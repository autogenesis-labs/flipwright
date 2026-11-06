# FlipWright Development Plan

Status: approved scope (milestones from the approved game design). Detailed tasks inside a milestone may change; changes to milestone scope or exit criteria need human review.

The plan covers the scope in game-design.md §13 (R14).

Development is iterative (R7). Each milestone ends with a playable iOS build that the human reviews before the next milestone starts. Only what the current milestone needs is built (R9). Rules and branch strategy are in [dev-process.md](dev-process.md).

Every milestone must also meet the standing exit criteria:

- `crates/core` at 100% line coverage (R8).
- The engine builds and tests with FlipWright crates removed (R13).
- No frame-time regression in the benchmarks.

## M0: Physics sandbox (go/no-go gate)

Goal: prove the stack on a real iPhone before building game features.

- Rust workspace scaffold (`engine/`, `crates/core`, `crates/game`, `crates/e2e`, `platform/ios`) and CI with tests, coverage gate and the engine-separability check.
- Engine: `winit` + `wgpu` window on iOS, fixed-step loop with render interpolation, shape renderer (circles, segments, capsules, arcs) with reduced-resolution bloom, touch input, frame-timing overlay.
- Core: ball physics with substepping, walls, slingshots, flippers with surface-velocity transfer, plunger, drain.
- Engine demo app in `engine/examples/`.

Exit criteria:

- 120 fps on a ProMotion iPhone and 60 fps on the oldest supported iPhone over a 5-minute scripted session (architecture.md §5).
- No tunnelling at maximum ball speed (unit-tested).
- Determinism test: same input timeline → identical state.
- Backgrounding and resuming the app works without losing the rendering surface.

## M1: One round

Goal: a single scored round is fun to play.

- Socket field (9 sockets) with fixed parts: Pop Bumper, Drop Bank, Spinner.
- Top lanes and lane change.
- Scoring: points, Mult, Momentum.
- Round rules: quota, 2 balls, ball saver, Cash Out.
- HUD: score, quota bar, Mult, Momentum, balls left.
- First scenario test: play a scripted round to completion.

Exit criteria: the human can play a full round on device and judge flipper feel and scoring.

## M2: Contract loop

Goal: the full run structure.

- Workshop: draft 1 of 3, placement and moving, merging/levels, rerolls, Scrap.
- All 16 parts and 10 mods.
- Seeded draft RNG.
- 6-round contract with escalating quotas, Inspection round with modifiers.
- Contract result screen.

Exit criteria: a complete contract can be won and lost on device; scenario tests for contract win and loss.

## M3: Meta progression

Goal: reasons to keep playing across sessions.

- Skyline home screen with districts.
- Blueprints and the Ledger (unlocks and workshop perks).
- Save and resume (at every workshop and on backgrounding).
- Scripted first-time experience.

Exit criteria: end-to-end tests for game-design.md §11 flows 1 to 4.

## M4: Feel and retention

Goal: immersion.

- Haptics through the engine's iOS bridge.
- Procedural audio, musical Momentum scoring, music layers.
- Overdrive, particles, hit flashes, capped camera shake, slow-motion.
- Settings (haptics, reduce motion, volumes).

Exit criteria: end-to-end tests for game-design.md §11 flow 5; on-device UI smoke test (XCUITest) for all main flows; performance targets still met with all effects on.

## M5: Android and Web

Goal: the other target platforms.

- Engine Android host and FlipWright Android app.
- Engine web host and FlipWright web build.
- Platform-specific haptics and audio start handling.

Exit criteria: all scenario tests pass on each platform build; 60 fps on a mid-range Android device; web download size reviewed with the human.

## After development

- Extract `engine/` into its own repository (architecture.md §7) and switch FlipWright to depend on it.
