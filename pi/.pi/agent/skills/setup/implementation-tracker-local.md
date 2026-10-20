# Implementation tracker: Local Markdown

Implementations and PRDs for this repo live as markdown files in `docs/features/`.

## Conventions

- One feature per directory: `docs/features/<NN>-<feature-slug>/`, numbered from `01`
- The PRD is `docs/features/<NN>-<feature-slug>/PRD.md`
- Implementation plans are `docs/features/<NN>-<feature-slug>/implementation/<NN>-<slug>.md`, numbered from `01`   
- Triage state is recorded as a `Status:` line near the top of each issue file (see `triage-labels.md` for the role strings)
- Comments and conversation history append to the bottom of the file under a `## Comments` heading

## When a skill says "publish to the implementation tracker"

Create a new file under `docs/features/<NN>-<feature-slug>/implementation/` (creating the directory if needed).

## When a skill says "fetch the relevant plan"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.