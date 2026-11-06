# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

FlipWright: a hybrid-casual pinball game with roguelite table-building. iOS first, then Android and Web. Rust with an in-house engine.

## Read first

- `docs/requirements.md`: requirements R1–R13. Source of truth.
- `docs/game-design.md`: game design.
- `docs/architecture.md`: tech stack, code structure, testing, performance, engine separability.
- `docs/dev-plan.md`: milestones and exit criteria. Work on the current milestone only.
- `docs/dev-process.md`: development rules and branch strategy. Follow it for every change.

Never merge a `docs/*` PR yourself; the human merges those.

## Commands

```sh
cargo test --workspace                          # all tests
cargo test -p flipwright-core <name>            # single test (by name filter)
cargo clippy --workspace --all-targets -- -D warnings
cargo fmt --all
cargo llvm-cov -p flipwright-core --fail-under-lines 100   # core coverage gate
scripts/check-engine-separability.sh            # engine builds and tests without FlipWright
```

Local coverage with Homebrew Rust (no rustup) needs Homebrew LLVM tools:
`LLVM_COV=/opt/homebrew/opt/llvm/bin/llvm-cov LLVM_PROFDATA=/opt/homebrew/opt/llvm/bin/llvm-profdata cargo llvm-cov ...`

CI (`.github/workflows/ci.yml`) runs the same checks on every PR. iOS build and run commands: added with the iOS host (M0).
