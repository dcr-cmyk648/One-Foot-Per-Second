# No Hitter Story Workbook, Campaign Stakes, and Balance Pass — Execution Plan

## Status

M1, M2, and M3 are accepted. The story workbook covers all 37 runtime/journal and special-dialog beats, preserves every supplied prose passage verbatim, provides a machine-recognizable pending-beat template, and enforces exact workbook/runtime draft parity. The campaign now forms one causal mortal/alien/eldritch arc. Human, alien, and eldritch enhancements and gear are mechanically distinct; Mastery and Determination have explicit retuned contracts; and XP/second is a spoiler-safe genetic convenience unlock with fair legacy migration. Mobile detail surfaces use a fixed-heading/action and bounded-body contract, Body no longer carries a hidden filter, action achievements use live-only counters, and the exact original Little Timmy cap can support a fair reality-long challenge through earned retention. The first v0.20.0 release candidate `d022dd0` correctly stopped before publication because two broad-suite assertions still described the superseded v0.19 Determination curve; no accepted artifacts or destinations changed. Those two assertions now match the accepted six-point/+0.140 contract and the focused `overhaul_runner` passes. v0.19.0 remains the rollback release. M4 will continue from the corrected source revision. The user-owned untracked root `AGENTS.md` must not be modified or staged.

## Goal

Create a durable, directly editable story-beat workbook that preserves Dustin's prose verbatim and pairs it with the current game draft, then use that source to strengthen the campaign's escalation from obsessive backyard baseball through alien conquest and reality-tearing eldritch baseball. In the same release, make steroids and post-human gear mechanically distinct, refine Mastery and Determination, move the XP/second estimator behind prestige, repair mobile detail dialogs, simplify the Body catalog, and add the requested challenge achievements.

## Requirements ledger

### Story authoring source of truth

- [x] Add `docs/writing/story-beats.md` containing every current story beat in chronological/trigger order, including prologue, league arrivals, equipment unlock, prestige transitions, alien commissioner sequence, eldritch transition, and divine ending.
- [x] Every beat has a stable beat ID, exact trigger/ordering note, tier, direction, a clearly marked **PLAYER PROSE SEED — EDIT THIS** block, and a separate **CURRENT GAME DRAFT — CODEX-MANAGED** block.
- [x] Copy all supplied prose from `docs/writing/story-voice-seed.md` into the appropriate Player Prose Seed blocks verbatim. Never silently polish, shorten, or overwrite those blocks.
- [x] Preserve `docs/writing/story-voice-seed.md` as the high-level voice guide, but make the workbook the durable per-beat authoring source that future agents must read before story changes.
- [x] Include a machine-recognizable `NEW BEAT` template. The user can add a stable ID, trigger, placement, direction, and prose seed; the generated/runtime block remains explicitly pending until implemented.
- [x] Add a focused audit that ensures every runtime beat has exactly one workbook entry, stable IDs are unique, required fields exist, and Player Prose Seed content is not accidentally dropped during ordinary synchronization. Markdown is editorial input and is not parsed at game runtime.
- [x] Record prose, directions, and new-beat requests as durable workbook entries rather than relying on conversation history.

### Campaign story and voice

- [x] Preserve the user's prose closely. Generated drafts may bridge mechanics or established direction, but must not unnecessarily rewrite the seed.
- [x] Reduce repeated use of “apparently” across player-facing copy; keep it only where it is the strongest joke.
- [x] Use the recurring joke `alien (Earth thing)` and `eldritch (ordinary thing)` selectively in names, equipment, facilities, opponents, and/or story, alongside genuinely unique post-human content.
- [x] Foreshadow in the upper human leagues that something about the competition is suspicious and that the player's baseball obsession may be an echo of an earlier destroyed/restarted reality.
- [x] Establish that aliens settle all conflicts through baseball. Their human-esque champion is part of an Earth-conquest bracket; after that champion falls, Commissioner Xylophax demonstrates impossible superiority and declares Earth lost by baseball law.
- [x] Establish that the player's escalating baseball power tears open or attracts attention across reality, drawing the elder baseball gods and causing the eldritch campaign rather than presenting it as an unrelated league.
- [x] Keep baseball literally central to multiversal law and survival, with sincere overdramatic narration landing on mundane sports/school/bureaucracy jokes.

### Gameplay balance and progression

- [x] Human steroids receive a meaningfully larger upside than v0.19.0 and at least one understandable physical downside, such as longer recovery/windup. Copy shows exact numbers.
- [x] Add or revise alien steroid-equivalent body enhancement(s) with strong benefits and no downside.
- [x] Add or revise eldritch steroid-equivalent enhancement(s) with enormous benefits and large, intentionally strange downsides. All effects remain authoritative, visible, and save-safe.
- [x] Alien and eldritch equipment tiers roll stronger affixes than human gear, while preserving human pacing and making tier escalation visible in Power/comparison text. Do not make ordinary human gear retroactively absurd.
- [x] Moderately reduce Mastery earned from non-strikeout/non-called-Strike sources without weakening the core guarantee that every online called Strike contributes. Preserve offline-efficiency scaling and clear UI copy.
- [x] Increase Determination's practical peak proportionally to the slower non-strike Mastery support so its comeback role becomes stronger without making ordinary tap spam dominant.
- [x] Move the XP/second estimator behind a first-prestige genetic upgrade. Before the layer is discovered, do not spoil it; after discovery, show the locked upgrade, exact effect, and unlocked estimator. Save migration must be explicit and fair.
- [x] The Body catalog no longer shows a Hide Purchased toggle. Body history/current build remains inspectable and purchased one-time body options are presented coherently.

### Mobile and achievement behavior

- [x] Every long-press explanation/detail surface uses the established bounded-scroll contract: the body scrolls, while the title, Close control, and essential action remain visible at 390×844 and 360×700.
- [x] Audit tall mobile inspection dialogs, not only equipment, and add a regression that a deliberately long explanation cannot move Close off-screen or trap the player.
- [x] Audit action/count achievements so offline simulation cannot unlock achievements for pitches, Strikes, strikeouts, hits saved, volleys, or equivalent player-action counts. Non-action milestone/story/prestige achievements may still resolve from authoritative state.
- [x] Keep the existing `human_champion_toddler` achievement (“Complete the entire human league without growing up”); do not add a duplicate.
- [x] Add a secret challenge achievement for completing the entire game without taking off Little Timmy's original hat. Define and persist a fair continuity contract: the tracked original hat must remain equipped through progression and prestige; automatic loss/reset counts as breaking the run unless an earned retention mechanic preserves that exact item.
- [x] Check the final catalog for semantic duplicate achievements and retain the funnier version when two rewards describe substantially the same accomplishment.

## Product decisions

- The workbook will be repository Markdown, so it is directly editable, diffable, portable, and available to future coding agents. Runtime copy remains authored in GDScript; a focused audit prevents drift rather than parsing prose Markdown at runtime.
- Player Prose Seed blocks are user-owned text. Future implementation may update trigger metadata, direction, and Current Game Draft, but must preserve those blocks exactly unless the user edits them.
- A new beat is indicated by copying the `NEW BEAT` template and setting `Status: NEW`. A pending new beat may intentionally have no runtime implementation; the audit must distinguish declared pending entries from implemented entries.
- “Without taking off Little Timmy's hat” tracks the specific first Little Timmy hat item, not merely any hat with the same name. This makes retention/prestige mechanics part of the challenge.
- XP/second is a convenience estimator, not an income modifier. The genetic upgrade reveals the existing calculation; it does not alter XP production.
- Determination tuning should change its payoff curve, not impose a hidden hard cap. Existing logarithmic/uncapped philosophy remains unless repository mechanics prove a visible capped meter is authoritative.
- Human, alien, and eldritch steroid/gear tuning must use existing stat semantics (release snapshot immutability, recovery direction, physical drag, etc.) and show exact pros/cons.

## Constraints and non-goals

- Preserve the 100-level campaign, strikeout-only XP, five-level pitch-draft cadence, story spoiler gating, released-ball immutability, and v0.19.0 save compatibility.
- Do not parse or ship the Markdown workbook as live game data.
- Do not invent a cloud authoring dependency; the repository document is the durable source for this phase.
- Do not flatten post-human content into only Earth-object jokes; use those as recurring punctuation among unique alien/eldritch material.
- Do not grant action achievements from offline/catch-up simulation merely because lifetime totals increased.
- Do not show undiscovered prestige concepts before their layer is revealed.
- Do not stage or modify the untracked user-owned `AGENTS.md`.
- Local Godot suites remain sequential because concurrent instances collide in shared engine state.
- Publish only after one accepted v0.20.0 source revision. Standing approval covers the established GitHub Pages, owner-only Sites, GitHub release/update assets, and supported browser/native artifacts.

## Repository state and discoveries

- Base release is v0.19.0. Release completion commit is `be13cc9`; accepted gameplay source is `90603e2`; artifact commit is `6d9293e`.
- Existing prose seed: `docs/writing/story-voice-seed.md`. Runtime story catalog: `scripts/run_content.gd::STORY_BEATS`; additional special encounter copy exists in `scripts/main.gd` and must be inventoried.
- `scripts/content.gd` already contains the toddler human-league achievement under ID `human_champion_toddler`; the new request must not duplicate it.
- v0.19.0 added `live_action_achievement_totals`; this phase must audit remaining action metrics and offline paths rather than replacing lifetime statistics wholesale.
- Human `steroids` currently gives Speed ×1.10 and Recovery ×1.025 with no downside. Post-human body/facility catalogs and equipment generation need focused discovery before exact values are chosen.
- The XP/second estimate is currently calculated and displayed unconditionally in `scripts/main.gd`; the new prestige unlock must own both visibility and help/status explanation.
- Long mobile details already have `_bounded_detail_scroll`; the defect implies one or more long-press surfaces bypass or incorrectly size that contract.
- The Body catalog still participates in `catalog_hide_purchased_toggles`; remove only the Body toggle without breaking other per-tab filters.
- M1 inventory found 33 journal/catalog beats plus four special dialog beats. The special dialog copy is now centralized in `RunContent.STORY_BEATS`; `{{DNA_AWARD}}` is the one documented runtime interpolation token.
- `docs/writing/story-beats.md` is now the per-beat source: implemented beats expose only their Player Prose Seed for user editing, while the NEW template asks for ID/trigger/direction/seed. The audit requires exact managed-draft/runtime parity and all original seed anchors.
- `endless_unlocked` now uses its centralized catalog draft instead of a GameState override. This is a copy centralization only; its trigger is unchanged.
- M2 exact enhancement contracts: human Steroids grant Speed ×1.45 and Payload ×1.15 but Recovery ×0.82 (windup ×1.22); Xenobiotic Overclock grants Speed ×4, Recovery ×2, Payload ×5 with no downside; Recursive Muscle Geometry grants Speed ×50, Payload ×100, Recovery ×0.15 (windup ×6.67) and a visible size increase.
- New ordinary equipment stores affix tier 1/3/12 for human/alien/eldritch generation. Raw affixes and per-stat effective clothing caps scale by that equipped contributing tier; a human-only wardrobe remains at the human cap, and legacy missing metadata migrates to tier 1.
- Mastery now grants 0.70× base Mastery per called Strike plus 0.80× on completed strikeout. Every called Strike stays positive; sticky-boss lookahead includes the full eventual strikeout. Determination uses a six-point reference, +0.140 Quality per doubling, and exact 12/8/5/3/1/0.2/0.1/0 outcome points (displayed ×1,000).
- `scoreboard_calculus` is a one-DNA genetic visibility upgrade. Fresh/undiscovered/discovered-unbought saves hide both header and Status estimates. Progressed pre-v32 genetic saves retain their previously unconditional estimator access.
- Release attempt at accepted source `d022dd0` invoked `scripts/package_all_platforms.sh` once in clean worktree `/private/tmp/ofps-v0200-release` and stopped in `tests/overhaul_runner.gd` before native exports/publication. Lines 117/119 still asserted the older 9.6-point / four-point / +0.092 Determination contract, while accepted M2 and its focused runner correctly require 12 points, a six-point reference, and +0.140 per doubling. The partial Web PCK hash `7103cc87…` is rejected and must not be reused.

## Milestones

### M1 — Story workbook and campaign narrative

- Inventory every runtime and special story beat, map it to an exact trigger, and build the complete chronological workbook plus `NEW BEAT` template.
- Preserve all user prose verbatim in Player Prose Seed blocks and pair it with the current/generated game draft.
- Implement the suspicious upper-human, alien conquest/baseball law, prior-cycle echo, and reality-tear/elder-god causal arc.
- Add selective alien/Earth and eldritch/ordinary-object jokes and reduce “apparently” repetition.
- Add workbook coverage, trigger, ordering, text-integrity, and story-once tests.

### M2 — Steroids, post-human gear, Mastery/Determination, and XP estimator prestige

- Discover authoritative stat directions and existing genetic/eldritch catalogs.
- Implement tier-distinct steroids/body enhancements and stronger post-human equipment affixes with exact displayed effects.
- Retune non-core Mastery sources and Determination peak with focused numeric contracts.
- Add and migrate the genetic XP/second estimator unlock with spoiler-safe UI state.
- Add focused save, balance, release-snapshot, and progression tests.

### M3 — Mobile detail safety, Body catalog, and achievements

- Apply the bounded-scroll pattern to every affected long-press/detail dialog and validate two phone geometries.
- Remove the Body Hide Purchased toggle while preserving body history/current build.
- Complete the online-only action-achievement audit.
- Implement the original Little Timmy hat continuity challenge and remove semantic achievement duplicates if found.
- Run focused desktop/mobile UI and achievement/save tests.

### M4 — Sol integration and synchronized v0.20.0 release

- Review each worker diff and evidence once, resolve cross-milestone conflicts, and run only invalidated/high-risk acceptance checks.
- Stamp v0.20.0/save metadata before the first export and identify one accepted source revision.
- Invoke the canonical deterministic all-platform publication pipeline once; reuse exact artifacts for Pages, GitHub Release/update metadata, supported native/browser downloads, and owner-only Sites.
- Record aggregate artifact hashes, run IDs, deployment IDs, and rollback state here.

## Acceptance criteria

- The workbook contains one implemented entry for every runtime story beat plus explicitly marked pending entries, with stable trigger metadata and all supplied prose preserved verbatim.
- A user can add a new beat by copying one template and editing only its Player Prose Seed/direction/trigger fields; the audit reports it as pending rather than corrupting runtime coverage.
- First-run story forms one causal arc: obsessive mortal rise → suspicious conquest bracket → alien baseball law and defeat → rebirth/alien victory → reality rupture → eldritch intervention.
- Steroid and gear effects are visibly and mechanically tier-distinct, save-safe, and do not mutate balls already released.
- Offline/action achievement separation is testable; offline simulation cannot award action-count achievements.
- XP/second is absent before discovery, purchasable as a genetic prestige convenience, and accurate immediately after purchase/load.
- Long mobile details remain closable and scrollable with oversized content at 390×844 and 360×700.
- The existing toddler human-league achievement remains unique, and the original-hat full-game challenge has deterministic continuity/save tests.
- One accepted v0.20.0 revision reaches every approved channel without rebuilding successful artifacts per destination.

## Validation ladder

### Focused milestone evidence

- Story workbook/runtime coverage and text-integrity audit
- Story progression/once/save runner for revised campaign beats
- Focused gameplay runner for enhancements, equipment tier scaling, Mastery/Determination, and XP-estimator unlock
- Achievement/save migration runner for live-only action metrics and original-hat continuity
- `tests/ui_runner.gd -- --fresh` and `tests/mobile_ui_runner.gd -- --fresh` only for affected UI milestones
- `git diff --check`

### Final accepted revision

- One cross-milestone save/story/UI integration smoke where worker evidence does not already cover the path
- Canonical all-platform release gate exactly once after metadata stamping
- Exact Web/native/source artifact parity and approved-destination verification

## Progress

- [x] Convert every Aug. 22 2:10 PM Bullet Journal note into a requirement.
- [x] Preserve v0.19.0 as rollback and identify the new phase boundary.
- [x] Complete and accept M1 through one Terra implementation worker.
- [x] Complete and accept M2 through one Terra implementation worker.
- [x] Complete and accept M3 through one Terra implementation worker.
- [ ] Complete M4 integration and synchronized v0.20.0 release.

## Exact next action

Create the corrected accepted source revision, then invoke one fresh canonical all-platform pipeline for that new revision. Reuse the exact successful artifacts across approved destinations and do not reuse or publish the rejected partial Web export from `d022dd0`.

## Accepted milestone evidence

- M1: `tests/story_name_audit.gd` PASS after review corrections; `tests/progression_audit.gd` PASS before the copy-only correction; `git diff --check` PASS. The audit covers 37 unique runtime beats, required workbook fields, exact draft parity, supplied-prose anchors, causal story anchors, text integrity, and once/save behavior for the changed established triggers.
- M2: `tests/campaign_balance_m2_runner.gd` PASS; `tests/ui_runner.gd -- --fresh` PASS; `git diff --check` PASS. Coverage includes enhancement math/save round-trip, 1/3/12 affix and effective-cap tiers, legacy gear neutrality, released-volley immutability, exact Mastery/Determination values and migration, threshold timing, and fresh/discovered/purchased/migrated XP-estimator UI states.
- M3: `tests/content_progression_navigation_runner.gd` PASS; `tests/ui_runner.gd -- --fresh` PASS; `tests/mobile_ui_runner.gd -- --fresh` PASS; `git diff --check` PASS. Coverage includes all action-achievement source classes, v33 migration, exact-item hat identity and save round-trip, level-one grace, unequip/replace/scrap invalidation, no-retention and Reverse Terminator prestige paths, new-reality attempts, offline-final refusal, witnessed level-100 completion, Body-filter removal, and bounded details at 390×844 and 360×700.
- M4 correction: `tests/overhaul_runner.gd` PASS after replacing only the two obsolete v0.19 Determination expectations with the accepted 12-point Grand Slam / six-point reference / +0.140 Quality contract.
