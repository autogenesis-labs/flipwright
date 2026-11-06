# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

FlipWright: a hybrid-casual pinball game with roguelite table-building. iOS first, then Android and Web. Rust with an in-house engine.

## Read first

- `docs/requirements.md`: requirements R1–R13. Source of truth.
- `docs/game-design.md`: game design.
- `docs/architecture.md`: tech stack, code structure, testing, performance, engine separability.
- `docs/dev-plan.md`: milestones and exit criteria. Work on the current milestone only.

## Rules

- AI writes all code; humans review only requirements, architecture, the plan and playable builds. Propose changes to any `docs/` file to the human instead of just making them.
- YAGNI: build only what the current milestone needs.
- `crates/core` needs 100% test coverage; the main flows (game-design.md §11) need end-to-end tests.
- `engine/` must never depend on code outside `engine/` or contain game-specific code (R13).
- Draw assets in code. Image prompts for the human go in `docs/image-prompts.md`.
- English only.

## Commands

None yet. Add build, test, single-test, coverage and iOS run commands once the workspace is scaffolded (M0).
