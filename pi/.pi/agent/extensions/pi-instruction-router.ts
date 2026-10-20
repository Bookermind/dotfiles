
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import {
  existsSync,
  readdirSync,
  readFileSync,
} from "node:fs";
import { homedir } from "node:os";
import {
  isAbsolute,
  join,
  relative,
  resolve,
} from "node:path";

const INSTRUCTIONS_DIR = join(
  homedir(),
  ".pi",
  "agent",
  "instructions",
);

const MESSAGE_TYPE = "pi-instruction-router";

interface InstructionRule {
  id: string;
  source: string;
  patterns: RegExp[];
  body: string;
}

function walkMarkdownFiles(directory: string): string[] {
  if (!existsSync(directory)) return [];

  const files: string[] = [];

  for (const entry of readdirSync(directory, {
    withFileTypes: true,
  })) {
    const fullPath = join(directory, entry.name);

    if (entry.isDirectory()) {
      files.push(...walkMarkdownFiles(fullPath));
    } else if (
      entry.isFile() &&
      entry.name.endsWith(".instructions.md")
    ) {
      files.push(fullPath);
    }
  }

  return files;
}

// Supports common Copilot applyTo glob syntax, including:
// - globstar followed by slash and py extension
// - src directory, globstar, slash, and py extension
// - sql extension
// Matching is case-sensitive, as on Linux.
function globToRegExp(glob: string): RegExp {
  let result = "";

  for (let i = 0; i < glob.length; i++) {
    const char = glob[i];

    if (char === "*") {
      if (glob[i + 1] === "*") {
        i++;

        if (glob[i + 1] === "/") {
          // **/ also matches zero directory levels.
          result += "(?:.*/)?";
          i++;
        } else {
          result += ".*";
        }
      } else {
        result += "[^/]*";
      }
    } else if (char === "?") {
      result += "[^/]";
    } else {
      result += char.replace(/[|\\{}()[\]^$+?.]/g, "\\$&");
    }
  }

  return new RegExp(`^${result}$`);
}

function parseInstruction(
  filePath: string,
): InstructionRule | undefined {
  const source = readFileSync(filePath, "utf8");

  // Require YAML-style front matter at the beginning.
  const frontMatter = source.match(
    /^---\s*\r?\n([\s\S]*?)\r?\n---\s*(?:\r?\n|$)/,
  );

  if (!frontMatter) return undefined;

  const applyToLine = frontMatter[1]
    .split(/\r?\n/)
    .find((line) => /^\s*applyTo\s*:/.test(line));

  if (!applyToLine) return undefined;

  let applyTo = applyToLine
    .replace(/^\s*applyTo\s*:\s*/, "")
    .trim();

  // Remove matching outer quotes.
  if (
    (applyTo.startsWith('"') && applyTo.endsWith('"')) ||
    (applyTo.startsWith("'") && applyTo.endsWith("'"))
  ) {
    applyTo = applyTo.slice(1, -1);
  }

  // Copilot commonly permits comma-separated glob patterns.
  const patterns = applyTo
    .split(",")
    .map((pattern) => pattern.trim())
    .filter(Boolean)
    .map(globToRegExp);

  const body = source.slice(frontMatter[0].length).trim();

  if (patterns.length === 0 || !body) return undefined;

  return {
    id: filePath,
    source: filePath,
    patterns,
    body,
  };
}

function loadInstructions(): InstructionRule[] {
  const rules: InstructionRule[] = [];

  for (const file of walkMarkdownFiles(INSTRUCTIONS_DIR)) {
    try {
      const rule = parseInstruction(file);

      if (rule) {
        rules.push(rule);
      } else {
        console.error(
          `[pi-instruction-router] Skipping invalid instruction file: ${file}`,
        );
      }
    } catch (error) {
      console.error(
        `[pi-instruction-router] Failed to load ${file}:`,
        error,
      );
    }
  }

  return rules;
}

function cleanPathToken(token: string): string {
  return token
    .replace(/^[`"'([{]+/, "")
    .replace(/[`"')\]},;:!?]+$/, "");
}

/**
 * Extracts explicit file-like paths from a user prompt.
 * This is intentionally a convenience, not a complete
 * natural-language path parser.
 */
function extractPaths(prompt: string): string[] {
  const matches =
    prompt.match(
      /(?:~\/|\/|\.{1,2}\/)?[A-Za-z0-9_@.+-][A-Za-z0-9_./@+-]*\.[A-Za-z0-9_-]+/g,
    ) ?? [];

  return [...new Set(matches.map(cleanPathToken))];
}

// Match absolute, working-directory-relative, and multi-root path suffixes.
function matchesPath(
  rule: InstructionRule,
  filePath: string,
  cwd: string,
): boolean {
  const expanded = filePath.startsWith("~/")
    ? join(homedir(), filePath.slice(2))
    : filePath;

  const absolute = isAbsolute(expanded)
    ? expanded
    : resolve(cwd, expanded);

  const candidates = new Set([
    expanded.replace(/\\/g, "/"),
    absolute.replace(/\\/g, "/"),
    relative(cwd, absolute).replace(/\\/g, "/"),
  ]);

  for (const candidate of candidates) {
    const segments = candidate.split("/");

    for (let i = 0; i < segments.length; i++) {
      const suffix = segments.slice(i).join("/");

      if (rule.patterns.some((pattern) => pattern.test(suffix))) {
        return true;
      }
    }
  }

  return false;
}

export default function (pi: ExtensionAPI) {
  const cwd = process.cwd();

  let rules: InstructionRule[] = [];
  let activePaths = new Set<string>();

  // Rules already present in this turn's system prompt.
  let systemPromptRules = new Set<string>();

  // Rules made available through the context hook this turn.
  // These allow a blocked write to be retried after the model
  // has received the relevant instructions.
  let contextInjectedRules = new Set<string>();

  function matchingRules(paths: Iterable<string>): InstructionRule[] {
    const matched = new Map<string, InstructionRule>();

    for (const filePath of paths) {
      for (const rule of rules) {
        if (matchesPath(rule, filePath, cwd)) {
          matched.set(rule.id, rule);
        }
      }
    }

    return [...matched.values()];
  }

  function renderRules(selected: InstructionRule[]): string {
    return [
      "The following project coding instructions apply to files",
      "relevant to this task. Follow them when creating, editing,",
      "or reviewing matching files.",
      "",
      ...selected.map(
        (rule) =>
          `## Instructions: ${rule.source}\n\n${rule.body}`,
      ),
    ].join("\n");
  }

  pi.on("session_start", async () => {
    rules = loadInstructions();

    console.error(
      `[pi-instruction-router] Loaded ${rules.length} instruction rule(s) from ${INSTRUCTIONS_DIR}`,
    );
  });

  pi.on("before_agent_start", async (event) => {
    // Reload each turn so changes to global instruction files
    // are picked up without restarting Pi.
    rules = loadInstructions();

    activePaths = new Set(extractPaths(event.prompt));
    systemPromptRules = new Set();
    contextInjectedRules = new Set();

    const selected = matchingRules(activePaths);

    if (selected.length === 0) return;

    for (const rule of selected) {
      systemPromptRules.add(rule.id);
    }

    return {
      systemPrompt: [
        event.systemPrompt,
        renderRules(selected),
      ].join("\n\n"),
    };
  });

  pi.on("tool_call", async (event) => {
    // The built-in read/write/edit tools use a `path` argument.
    // This hook deliberately does not attempt to parse arbitrary
    // shell commands for file paths.
    const input = event.input as Record<string, unknown>;
    const filePath =
      typeof input.path === "string"
        ? input.path
        : typeof input.filePath === "string"
          ? input.filePath
          : undefined;

    if (!filePath) return;

    activePaths.add(filePath);

    const selected = matchingRules([filePath]);

    if (selected.length === 0) return;

    const isWriteOperation = [
      "write",
      "edit",
      "apply_patch",
    ].includes(event.toolName);

    if (!isWriteOperation) return;

    // If a matching rule hasn't reached the model yet, block the
    // first write. The context hook will provide the instructions
    // after the blocked tool result, allowing a retry.
    const missing = selected.filter(
      (rule) =>
        !systemPromptRules.has(rule.id) &&
        !contextInjectedRules.has(rule.id),
    );

    if (missing.length > 0) {
      return {
        block: true,
        reason:
          "The write was paused because applicable coding " +
          "instructions have not yet been provided. Review the " +
          "instruction context in the next model request, then retry.",
      };
    }
  });

  pi.on("context", async (event) => {
    const selected = matchingRules(activePaths).filter(
      (rule) => !systemPromptRules.has(rule.id),
    );

    if (selected.length === 0) return;

    // Keep the discovered-file instructions in each subsequent
    // model request for this turn, not just the first one.
    for (const rule of selected) {
      contextInjectedRules.add(rule.id);
    }

    return {
      messages: [
        ...event.messages,
        {
          role: "custom" as const,
          customType: MESSAGE_TYPE,
          content: renderRules(selected),
          display: false,
          timestamp: Date.now(),
        },
      ],
    };
  });
}
