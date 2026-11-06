# FlipWright Development Process

Status: approved (2026-11-06). Changes need human review.

How work is done in this repository. What to build and when is in [dev-plan.md](dev-plan.md).

## Roles

- **AI** writes all code, tests and documents, and opens and merges code PRs.
- **Human** reviews requirements, game design, architecture, the plan, this process, and playable builds. The human does not review code (R6).

Because nobody reviews code, correctness comes from tests and CI.

## Rules

- **YAGNI (R9).** Build only what the current milestone needs. No speculative abstractions, options or plugin systems.
- **Testing (R8).**
  - `crates/core` keeps 100% line coverage.
  - Every main flow in game-design.md §11 has an end-to-end test by the milestone that delivers it.
- **Engine separability (R13).** `engine/` never depends on code outside `engine/` and contains no FlipWright or pinball-specific code.
- **Assets (R10, R11).** Draw assets in code. When an image is truly needed, write a GPT Image prompt in `docs/image-prompts.md` for the human to generate.
- **English only (R12)** for code, comments, commits, PRs and documents.
- **Scope (R14).** Nothing out of scope in game-design.md §13 is added to this repository. Outside pull requests are not accepted.
- **Documents are human-approved.** Changes to anything in `docs/` are proposed in a `docs/*` PR, never merged by the AI.

## Branch strategy

Trunk-based development with short-lived branches.

| Branch | Purpose | Merged by |
|---|---|---|
| `main` | Always builds and passes CI. Protected by a ruleset. | — |
| `m<N>/<task>` (e.g. `m0/scaffold`, `m0/flipper-physics`) | One small task of the current milestone. Lives hours to a day or two. | AI, after CI passes |
| `docs/<topic>` | Changes to `docs/`. | Human |

- Branch from the latest `main`. Never push directly to `main`.
- One task per branch. Keep PRs small enough that a failing CI run points to one change.
- Merge with **squash merge** only. The PR title becomes the commit message on `main`.
- Delete the branch after merging.
- A task that also needs a document change splits the document change into its own `docs/*` PR.

## `main` ruleset

- Pull request required, 0 approvals (the AI acts with the human's GitHub account and cannot approve its own PRs).
- Squash merge only.
- No force push, no branch deletion.
- Required status checks: added once CI exists (first task of M0); the checks must have run once before they can be required.

## Milestones

- A milestone is done when all its exit criteria in dev-plan.md pass on `main`.
- The AI then tags `main` (`m0`, `m1`, …) and provides a playable iOS build for human review.
- Problems found in review are fixed in new task branches. The next milestone starts only after the human accepts the current one.
