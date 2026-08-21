# No Hitter v0.17.1 Feedback Fixes — Execution Plan

## Status

The corrective update is implemented, validated, packaged, and published as v0.17.1 from app commit `a56c2dc`. Authoritative flight, opening drag, five-level pitch cadence, deferred reward presentation, focused copy, active campaign slots, compact subtitles, and dark responsive modals pass the focused and release suites plus uncached desktop/phone browser acceptance. The synchronized native/Web release, GitHub Pages deployment, and owner-only Sites version 31 are live.

## Goal

Ship a focused corrective update that fixes the stuck-flight state, restores believable opening air drag, changes ordinary pitch drafts to the expected five-level cadence, defers mandatory level rewards until the player deliberately advances, makes new-game slot selection safe and obvious, and brings every app-owned popup and the title subtitle into the established dark, responsive visual system.

## Requirements

### Gameplay and progression

- An authoritative volley must continue resolving even when its visual counterpart has not yet spawned or the batter renderer is between phases. A flight dial may never remain visible at `0.0s` after impact.
- The opening Wiffle Ball must have small but real atmospheric drag. Release speed remains 1 ft/s; plate speed is slightly lower and the roughly three-second opening joke remains intact.
- Keep the finite topology at 33 human + 33 alien + 33 eldritch + level-100 Octathulhu. Narrative sub-eras remain three authored opponents because they drive content, distance, and story.
- Decouple ordinary pitch drafts from the three-level narrative sub-era boundary. Ordinary pitch drafts occur at cleared finite levels 5, 10, 15, and so on; authored league bosses keep their separate boss-pitch rewards. Level 100 remains a boss reward. Endless pitch cadence also uses five cleared levels.
- A level-clear reward is generated and saved when earned, but it is not presented while the player remains on the cleared opponent. The player may keep pitching and gaining mastery there.
- Pressing **Next Level** with mandatory choices queued opens the choice dialog. Once all choices required before that transition are resolved, the game immediately enters the requested next level (or proceeds through the appropriate story gate). Passive refresh must not open a choice dialog.
- Auto-advance must not skip an unresolved mandatory choice boundary. Preserve deterministic serialized offers and reload protection.

### Copy and information design

- Pitch-choice cards must distinguish the randomized draft-quality gain from the pitch's innate/base profile. Use concise labels such as `DRAFT BONUS` and `BASE PROFILE`; do not show two unlabeled Quality values.
- Payload help reads simply and mathematically: `Payload multiplies XP from completed strikeouts.` Remove implementation reassurance about invisible balls from all matching descriptions.
- The full body modifier chain remains available in the detailed loadout/body name, but the game subtitle uses a compact build descriptor: at most one strength class plus one compatible conditioning adjective before the age/body noun. Preserve pluralization for clones. A valid result is `A baseball game about suspiciously buff, toned toddlers.`

### New game, saves, and responsive UI

- **Start New Game** on the title screen opens a dedicated save-slot picker instead of the typed global-reset dialog.
- Empty slots start immediately. Occupied slots require a clear slot-specific overwrite confirmation; starting a new slot must not erase other slots or require typing `RESET`.
- The destructive typed-reset flow remains only under **Reset Progress** in the in-game Saves screen and must fit a 390×844 viewport.
- All app-owned story, reward, offline, update, prestige, inspection, overwrite, and reset dialogs use the established navy/teal/gold/red game styling instead of Godot gray/native-looking surfaces. Native file pickers remain native.
- Modal content and actions remain reachable at 390×844 and at the compact desktop edge. The title screen controls must stay in-frame without page scrolling.

## Constraints and non-goals

- Do not change the 100-level campaign topology, authored opponent order, save-slot count, or prestige reset rules.
- Do not make a fresh save incompatible with v0.17.0, wipe existing saves, or repurpose the global reset dialog as slot overwrite.
- Do not alter combat outcomes merely to fix visual flight state; authoritative simulation remains the source of truth.
- Do not add future-layer spoilers to fresh UI.
- Browser, PWA, Pages, Sites, macOS, Windows, and Linux must continue to share one gameplay source.

## Relevant repository state and discoveries

- `scripts/main.gd::_process()` currently disables live simulation whenever `PitchField.is_simulation_clock_available()` is false. A saved authoritative volley can exist before the visual volley/batter becomes active, so `GameState._resolve_elapsed()` takes the replacement-only early return and never advances that volley.
- `scripts/game_state.gd::get_ball_drag_per_foot()` explicitly returns zero for the untouched opening shell.
- `scripts/campaign.gd` uses `LEVELS_PER_SUBERA = 3` for both authored narrative grouping and `pitch_draft`, which is why level 3 offers a pitch.
- `scripts/main.gd::_maybe_show_pending_overlay()` passively opens any queued run choice. `set_current_opponent()` blocks advancement while choices exist.
- `scripts/main.gd::_request_new_game_from_title()` treats `last_load_succeeded` alone as progress, routing even a fresh file into global hard reset.
- `scripts/main.gd::_run_choice_option_text()` prints both `quality_gain` and a pitch description containing another Quality value without labeling their distinct roles.
- `scripts/game_state.gd::get_body_growth_noun()` intentionally emits the full adjective chain, and `_get_game_subtitle()` uses it directly.
- The main theme does not style `AcceptDialog` or `ConfirmationDialog`; several custom `Window` modals also retain native chrome. `loot_item_dialog` is the existing dark/borderless reference.

## Decisions

1. Five levels is the **ordinary pitch-draft cadence**, not a rewrite of the 33/33/33 authored story topology.
2. Offers are still generated and serialized at clear time. Presentation and level transition are deferred until the player requests Next Level, preserving deterministic saves and permitting continued farming.
3. Opening drag is a small atmospheric Wiffle loss (target roughly 0.5–1% across 3 ft), not a display-only fiction.
4. New games are slot-scoped. Global typed reset remains an explicitly destructive in-game maintenance action.
5. Subtitle compaction is presentation-only; detailed body/loadout text retains the complete build history.

## Milestones

### M1 — Simulation, cadence, and deferred reward flow

- Fix authoritative-flight clock gating and retire stale visual flight indicators.
- Add opening atmospheric drag and update physical-flight expectations.
- Decouple five-level pitch cadence from narrative sub-eras and update campaign/help/audit assertions.
- Defer choice presentation until Next Level; resolve queued choices and then complete the requested transition safely across ordinary and story boundaries.
- Clarify pitch-card and Payload copy.
- Add focused regressions for each behavior and run the core/progression suites.

### M2 — New-game slots, compact subtitle, and modal visual system

- Add the title new-game slot picker and slot-specific overwrite behavior.
- Add compact subtitle body descriptors while preserving detailed modifier chains.
- Apply a reusable dark responsive style/layout to app-owned dialogs; keep native file pickers unchanged.
- Add phone/compact desktop interaction and geometry regressions.

### M3 — Primary integration, visual acceptance, parity, and release

- Review both milestones' actual diffs and test evidence; resolve cross-cutting state/UI issues.
- Run the repository-wide gameplay, save/migration, browser, desktop, and portrait suites.
- Perform local real-browser acceptance at desktop, compact-edge, and 390×844 layouts, including new-game, reward, story, update, reset, and flight states.
- Bump to v0.17.1, package and archive-verify every target, verify Web parity/update metadata, publish GitHub Pages/release assets and owner-only Sites, then verify both deployment pipelines without automatically opening the live page.

## Acceptance criteria

- Rehydrated or temporarily unrendered volleys resolve; no flight indicator persists at `0.0s`.
- Fresh level-one telemetry shows a small positive drag loss and internally consistent release speed, plate speed, and travel time.
- No ordinary pitch choice appears at level 3; regular pitch choices follow a five-level cadence and boss rewards remain present.
- Clearing a level leaves the player actively pitching there with no forced modal. Next Level opens the saved mandatory choice, and choosing it enters the requested next stage.
- Pitch cards and Payload help are concise and unambiguous.
- Fresh Start New Game always offers slots and never invokes typed global reset. Existing slots survive starting another slot.
- Long body builds yield a compact, readable subtitle and all title actions remain reachable on phone.
- App-owned modals are dark, coherent, closable where permitted, and fit phone/compact desktop layouts.
- Existing v0.17.0 saves migrate/load without loss; all exported platforms remain at source parity.

## Validation

- `godot --headless --path . --script res://tests/overhaul_runner.gd`
- `godot --headless --path . --script res://tests/progression_audit.gd`
- `godot --headless --path . --script res://tests/ui_runner.gd`
- `godot --headless --path . --script res://tests/mobile_ui_runner.gd`
- Existing core/save/offline/first-lifetime suites used by `scripts/package_all_platforms.sh`
- `npm test` in `sites-host`
- `./scripts/verify_web_parity.sh`
- Local real-browser desktop, compact, and phone screenshots/interactions
- `./scripts/package_all_platforms.sh`
- GitHub Pages workflow, GitHub release assets, update manifest, and owner-only Sites deployment verification

## Progress

- [x] Re-read the applicable orchestration rules and completed v0.17.0 campaign ExecPlan.
- [x] Confirm a clean v0.17.0 baseline and collect two independent read-only diagnoses.
- [x] Reconcile the five-level expectation with the fixed 100-level topology.
- [x] Complete and accept M1 through a delegated Terra implementation milestone.
- [x] Complete and accept M2 through a delegated Terra implementation milestone.
- [x] Complete M3 primary integration, acceptance, packaging, and synchronized deployment.

### M1 accepted implementation and evidence

- Changed `scripts/campaign.gd`, `scripts/game_state.gd`, `scripts/pitch_field.gd`, `scripts/main.gd`, `scripts/content.gd`, `docs/DESIGN.md`, and focused progression/UI tests.
- GameState now remains authoritative when the renderer is between phases; PitchField retires visual volley IDs absent from the authoritative queue.
- Fresh Wiffle drag is `0.002/ft`, producing roughly 0.6% loss across 3 ft and a roughly 3.009-second opening flight.
- Regular numbered pitch drafts now occur every five levels. Off-cadence levels 33, 66, and 99 retain boss pitches; level 100 retains its final boss pitch, for 23 finite pitch drafts total.
- Passive interface refresh no longer opens saved choices. Next Level presents them and the final choice completes the requested transition; auto-advance cannot cross a queued mandatory reward.
- Independent Sol validation passed:
  - `overhaul_runner.gd`
  - `progression_audit.gd`
  - `ui_runner.gd -- --fresh`
  - `mobile_ui_runner.gd -- --fresh`
  - `git diff --check`

### M2 accepted implementation and evidence

- Added a dedicated three-slot New Game picker. Empty slots begin immediately; occupied slots use a slot-specific overwrite confirmation rather than typed global reset.
- Added serialized `active_campaign_slot` metadata. Loading or creating a campaign slot makes it active; every verified autosave mirrors into it while the universal autosave remains the recovery source. Global Reset detaches before clearing and leaves all manual campaign slots intact.
- Added compact build-subtitle composition (one strength class, optional compatible conditioning adjective, and correctly pluralized age noun) while retaining the complete modifier chain in detailed Body text.
- Applied reusable borderless navy modal styling, responsive clamping, and visible in-content headings to app-owned dialogs. Native file pickers remain native.
- Fixed a real-browser-only title picker layout defect by removing flexible spacer consumption during slot selection, and added actual update-banner clearance above the title.
- Independent Sol validation passed `test_runner`, desktop UI, portrait UI, and `git diff --check`.
- Uncached local Web acceptance passed at 1280×720 and 390×844. Verified the title menu, new-game slot picker, fresh slot creation, Little Timmy/Scorebook story dialogs, opening −0.6% air drag, and a live flight resolving from its countdown back to the pitch cooldown without a persistent `0.0s` meter.

### M3 accepted integration and release evidence

- Bumped shared project, native executable, distribution, update-manifest, Sites adapter, README, and changelog metadata to v0.17.1 without changing save schema 28.
- The final `package_all_platforms.sh` run passed the core, desktop-interface, and portrait-interface suites; exported browser/PWA, Universal macOS, Windows x86_64/ARM64, and Linux x86_64/ARM64; smoke-launched the exported Mac app; verified every architecture, signature, DMG, ZIP, tar archive, and checksum; and produced a verified 206 MB all-platform bundle. Superseded local v0.17.0 release artifacts were pruned automatically.
- Final focused `overhaul_runner.gd` and `progression_audit.gd` runs passed. The progression audit reports 100 levels, 23 finite pitch drafts (five-level cadence plus authored off-cadence bosses), and unchanged 115 mph / Mach 5,000 / 5,000c physical anchors.
- `verify_web_parity.sh` passed. The Sites adapter rebuilt from the exact Web export and passed all four route, cache, and segmented-WebAssembly tests. The published Pages `index.pck` SHA-256 is `7e017b0f6739a33412d778d31ce3575393c8e1117810fe14116b8bbb6578bc5c`, matching the packaged Sites stamp.
- GitHub Pages workflow run `32445309837` completed successfully from `a56c2dc`. The live Pages and authenticated owner-only Sites manifests both report v0.17.1 and the matching five native download URLs.
- GitHub release `v0.17.1` contains the verified browser, macOS, Windows x86_64/ARM64, Linux x86_64/ARM64, release-manifest, and SHA256SUMS assets. Owner-only Sites version 31 saved the tested 88-file archive and its production deployment completed successfully without changing access policy.

## Exact next action

Release complete. Preserve v0.17.0 and Sites version 30 as rollback points; begin later feedback from the clean, published v0.17.1 baseline.
