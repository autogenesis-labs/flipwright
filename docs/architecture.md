# FlipWright Architecture

Status: **approved (2026-11-06).**

## 1. Decision: one shared Rust codebase with a small custom 2D engine

FlipWright uses its own small 2D engine written in Rust, built on proven low-level libraries for graphics, windowing and audio. The game logic and the engine are shared by iOS, Android and Web. Each platform has only a thin native shell.

### Why not a separate codebase per platform

- Three codebases mean three implementations of the physics and game rules. They would drift apart, and pinball feel depends on small physics details.
- The 100% core coverage requirement (R8) would have to be met three times.
- The amount of AI-written code that nobody reviews (R6) would triple, and so would the risk.
- The performance gain is small: a 2D pinball table has one to a few balls and a few dozen static shapes. A shared native-compiled core is already fast enough. The performance work that matters is frame pacing, input latency and rendering, and each of those can be handled per platform inside the shared engine.

### Why a custom engine instead of an off-the-shelf one

The game needs only a narrow set of features, and most of them are things general engines do poorly for pinball:

| Need | Why general engines don't fit well |
|---|---|
| Pinball physics (fast ball, rotating flippers, no tunnelling, deterministic) | General rigid-body engines (Box2D, SpriteKit, Godot physics) are tuned for stacking and generic bodies. Pinball needs a custom ball-vs-shape solver with continuous collision anyway. |
| Code-drawn vector graphics with glow (R10) | A small shape renderer with signed-distance-field shapes and bloom is simpler than working around a sprite-oriented engine. |
| 120 fps and minimal input latency on iOS | Direct control over the frame loop and present timing. |
| Headless deterministic tests, 100% coverage (R8) | Pure Rust logic tests run with `cargo test` and coverage gates, with no editor or engine runtime. |
| Fully AI-developed via the command line (R6) | Everything is plain text and CLI-driven: no binary scene files, no editor. |

Engine scope is limited to what the game uses (R9): fixed-step loop, pinball physics, shape and text rendering, input, audio playback and synthesis, simple in-game UI, save files. Nothing else.

### Alternatives considered

| Option | Rejected because |
|---|---|
| Swift + Metal for iOS, then rewrite for Android and Web | Best possible iOS result, but means two or three rewrites later (see above). |
| TypeScript + Phaser/PixiJS + Capacitor | iOS runs inside WKWebView: less control over frame pacing, input latency and 120 Hz. Conflicts with R5. |
| Godot 4 | Large web exports, editor-centric workflow, generic physics. Harder to test fully from the CLI. |
| Unity | Heavy WebGL builds, editor-centric, poor fit for an AI-only CLI workflow. |
| C++ with SDL3 or sokol | Technically viable and similar to this proposal, but Rust's compiler checks catch more errors in code that no human reviews, and its test and coverage tooling is built in. |

## 2. Libraries

| Concern | Library | Notes |
|---|---|---|
| Graphics | `wgpu` | Metal on iOS, Vulkan/GLES on Android, WebGPU with WebGL2 fallback on Web. |
| Window, events, frame loop | `winit` | Supports iOS, Android and Web. |
| Audio | `kira` (or `cpal` directly) | Low-latency playback. Procedural synthesis is our own code. |
| Text | a small glyph-atlas text renderer, or `glyphon` if needed | Bundled open-licence font. |
| Serialization | `serde` + `serde_json` | Save files and scenario files. |
| iOS native APIs (haptics, later Game Center) | `objc2` bindings or a thin Swift shim | The only iOS-specific code. |

Library versions are pinned in `Cargo.lock`.

## 3. Structure (planned)

```
engine/                Extractable engine (R13). Never references anything outside engine/.
  crates/engine/       Rendering (wgpu), audio, input, frame loop, UI widgets, platform services API.
  platform/ios/        Reusable iOS host: Swift shell template + native bridges (haptics, audio session, lifecycle).
  platform/android/    Reusable Android host (M5).
  platform/web/        Reusable web host page and wasm loader (M5).
  examples/            Small standalone demo app that proves the engine works without FlipWright.
crates/
  core/                Pure game logic. No graphics, audio or platform dependencies.
                       Pinball physics, table and parts, scoring, round/contract/meta state machines,
                       seeded RNG, save data. 100% unit test coverage (R8).
  game/                Scenes and screens. Connects core to engine.
  e2e/                 Scenario runner for end-to-end tests.
platform/
  ios/                 FlipWright Xcode project (bundle ID, icons, Info.plist) built on engine/platform/ios.
  android/, web/       FlipWright app projects (M5).
```

Dependency direction: `game → engine`, `game → core`. `core` depends on nothing in the project and has no I/O. `engine` depends on nothing in the project.

Pinball physics lives in `core`, not in the engine: it is game-specific and must stay pure for determinism and coverage.

### Key design rules

- **Core is a deterministic simulation.** `core` advances in fixed 1/240 s steps from `(state, inputs) → state`. Rendering reads the state and interpolates; it never changes it.
- **Seeded randomness only.** All randomness in `core` comes from a seeded RNG stored in the run state. This makes the Daily Contract, replays and tests reproducible.
- **Platform code stays thin.** Platform shells only start the app and forward OS services (haptics, lifecycle, storage paths).

## 4. Testing (R8)

| Level | What | How |
|---|---|---|
| Unit | Everything in `core` | `cargo test`, coverage gate with `cargo llvm-cov` at 100% lines for `core`. |
| Scenario (end-to-end logic) | The main flows in game-design.md §11 | Scripted input timelines (JSON) run headless through `core` + `game` scene logic. Assertions on resulting state. |
| Render snapshots | Key screens | Offscreen wgpu render compared against reference images with a tolerance. |
| On-device UI | Smoke test of the main flows on iOS | XCUITest launches the app with a scenario argument. The app replays the scenario and exposes its state through an accessibility element the test reads. |

Because the UI is drawn by the engine (not UIKit), on-device tests cannot tap native views. Instead, the game exposes a test mode that accepts scripted input and reports state.

## 5. Performance budget (R5)

- 120 fps on ProMotion iPhones: under 8.3 ms per frame, target under 4 ms CPU.
- Input to flipper movement within the next simulation step.
- No heap allocations per frame in the simulation step.
- Cold start to Skyline screen under 2 s.

### How performance is verified

Performance is not assumed; it is measured, and M0 is a go/no-go gate:

- **Benchmarks:** `criterion` benchmarks for the simulation step and render preparation, run in CI to catch regressions.
- **In-app frame timing:** a debug overlay and log of CPU frame time, GPU frame time and missed frames.
- **On-device check:** M0 must hold 120 fps on a ProMotion iPhone and 60 fps on the oldest supported iPhone for a 5-minute scripted session, measured with the in-app timer and Xcode Instruments. If it fails, the architecture is revisited before any game features are built.
- **Known GPU cost:** full-screen bloom at native resolution is the most expensive effect, so it is rendered at reduced resolution.

## 6. Platform integration

| Platform | Build | Hosting | Notes |
|---|---|---|---|
| iOS | Rust compiled for `aarch64-apple-ios` into a static library (XCFramework), linked into a normal Xcode project | `winit` creates the view with a `CAMetalLayer`; `wgpu` renders through Metal | App Store submission is a standard Xcode archive. 120 Hz requires `CADisableMinimumFrameDurationOnPhone` in Info.plist and a display link preferring 120 Hz. Haptics (Core Haptics) and the audio session (`AVAudioSession`) go through the engine's iOS bridge. |
| Android | `cargo-ndk` builds a `.so` for arm64 and armv7, loaded by a Gradle project | `winit` with `android-activity` (GameActivity); `wgpu` on Vulkan, GLES fallback | Haptics through the Android Vibrator API via JNI. |
| Web | `wasm32-unknown-unknown` + `wasm-bindgen` | Canvas element; `wgpu` on WebGPU with WebGL2 fallback | Audio starts after the first user tap (browser rule). Download size budgeted in M5. |

Rust on iOS and Android is an established path: several shipped apps use a Rust core on mobile, and the `winit` + `wgpu` combination is what Bevy uses for its mobile targets. The parts that still need care are lifecycle events (backgrounding, surface loss), safe areas and 120 Hz frame pacing. All of these are verified in M0.

## 7. Engine separability (R13)

The engine lives in `engine/` from the start, so extracting it later is a mechanical step rather than a refactor.

- **No dependency on the game.** Nothing under `engine/` may reference a path outside `engine/`. A CI check (via `cargo metadata`) fails the build if an engine crate depends on a FlipWright crate.
- **No game knowledge.** No pinball concepts, FlipWright names, assets or tuning values in the engine. Game-specific code goes in `crates/game`.
- **Proven standalone.** `engine/examples/` contains a small demo app, and the engine has its own tests. Both build and pass with the FlipWright crates removed (checked in CI).
- **Platform hosts are generic.** Native bridges and host templates live in `engine/platform/`. App-specific settings (bundle ID, icons) stay in the top-level `platform/`.
- **Extraction procedure (at the end of development):** `git filter-repo --subdirectory-filter engine` into a new repository, add a workspace `Cargo.toml` and a licence, then switch FlipWright to depend on the new repository by git URL or version.
- **YAGNI still applies:** the engine only contains features FlipWright uses. Separability concerns where code lives and what it depends on, not adding general-purpose features.

## 8. Risks

| Risk | Mitigation |
|---|---|
| Building our own engine takes longer than expected | Scope is fixed to the list in §1. M0 is a physics sandbox on a real iPhone, so problems show up early. |
| `winit`/`wgpu` iOS integration issues (lifecycle, safe areas, ProMotion) | Verify in M0 before any game features. Fall back to a thin Swift shell that owns the `CAMetalLayer` and display link and calls into Rust. |
| Hybrid-casual SDKs (ads, analytics) are native only | Not needed for MVP. Later, bridge them through the platform shells. |
| Floating-point results differ across platforms | Not required for MVP (see game-design.md §9). Revisit if cross-platform leaderboard validation is needed. |
