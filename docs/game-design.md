# FlipWright Game Design

Status: approved (see §12). Milestones are in [dev-plan.md](dev-plan.md). All numbers are starting values for tuning, not commitments.

## 1. Pitch

**Build the table you play.** You are a *flipwright*, a maker of pinball machines. Each run, you take a contract, play short pinball rounds on your own machine, and between rounds you install parts you draft onto the playfield. Where you place them changes both the ball's path and the way the parts combo with each other. A good machine is something you built yourself, not something you found.

- **Genre:** hybrid-casual pinball with roguelite table-building.
- **Session:** one contract takes about 8 to 10 minutes. One round takes about 1 to 2 minutes.
- **Orientation:** portrait, single screen, no scrolling.
- **Controls:** tap the left or right half of the screen to flip.
- **Scope:** a public demo with general game features only (§13).

## 2. Differentiation (R2)

Existing mobile pinball games are mostly one of these:

- simulations of real licensed tables,
- fixed arcade tables played for a high score,
- or "pinball-like" casual games (ball drop, brick breaker) without real flipper play.

FlipWright keeps real flipper skill but adds three hooks that none of those combine:

1. **The player builds the playfield.** Placement is a spatial puzzle: a part only scores if the ball can reach it, and adjacent parts interact.
2. **Run-based drafting with escalating quotas.** Every run produces a different machine, which gives replay value without new hand-made content.
3. **Visible long-term progress.** A night-time city skyline lights up one district per completed contract. It is the meta-progression map and the main menu.

## 3. Core loop

```
Contract (one run)
 ├─ Round 1..5: play pinball → reach quota
 │    └─ Workshop between rounds: draft 1 of 3, place/move parts
 └─ Round 6: Inspection (boss round with a table modifier)
→ Rewards: Blueprints (meta currency), district lights up
→ Meta: unlock parts/mods into the draft pool, new chassis, workshop perks
```

### 3.1 Round

- Each round has a **score quota** and **2 balls**.
- Reaching the quota completes the round. Play continues for bonus **Scrap** until both balls drain, or until the player taps **Cash Out**.
- Draining both balls before reaching the quota fails the contract.
- **Ball saver:** for the first 5 s after each launch, a drained ball is returned.
- **Quota curve:** round *n* quota = `base × 1.6^(n−1)`, with `base = 1,000`. The final round has a fixed ×1.3 on top.

### 3.2 Workshop (between rounds)

- **Draft:** pick 1 of 3 offers. An offer is either a **Part** (placed on the table) or a **Mod** (a global rule change).
- **Place:** drag parts into empty **sockets**. Parts already placed can be moved or swapped for free.
- **Merge:** drafting a part you already own lets you upgrade it (level 1 → 2 → 3) instead of placing a second copy.
- **Reroll:** 1 free reroll per workshop. More rerolls cost Scrap (cost doubles each time).
- **Scrap:** earned from score above quota (1 Scrap per 20% over quota, max 5 per round). Spent only on rerolls in the MVP.

### 3.3 Inspection (final round)

The last round of every contract applies one **Inspection modifier**, drawn from the district's set. The player sees it before the last workshop so they can prepare. Examples:

- **Blackout:** the upper half of the table is dark except for 0.5 s flashes on each hit.
- **Crosswind:** gravity is tilted 8° to one side.
- **Short Flippers:** flipper length −20%.
- **Wear:** each part stops working after 10 hits for this round.

### 3.4 Failure and rewards

- Completing a contract awards Blueprints and lights the district.
- Failing still awards Blueprints in proportion to the rounds cleared (minimum 1). A failed run always makes some progress, which supports retention.

## 4. The table

### 4.1 Fixed layout (Chassis "Workbench", MVP)

From bottom to top:

- **Drain** between two **flippers**, with inlanes and outlanes on each side.
- **Slingshots** above each flipper pair (fixed, 1 pt per hit, they kick the ball).
- **Plunger lane** on the right. Hold anywhere and release to launch, with a power meter.
- **Socket field**: **9 sockets** in a staggered 3-3-3 pattern in the upper two-thirds. Two sockets are adjacent if they are neighbours in the stagger, so each socket has up to 6 neighbours.
- **Top lanes:** 3 rollover lanes. Lighting all 3 gives +1 Mult for the current ball. Flippers rotate the lit lanes (lane change).

### 4.2 Scoring model

`hit score = part points × Mult × Momentum bonus`

- **Mult** starts at ×1 for each ball. Some parts and the top lanes increase it. It resets when the ball drains.
- **Momentum** rewards keeping the ball active in the socket field:
  - Every part hit within **1.5 s** of the previous hit adds +1 Momentum (max 10).
  - The Momentum bonus is `1 + 0.1 × Momentum` (up to ×2).
  - Momentum decays by 1 every 1.5 s without a hit and resets on drain.
  - Each consecutive hit plays the next note of a musical scale, so a good chain is something you hear (see §7).
- **Overdrive:** the Overdrive meter fills with every hit (more at high Momentum). When it is full, tapping both flippers at once triggers 8 s of Overdrive: all scoring ×2, a short slow-motion entry (0.3 s at 30% speed), and the music switches to a high-intensity layer.

### 4.3 Parts (MVP pool: 16)

Each part fills one socket and has a distinct silhouette, so shape alone identifies it (accessibility). Points shown are level 1. Levels 2 and 3 multiply points by 2 and 4, unless noted otherwise.

| # | Part | Type | Effect |
|---|---|---|---|
| 1 | Pop Bumper | Bumper | 10 pts. Kicks the ball away. |
| 2 | Copper Coil | Bumper | 5 pts. Each hit charges adjacent parts: their next hit scores +50%. |
| 3 | Ember Bumper | Bumper | 4 pts × current Momentum. |
| 4 | Drop Bank | Target | 3 drop targets, 25 pts each. Clearing the bank: +1 Mult, then it resets. |
| 5 | Bullseye | Target | 60 pts, but only when hit above a speed threshold. Otherwise 5. |
| 6 | Spinner | Spinner | 2 pts per rotation. Faster ball → more rotations. |
| 7 | Dynamo | Spinner | 1 pt per rotation. Each rotation adds extra Overdrive charge. |
| 8 | Saucer | Kicker | Holds the ball for 1 s and scores the sum of adjacent parts' base points, then ejects toward the flippers. |
| 9 | Magnet | Utility | Pulls the ball in and releases it toward the highest-value adjacent part. 3 s cooldown. |
| 10 | Mirror | Utility | Each hit triggers the effect of one random adjacent part. |
| 11 | Deflector | Utility | An angled wall the player can rotate in the workshop (8 steps). No score. Used to route the ball. |
| 12 | Battery | Utility | Stores 20% of all adjacent hit points. Hitting the Battery releases the stored points ×2. |
| 13 | Lucky Pin | Bumper | 5 pts. 1-in-4 chance of 100 pts instead. Level up improves the odds (1/3, 1/2). |
| 14 | Lock | Kicker | The first hit locks the ball and launches a new one. The second lock starts a 2-ball multiball. Once per ball. |
| 15 | Rail Post | Utility | Places a temporary post between flippers that blocks one drain per round. Levels add uses. |
| 16 | Prism Target | Target | 15 pts. Changes colour each hit. Three hits on the same colour in a row: +2 Mult. |

### 4.4 Mods (MVP pool: 10)

Mods are global and do not take a socket. A run can hold up to 5.

| Mod | Effect |
|---|---|
| Heavy Ball | Ball mass +30% (slower, harder to control). All points +25%. |
| Hot Flippers | Flipper hits add +1 Momentum. |
| Long Flippers | Flipper length +12%. |
| Patience | Ball saver lasts 10 s. |
| Overclock | Overdrive lasts 12 s. |
| Tight Chain | Momentum window is 2.0 s instead of 1.5 s. |
| Third Ball | +1 ball per round. Quotas +25%. |
| Salvage | +1 Scrap per round. |
| Lane Master | Top lanes give +2 Mult instead of +1. |
| Sympathy | Adjacency effects also reach parts two sockets away. |

### 4.5 Draft pool and unlocks

- New players start with 8 parts and 4 mods in the pool. The rest are unlocked with Blueprints.
- Offers are drawn from a seeded RNG. The same seed always produces the same offers (needed for tests and replays).
- The first offer of a contract always includes at least one bumper, so a new table can always score.

## 5. Meta progression

- **Skyline:** 6 districts in the MVP. Each district is a client with 2 or 3 contracts and its own set of Inspection modifiers. Finishing a contract lights a block of windows. Finishing a district turns on its landmark (a code-drawn silhouette).
- **Blueprints** (meta currency) are spent in the **Workshop Ledger** on:
  - unlocking parts and mods into the pool,
  - workshop perks: +1 free reroll, start each contract with one placed Pop Bumper, +1 draft option (choose 1 of 4).
- **Difficulty:** each new district raises the base quota by 15% and adds a harder Inspection set.

## 6. Retention features

| Feature | Phase | Purpose |
|---|---|---|
| Contract with escalating quotas | MVP | Short, complete session with a clear goal. |
| Skyline progress | MVP | Visible long-term goal on the main screen. |
| Always-some-reward on failure | MVP | A failed run still counts. |

Retention targets for evaluating playtests: D1 ≥ 40%, D7 ≥ 15%.

Monetization is out of scope (§13).

## 7. Feel and immersion (R3)

Immersion comes mostly from responsiveness and feedback, not from content:

- **Frame rate:** 120 fps on ProMotion devices, 60 fps minimum on all supported devices. Input-to-flipper latency must be under one frame.
- **Haptics:** every collision triggers a transient haptic scaled by impact speed. Flippers get a sharp click. Overdrive gets a continuous rumble.
- **Musical scoring:** each Momentum step plays the next note of a pentatonic scale on the current part's instrument. A long chain becomes a melody. Music layers are added as Momentum rises.
- **Procedural audio:** sound effects are synthesized in code (filtered noise, FM tones), consistent with R10.
- **Juice:** hit flashes, particle sparks, score pop-ups, brief camera shake on strong hits (capped), slow-motion entry into Overdrive.
- **Part reveal:** a newly placed part "inks in" from blueprint lines to its glowing finished form.

### Settings and accessibility

- Haptics on/off, reduce motion (no shake or slow-motion), sound and music volume.
- Every part type has a unique silhouette in addition to its colour.
- Left-handed option: plunger can be released with either hand (hold anywhere).

## 8. Art direction (R10, R11)

- **Style:** neon blueprint. Dark navy background with a faint grid. Parts are drawn as glowing vector shapes with additive bloom. Placed parts are bright; empty sockets are dashed blueprint outlines.
- **Everything in the game is code-drawn:** table geometry, parts, particles, UI, fonts rendered from a bundled open-licence typeface, and the skyline.
- **Generated images (R11)** only where an image is truly needed outside the game rendering. Prompts are written into `docs/image-prompts.md` when needed. The app icon is code-drawn (§13).

## 9. Physics requirements

The physics must feel like real pinball, and it must be deterministic.

- **Fixed timestep:** 1/240 s simulation step, independent of frame rate, with rendering interpolated between steps.
- **Substepping:** extra substeps when the ball moves faster than half its radius per step. No tunnelling through any wall or flipper at maximum ball speed.
- **Shapes:** the ball is a circle. The table uses line segments, arcs, circles and capsules (flippers). No general-purpose rigid-body engine is needed.
- **Flippers:** kinematic rotating capsules with a fixed angular speed. The ball receives the flipper's surface velocity at the contact point, so "post passes", "cradles" and late flips work as in real pinball.
- **Effective gravity:** tuned for the feel of a 6.5° table incline, then adjusted in playtests.
- **Restitution and friction:** set per material (rubber, metal, plastic).
- **Determinism:** same seed + same input timeline → identical results on the same build. This is required for tests and input replays. Cross-platform bit-identical results are not required in the MVP.

## 10. Screens and flows

1. **Skyline (home):** city skyline, Continue/Start Contract button, Ledger, Settings.
2. **Contract intro:** client name, district, round count, preview of the Inspection modifier pool.
3. **Round (gameplay):** quota bar, score, Mult, Momentum gauge, Overdrive meter, balls left, Cash Out (visible after the quota is reached), pause.
4. **Workshop:** table view with sockets, 3 offer cards, reroll button, Scrap count, Next Inspection preview (before the last round), Start Round.
5. **Contract result:** rounds cleared, Blueprints earned, skyline animation.
6. **Ledger:** unlock tree for parts, mods and perks.
7. **Settings.**

**Pause and resume:** leaving the app pauses the game. The full run state is saved at every workshop and when the app goes to the background, so a run can always be resumed.

### First-time experience

- The first contract is scripted: round 1 has two pre-placed Pop Bumpers and no workshop before it. On-screen hints show tap-to-flip and hold-to-launch.
- The first workshop has fixed offers that teach adjacency (Copper Coil next to a bumper).
- No text tutorials longer than one line.

## 11. Main flows that need end-to-end tests (R8)

1. First launch → scripted first contract → round 1 → workshop → round 2.
2. Complete a full contract → result screen → district lights up on the skyline.
3. Fail a contract → Blueprints awarded → spend them in the Ledger.
4. Background the app mid-round → reopen → resume the same state.
5. Settings changes persist across restarts.

## 12. Review decisions (2026-11-06)

1. Art direction: neon blueprint, approved.
2. Rounds: ball-based (2 balls per round), approved.
3. Retention targets: D1 ≥ 40%, D7 ≥ 15%, approved.
4. Monetization: out of MVP scope, approved.
5. Project scope: public demo with general game features only (§13, R14).

## 13. Scope (R14)

This repository is a public demo: the complete playable game described in §1 to §11, with general game features only.

Out of scope:

- Ads, in-app purchases and cosmetic skins.
- Analytics, crash reporting and remote config.
- Online services: leaderboards, cloud save, sharing.
- Daily Contract and streaks.
- Store release: bundle ID, signing, privacy manifest, tracking consent, store listing and store images. The demo uses a code-drawn app icon and runs on development devices.
- Content beyond §4 and §5, such as additional chassis and districts.

No code, SDKs, keys, configuration, assets or hooks for out-of-scope features are added to this repository.
