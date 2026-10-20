---
name: to-implement
description: Convert a list of issues into implementation plans ready for human or machine execution.
---

# To Implement

Convert a list of issues into implementation plans ready for human or machine execution.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-matt-pocock-skills` if not.

## Process

### 1. Gather context

Work from whatever is already in the converation context. If the user passes an issue reference (issue number, URL, or path) as an arguement, fetch it from the issue tracker and read its full body and contents.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Issue titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

### 3. Draft implementation plans
For each issue, draft an implementation plan. Ensure to include full code diffs, explainations and review checklists in each implementation plan. Each plan should be detailed enough for a developer to pick up and execute without further clarification.

### 4. Quix the user

Present the proposed implementation plans. For each plan, show:   

- **Title**: short descriptive name
- **Blocked by**: which other plans (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)

Ask the user:
- Does the level of detail feel right? (too coarse / too fine)
- Are the dependency relationships correct?

Iterate until the user approves the implementation plans.

### 5. Publish the implementation plans to the implementation tracker

For each approved implementation plan, publish a new plan to the implementation tracker. Use the implementation body template below. Use the same filename as the issue this plan resolves but in the `implementation` subdirectory. These plans are considered ready for AFK agents, so publish them with the correct triage label unless instructed otherwise.

Publish plans in dependency order (blockers first) so you can reference real plan identifiers in the "Blocked by" field.

<implementation-template>
## Issue

A reference to the issue in the issue tracker that this plan resolves.

## What to build

### Overview

A concise description of the implementation work to be done. Describe the end-to-end behavior, not layer-by-layer implementation.

### Components to build

A detailed description of the implementation work to be done, including code diffs, explanations, and review checklists.
Split each component into its own section with a description title and a code diff.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by
- A reference to the blocking ticket (if any)

Or "None - can start immediately" if no blockers.

</implementation-template>