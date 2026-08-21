# No Hitter Remote-Update Test and Complete Title Loop — Execution Plan

## Status

M1 is implemented, reviewed, corrected, and accepted. Before its publication step, a broader feedback batch arrived; the accepted work and evidence are now integrated into `docs/execplans/content-progression-navigation-pass.md` for one synchronized source revision and publication pipeline.

## Goal

Make two unresolved testing notes concrete:

1. Provide a save-safe macOS workflow that exercises the installed game's real remote update channel against the official published manifest and download, without needing to wait for an actually obsolete local build.
2. Replace the title art's perpetually outbound, disconnected ball motion with a complete and readable baseball interaction: windup, release, outbound pitch, coordinated swing/contact, batted return, and reset.

## Requirements

### Remote installation/update test workflow

- The ordinary installed build must continue checking the official Pages manifest and selecting only official GitHub release downloads.
- Add an explicit macOS test entry point that launches a local or installed `No Hitter.app` in a forced-outdated update-test session.
- Update-test mode must check the real official manifest immediately and compare it against an intentionally old test version, so the current published update prompt can be exercised on demand.
- The prompt must clearly identify the session as an update test, show the installed/test and available versions, explain that saves live outside the app, and open the real official macOS DMG when Download is chosen.
- The test session must never write, reset, migrate, or overwrite the player's actual save data. It may reset only its in-memory state after startup and must clearly indicate that play in the test session is not saved.
- The helper must find a reasonable installed/local app path, print an actionable error if none exists, and support a dry-run or equivalent inspectable mode. It must not mount a DMG, overwrite an installed app, delete files, or request administrator access.
- Document the human test sequence: launch test mode, observe the remote prompt, download the official DMG, quit the test session, install the replacement normally, and verify the external save remains available.

### Complete animated title interaction

- Preserve the existing progressive, non-spoiler visual eras. Fresh human saves must not reveal alien, eldritch, or divine imagery.
- Use a deterministic repeating phase model with distinct windup, outbound pitch, contact, return flight, and reset/rest intervals.
- Coordinate the pitcher arm and batter swing with release/contact instead of using independent ambient sine motion.
- Show a visible contact cue and a batted ball traveling away from the batter before the loop resets. The ball must not teleport at the plate or imply a pitch with no result.
- Higher unlocked eras may show additional arms/projectiles and larger arcs, but the interaction must remain legible. Their outbound trajectories should be distinct; the return portion may resolve into one or several stylized batted paths.
- Keep the composition responsive at the existing desktop and 390×844 title sizes.
- Expose enough deterministic animation-state information for focused tests to assert all phases without relying only on screenshots.

## Constraints and non-goals

- This iteration does not implement silent self-replacement of a running macOS app. The current ad-hoc-signed, non-notarized DMG distribution requires an explicit normal replacement install.
- Do not weaken the official GitHub release URL allowlist or fetch an arbitrary manifest supplied by a command-line argument.
- Do not touch save schema or gameplay balance.
- Do not reveal locked campaign tiers through title visuals or update copy.
- Do not bump the release version, rebuild all native platforms, create a GitHub release, or deploy Sites for this ordinary feedback iteration.
- Validation defaults to focused Godot tests, one exact Web export, real-browser acceptance, and GitHub Pages.

## Relevant repository state and discoveries

- `scripts/main.gd` already checks `https://dcr-cmyk648.github.io/One-Foot-Per-Second/update-manifest.json` after three seconds and every five minutes in native non-development sessions.
- The native updater already rejects downloads outside the official GitHub releases prefix, saves before opening the release URL, and explains that save data is external to the app.
- Development arguments are currently applied after initial save loading, and `GameState.load_game()` may itself write when repairing a newer backup/pending generation. The test flag must therefore be detected before `load_game()` and bypass persistent loading/recovery entirely; merely setting `development_session` afterward is not save-safe.
- Before M1, `scripts/title_art.gd` looped projectiles from pitcher to batter with `fmod()` and animated limbs independently. M1 replaced that with the accepted five-phase interaction described below.
- Desktop and phone title geometry already have focused coverage in `tests/ui_runner.gd` and `tests/mobile_ui_runner.gd`.
- v0.17.2 is the current official manifest/release version. This work begins from the clean published source baseline.
- Parallel Godot processes collide in this local environment before test code executes. Primary acceptance must run Godot suites sequentially with distinct `/private/tmp` log files; this is harness/process isolation, not a product failure.

## Decisions

1. The remote workflow is an acceptance/test mode for the real production update path, not a second updater. It uses the official manifest and official platform URL selection unchanged.
2. The test reports an intentionally old local version through a fixed internal test override. Users cannot redirect it to another server or arbitrary download.
3. Test mode is read-safe and write-disabled. It may load enough application state to initialize normally, then replaces only in-memory gameplay state and never calls save/export automatically.
4. The macOS helper is a launcher, not an installer. The replacement step remains visible and reversible through the downloaded DMG.
5. Title animation uses named deterministic phases. Rendering derives arm, bat, ball, contact, and return positions from the same phase clock so the story of the loop is visually coherent.

## Milestones

### M1 — Delegated implementation and focused regressions

- Implement the complete title phase model and coordinated drawing in `scripts/title_art.gd`.
- Add save-safe forced-outdated native update-test mode to `scripts/main.gd`.
- Add a macOS launcher/test helper under `scripts/` and concise README instructions.
- Extend focused desktop/mobile tests for phase completeness, spoiler gates, update-test safety/copy, and responsive title geometry.
- Run focused UI suites and `git diff --check`.

### M2 — Sol review, browser acceptance, and Pages

- Inspect the actual implementation diff and worker evidence; resolve only cross-feature/product issues in Sol.
- Run one targeted primary desktop/mobile acceptance pass.
- Exercise the helper in dry-run mode and, if a local `.app` exists, verify the forced update prompt without installing or overwriting anything.
- Export Web exactly once after source acceptance; verify parity and inspect the title loop in a real desktop and phone browser viewport.
- Commit and push the accepted source/Web artifact to `main` for GitHub Pages, then verify the deployed artifact. Do not create native release assets or deploy Sites.

## Acceptance criteria

- A forced test launch of the current macOS app promptly offers the currently published official release as an update without modifying the player's save.
- The update test cannot select a nonofficial manifest or download and does not install/replace anything automatically.
- The helper gives a clear command/result on a developer Mac and supports non-mutating inspection.
- Human title art visibly performs release, pitch, swing/contact, and batted return before resetting.
- Alien/eldritch/divine title variants retain spoiler gating and use distinct multi-projectile motion without becoming an incoherent particle loop.
- Desktop and phone title layouts remain in-frame and readable.
- Focused Godot suites, Web parity, browser acceptance, and Pages deployment pass.

## Validation

- `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/ui_runner.gd -- --fresh`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/mobile_ui_runner.gd -- --fresh`
- Focused update-test assertions added to the existing UI runner or a small dedicated runner
- macOS helper dry-run plus safe forced-prompt smoke when a local app is available
- `git diff --check`
- `./scripts/package_web.sh`
- `./scripts/verify_web_parity.sh`
- Real-browser title-loop acceptance at desktop and 390×844
- GitHub Pages workflow and deployed artifact verification

## Progress

- [x] Re-read the completed v0.17.2 phase ledger after compaction.
- [x] Inspected the existing native update channel, title-art implementation, and focused title/update tests.
- [x] Recorded product decisions, non-goals, acceptance criteria, and release scope for this feedback batch.
- [x] Complete and accept M1 through one delegated Terra milestone.
- [ ] Complete M2 primary review, one Web export, browser acceptance, and Pages deployment.

### M1 accepted implementation and evidence

- Added a deterministic five-phase title animation: visible windup, outbound pitch, coordinated contact/swing burst, batted return into the field, and reset/rest. Pitcher arm, batter bat, balls, trails, and later-era distinct arcs all derive from the same state clock.
- Added fixed `--native-update-test` startup detection before persistent loading. The test session bypasses `load_game()` and recovery entirely, creates only fresh in-memory state, enables development-session guards, and write-locks GameState for the session.
- The real production manifest URL and official GitHub release allowlist remain unchanged. Test copy identifies the forced version and official candidate, explains volatile play/external saves, and hides the unavailable backup action.
- Added executable `scripts/launch_native_update_test.sh`. It locates a local/installed app, supports `--app` and `--dry-run`, prints the exact invocation, and passes Godot's required `--` user-argument separator. It never installs or mutates application/save data.
- Added focused title/update assertions to desktop and phone UI tests plus a dedicated native startup runner, and documented the manual macOS workflow in README.
- Delegated validation passed desktop UI, mobile UI, native update startup, helper syntax/dry-run, and diff checks. Sol inspected the full diff, caught and corrected the launch separator, return direction, static windup, and test-only backup control, then independently passed all three Godot runners sequentially plus helper/diff checks.

## Exact next action

Continue from `docs/execplans/content-progression-navigation-pass.md`. Do not repeat the already accepted title/update implementation or unchanged-save-hash smoke unless a relevant later edit invalidates it.
