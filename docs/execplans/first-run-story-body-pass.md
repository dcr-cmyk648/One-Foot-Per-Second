# No Hitter First-Run Story, Aging, and Achievement Pass — Execution Plan

## Status

M1 and M2 are implemented and accepted from the clean published v0.17.1 baseline. M3 integration, exact-build browser acceptance, and packaging have passed; synchronized publication and live verification remain.

## Goal

Make a fresh human run feel like a narrated baseball life rather than an unexplained sequence of opponents: open with an immediate story scene, announce every authored human sub-era on first discovery, make aging rewards legible and normally attainable by the human finale, default one-time catalogs to hiding owned entries, and expand the achievement catalog around the new campaign and draft systems.

## Requirements

### First-run story

- Starting a genuinely fresh campaign slot must immediately present a non-spoiler opening story dialog before ordinary play is allowed to feel unexplained.
- The opening establishes the core joke: a toddler, a Wiffle Ball, three feet of distance, and a one-foot-per-second first pitch.
- Each of the eleven authored human sub-eras must have a distinct arrival blurb the first time it is reached: Preschool Backyard, Tee-Ball, Coach Pitch, Little League, Middle School, High School, Community College & D-III, Division I, Lower Minors, Upper Minors, and Major Leagues.
- Story dialogs remain recorded in STORY and are not repeatedly forced once their IDs have been seen. Existing special-contact, boss, rebirth, and cosmic story beats remain intact.
- Story arrival must occur at the actual transition boundary, after any mandatory clear rewards are resolved and as the next level is entered.

### Catalog defaults and aging clarity

- Fresh campaigns default **Hide Purchased** on for Pitch, Ball, Facility, and Body catalogs.
- Explicit existing save preferences remain authoritative; a player who turned a filter off must not have it silently turned back on by migration.
- An age card must show the exact incremental Speed, Quality, Recovery, and visual Size change granted by that age step. The detailed Body history must retain the same readable effect information after selection.
- Aging remains an optional sequential run draft. A player may decline age cards and preserve the toddler challenge.

### Aging availability and balance

- Add explicit “normal by” timing metadata to the six sequential human age cards.
- The next valid age card gains selection weight as it becomes overdue. Sampling remains deterministic from the saved run seed/choice serial and is weighted without replacement; reloading cannot reroll it.
- With the default two-card board and a policy of always choosing an offered next-age card, target roughly an 85–90% chance to be a full Regular Ol’ Guy by the level-33 human clear reward. It should be meaningfully likely, but not guaranteed, before facing the final human batter.
- Expanded Draft Board remains valuable and must improve the probability beyond the default board.
- Add an automated deterministic-seed audit of the real offer generator rather than relying on a simplified probability estimate.

### Achievements

- Add achievements without removing existing distinct achievements. Each continues to grant the established stacking +0.5% XP.
- Cover newly meaningful story discovery, sequential aging, adult-by-human-finale, deliberately remaining young, run drafts, pitch drafts, build combinations, boss rewards, and other funny interactions made possible by the campaign overhaul.
- Reuse durable metrics or generic achievement event totals where practical. Do not expose future genetic, eldritch, or divine information before its tier/reveal rules allow it.
- Secret challenge achievements reveal no identifying information until earned.

## Constraints and non-goals

- Do not change the 33/33/33+1 finite campaign topology, five-level pitch-draft cadence, opponent order, or prestige reset rules.
- Do not turn aging into an XP purchase or a mandatory automatic transition.
- Do not invalidate v0.17.1 saves or increase the save schema unless a truly new serialized field is required; generic event totals and definition metadata should be preferred.
- Do not replay every human story blurb on every rebirth. The first lifetime is the required narrative path.
- Browser, PWA, and native builds continue to share one authoritative gameplay/content source.

## Relevant repository state and discoveries

- `scripts/campaign.gd` authors eleven human sub-eras of three opponents each and stores `story_key` on the first opponent, but built descriptors do not expose `subera_start` even though `GameState._record_campaign_clear_story()` checks it. The check therefore returns before recording any ordinary league-up story.
- `scripts/run_content.gd::STORY_BEATS` has only a few broad human beats; most generated `arrive_<subera_id>` keys have no authored definition. The fallback body in `_record_campaign_clear_story()` is generic even if its guard is repaired.
- `GameState.reset_fresh()` queues `prologue_little_timmy` and `story_tab_explained`, and `Main._start_fresh_title_game()` defers `_maybe_show_pending_overlay()` after leaving the title. The user nevertheless observed no opening dialog, so the slot-start path needs an explicit regression using the real deferred title transition.
- `catalog_hide_purchased` defaults and missing-save fallbacks are currently false for every catalog.
- `_run_effect_text()` renders any age effect as only `Body age advances`; the old granular body stages already contain the underlying incremental Speed, Quality, Recovery, and absolute visual-size values. Draft ages map to legacy stages through `AGE_TO_STAGE = [0, 2, 4, 5, 7, 9, 11]`.
- The draft generator uniformly samples eligible perk definitions. Sequential aging only makes the next age card eligible; no definition weights or overdue timing exist. Current exact default-board chance to reach full adulthood by the level-33 reward is 28.9425% when every offered age card is selected.
- The pre-pass achievement catalog contains 140 entries and its metric layer already supports body age, levels, pitch count, selected run-perk/pitch events, prestige upgrades, and generic durable event counters.

## Decisions

1. “Every league up” means each authored human sub-era transition, not every individual batter. This gives eleven distinct first-lifetime chapters without interrupting all 33 opponents.
2. The prologue is a queued, journaled story beat, not title-screen flavor text. A fresh slot must visibly present it through the same dark responsive story modal used later.
3. Age probability is increased through overdue definition weight, not by forcing an age card or adding a separate slot. The challenge of intentionally remaining a toddler survives.
4. Age effect copy is derived from the same mapped body-stage data used by gameplay, so displayed bonuses cannot drift from the actual effect.
5. Existing explicit filter choices are preserved; only fresh/missing values default to true.
6. Achievement growth is additive. New entries should describe genuinely distinct actions, builds, or campaign moments rather than inserting arbitrary near-duplicate quantity thresholds.

## Milestones

### M1 — First-run narrative, catalog defaults, and age-card clarity

- Author distinct prologue and all eleven human sub-era arrival beats.
- Repair sub-era transition detection and ensure the correct story queues when the requested next level is actually entered.
- Make fresh-slot start visibly present the prologue and retain STORY journal behavior.
- Default all one-time catalog Hide Purchased toggles on for fresh/missing preferences while preserving explicit saved values.
- Add a shared exact age-step bonus summary and use it in draft cards and selected Body history.
- Add focused core/UI/phone regressions for story order, fresh title-slot entry, filter persistence/defaults, and exact age effect text.

### M2 — Weighted aging and achievement expansion

- Add normal-timing metadata and deterministic weighted-without-replacement sampling for draft definitions.
- Tune and audit the real default-board sampler to the 85–90% full-adult-by-human-finale target, with a higher Expanded Draft Board result.
- Add a substantial set of distinct achievements around story progression, age/build/run-draft systems, preserving spoiler gating and every existing achievement.
- Add metric/event hooks and focused save/migration/achievement tests only where needed.

### M3 — Primary integration, acceptance, parity, and release

- Review both delegated milestones’ actual diffs and test evidence; resolve any architecture or cross-feature issue in Sol.
- Run repository-wide gameplay, save/migration, progression, desktop UI, and portrait UI suites.
- Perform uncached local browser acceptance at desktop and 390×844: fresh slot → prologue, first sub-era transition, age-card details, default filters, achievement browser.
- Bump the synchronized app version, package/archive-verify all native and browser targets, verify Web parity and update metadata, then publish GitHub Pages/release assets and owner-only Sites without automatically opening hosted pages.

## Acceptance criteria

- A fresh slot presents the opening story dialog immediately and records it in STORY.
- Entering each new human sub-era on the first lifetime presents unique authored copy exactly once; Coach Pitch/Youth Baseball can no longer arrive silently.
- Fresh Hide Purchased toggles are on. A saved explicit false remains false after reload.
- Every age offer and selected age entry states its actual Speed, Quality, Recovery, and Size improvement.
- The real deterministic two-card sampler lands between 85% and 90% full-adult completion by the level-33 reward under the always-select-age policy; a three-card board is higher.
- Remaining a toddler is still possible by declining age cards and the existing toddler human-champion achievement remains valid.
- The achievement catalog grows beyond 130 without deleting distinct old achievements, without duplicate IDs, and with correct spoiler/secret behavior.
- Existing v0.17.1 saves load without loss; all exported platforms remain at source parity.

## Validation

- `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/test_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/overhaul_runner.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/progression_audit.gd`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/ui_runner.gd -- --fresh`
- `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/mobile_ui_runner.gd -- --fresh`
- New deterministic draft-probability/achievement audit using the authoritative `create_perk_choice()` path
- `git diff --check`
- `npm test` in `sites-host`
- `./scripts/verify_web_parity.sh`
- Local real-browser desktop and phone acceptance
- `./scripts/package_all_platforms.sh`
- GitHub Pages workflow, GitHub release assets/update manifest, and owner-only Sites deployment verification

## Progress

- [x] Confirmed the clean published v0.17.1 baseline and reread the applicable orchestration rules.
- [x] Diagnosed the missing sub-era guard, intro path, false filter defaults, generic age-card copy, uniform draft sampling, and available achievement metrics.
- [x] Defined product decisions and measurable adulthood target.
- [x] Complete and accept M1 through one delegated Terra implementation milestone.
- [x] Complete and accept M2 through one delegated Terra implementation milestone.
- [ ] Complete M3 primary integration, browser acceptance, packaging, and synchronized deployment.

### M1 accepted implementation and evidence

- Added a prologue identity for the initial Preschool chapter and authored distinct arrival copy for every later human sub-era.
- Added the missing `subera_start` descriptor and moved ordinary chapter recording to successful forward level entry. Clearing/farming the previous opponent stays quiet; resolving rewards and entering the next chapter queues its story exactly once. Boss and special-contact clear stories keep their authored timing, and auto-advance uses the same entry path.
- Fresh title slots visibly present `THREE FEET OF DESTINY` through the real deferred story modal and retain it in STORY.
- Fresh or missing catalog-filter preferences default true; explicitly saved false values survive load.
- Age-step copy is derived from the same mapped `BODY_GROWTH_STAGES` used by live gameplay and states exact Speed, Quality, Recovery, and Size changes on draft cards and selected Body history.
- Delegated tests passed `overhaul_runner`, desktop UI, mobile UI, and `git diff --check`. Independent Sol review inspected the complete diff and independently passed `overhaul_runner` plus `ui_runner -- --fresh`.

### M2 accepted implementation and evidence

- Added `normal_by_level` milestones 4, 8, 13, 18, 24, and 30 to the six sequential age cards.
- Perk selection is now deterministic weighted-without-replacement. Every non-age definition retains weight `1`; the next valid age has `1 + 0.15 × overdue × (overdue + 1)`, where overdue is the number of source levels beyond its normal milestone. No card is forced or reserved, and serialized offers remain reload-proof.
- The authoritative 1,024-seed audit uses real queued level rewards, including five-level pitch choices and their serial consumption. It measures:
  - default two-card board: `87.5977%` full adult by the level-33 reward;
  - default board before facing the final human: `74.2188%`;
  - Expanded Draft Board rank 1: `97.2656%` by the level-33 reward.
- Corrected the existing Puberty achievement to Teen age order 4 and added 25 distinct achievements without removing any of the frozen 140 old IDs. The catalog now has 165 entries covering run perks, pitch drafts, all age milestones, body builds/combinations, human story chapters, adult/late/declined aging challenges, legendary perks, pitch specialization, and boss pitches.
- New moment-specific facts use already-serialized generic event totals; other achievements derive from saved stories, perks, adjectives, and pitch levels. Save schema remains 28.
- Delegated validation passed the focused audit halves, core/overhaul/progression suites, desktop UI, portrait UI, and `git diff --check`. Independent Sol review inspected the full diff and independently passed the exact 1,024-seed audit, core/progression, corrected desktop UI, portrait UI, and diff checks.

### M3 integration and acceptance evidence

- Synchronized release metadata is staged at v0.17.2 with save schema 28 retained. README, Help, Design, and Changelog now describe five-level pitch drafts, overdue aging, exact age bonuses, first-run chapters, and the 165-achievement catalog.
- Fixed `package_all_platforms.sh` to stamp release metadata before the browser export. This prevents the desktop packager's final `export_presets.cfg` stamp from making the already-built Pages source fingerprint stale.
- `package_all_platforms.sh` completed twice, with the corrected final run passing core, desktop UI, and portrait UI suites; exporting and validating macOS Universal, Windows x86_64/ARM64, Linux x86_64/ARM64, source, browser, desktop bundle, and all-platform bundle archives; and retaining only v0.17.2 artifacts.
- `verify_web_parity.sh` passes against the final source tree. The Sites adapter builds from the same PCK (`985bc2789c7d25e586ebd81892eb8cfd0187831565af8e90dd075b664cf76a1c`) and all four rendered-host tests pass.
- Tested the exact exported WebAssembly build through a temporary localhost server at 1280×720 and 390×844. Desktop and phone fresh-campaign pickers keep every slot action and Back control in-frame; an empty slot starts without typed reset; `THREE FEET OF DESTINY` is immediately visible and readable; the opening profile shows 1 ft/s, 3 ft, and −0.6% atmospheric drag; the Facility catalog starts with Hide Purchased enabled; and no browser warnings/errors appeared.

## Exact next action

Publish the accepted v0.17.2 tree and verified assets, verify the GitHub Pages workflow/release and owner-only Sites version without opening either hosted page, record immutable release identifiers here, and perform the final Sol acceptance review.
