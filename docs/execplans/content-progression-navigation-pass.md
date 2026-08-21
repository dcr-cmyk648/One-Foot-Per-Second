# No Hitter Content, Progression, and Navigation Pass — Execution Plan

## Status

M1, M2, and M3 are accepted after primary diff and visual review. M1 has cumulative multi-axis ball profiles, exact Body-adjective copy, resolved-opponent mastery identity, persisted live-action achievement counters separated from true career statistics, source-gated volley feats, and exact ball delta/full-profile tooltips. M2 adds a durable authorial prose seed, rewrites the full first-run human story in the requested dramatic/absurd voice, preserves the player as pitcher in Coach Pitch, adds save-compatible once-only post-rebirth Middle School copy, strengthens the genetic/eldritch story anchors, and substantially expands deterministic names without changing boss signatures. M3 makes mobile Upgrades purchase-only in Train → Facility → Ball → Body order, adds a touch-safe Log hub, moves learned pitches into a scrollable Loadout Arsenal, and synchronizes live/title windup, release, contact, return, and retraction geometry. Focused M1/M2/M3 runners, `overhaul_runner`, `progression_audit`, desktop/390×844 UI suites, and `git diff --check` pass. M4 locked source commit `146ebc0` as v0.18.0 (save schema 30), ran the one all-platform pipeline successfully, and produced the exact Web/native/source artifacts now awaiting synchronized publication.

## Goal

Make the run systems clearer and more intentional: balls should create distinct physical/build choices rather than being a payload ladder; every perk must state exact effects; mastery must unlock the correct opponent on the exact completing strikeout; action achievements must represent live play; the game’s authored voice and name variety must improve; and mobile navigation must separate purchases from Log/Loadout information. At the same time, make the live and title pitchers visibly wind back and whip forward at the actual release moment.

## Requirements ledger

Every unresolved note is tracked here even when implemented in a later milestone.

### Mechanics and data

- [x] **Distinct ball profiles:** Ball upgrades may rotate among cumulative Payload, release Speed, Quality, and air-Drag improvements. They must not all be Payload upgrades.
- [x] **Concrete perk effects:** Every run-perk option, including Body adjective cards, must state the exact numerical benefit and any exact tradeoff applied by that generated card.
- [x] **Mastery completion invariant:**
  - If a non-strikeout raises mastery to at least the requirement, the opponent becomes ready but remains locked until the next completed strikeout.
  - If a completed strikeout itself raises mastery to at least the requirement, the next level unlocks immediately.
  - A delayed resolution must evaluate the same opponent whose mastery it credited; changing the currently displayed opponent cannot unlock the wrong level.
- [x] **Online action achievements:** Offline simulation continues granting its intended XP, mastery, loot, and other idle progress, but pitches/outcomes/strikeouts/volleys and similar action-count achievements only count live play. Offline catch-up must not emit achievement popups.
- [x] **Achievement deduplication:** Audit semantic predicates, not just names. When two visible achievements truly represent the same condition, retain the funnier one and preserve earned-save credit through an alias/migration. Keep genuinely distinct escalation thresholds and boss-specific feats.

### Writing, story, and names

- [x] **Durable authorial seed:** Store the user’s supplied prose and explicit voice rules in a repository writing source. Future narrative work must read and update that source; shipped strings remain authored code, not runtime Markdown parsing.
- [x] **Dramatic story pass:** Rewrite the prologue and every first-run human chapter in the user’s intimate, overdramatic setup → mundane baseball absurdity voice. Use the supplied Little Timmy, repeated-school, prestige, and cosmic-threat prose as primary seeds.
- [x] **Authored replay/cosmic seeds:** The first genetic rebirth uses the supplied “Was it all a dream?” / modified toddler / Little Timmy conquest scene; the first post-rebirth return to Middle School records the supplied Axe-body-spray-and-acne beat exactly once; Octathulhu’s contact copy explicitly states that the universe will be eaten unless the player wins at baseball.
- [x] **Coach Pitch perspective:** Coach Pitch remains a recognizable age/league label, but no story copy may claim the coach throws the player’s pitches. Frame the player as seizing/defending the mound in appropriately melodramatic terms.
- [x] **More names:** Expand human/alien/eldritch component pools and grammar forms, preserve boss signatures, and prevent obvious local repetition across consecutive generated batters without requiring nondeterministic rerolls.

### Interface and animation

- [x] **Upgrade order:** The purchasable navigator begins `TRAIN → FACILITY → BALL → BODY`, followed only by currently revealed prestige purchase sections. FACILITY is second and BALL third.
- [x] **Pitch Arsenal under Loadout:** PITCH is removed from the upgrade navigator. The existing Loadout Arsenal card opens the same read-only learned-pitch inspection on desktop and mobile.
- [x] **Mobile Log hub:** Mobile `LOG` becomes the home for `EVENTS`, `ACHIEVEMENTS`, `STORY`, `STATS`, and `HELP`. Those non-purchase views disappear from the mobile upgrade sequence, remain available in their existing desktop context, and are reachable from a touch-sized Log menu.
- [x] **Discoverability:** The opening Story explanation and Help copy explicitly say `LOG → STORY` / `LOG → HELP`; the mobile Log hub labels each destination clearly.
- [x] **Pitcher release animation:** On both the live field and title art, the pitcher’s short rectangular arm slowly moves from rest into a cocked-back pose, then whips forward quickly. The ball appears at the exact forward release pose; already released balls remain immutable and independent.

### Preserved prior milestone

- [x] Complete five-phase title interaction and save-safe native remote-update test workflow remain accepted in the working tree.
- [x] A local macOS forced-update smoke used the real official channel and left the autosave, backup, and both manual-slot hashes byte-for-byte unchanged.

## Constraints and non-goals

- Preserve the 33 human / 33 alien / 33 eldritch / 1 final-boss campaign topology, five-level ordinary pitch-draft cadence, prestige layers, and strikeout-only XP rule.
- Do not make ball ownership stack every historical shell. The current/highest shell is one cumulative profile; its row explains the exact change from the prior profile.
- Preserve existing ball IDs and purchased-ID saves. Optional profile fields default neutral for older data.
- Ball profile tuning may redistribute the existing progression curve, but must retain the established human/alien/eldritch endpoint anchors and must not make every intermediate shell a disguised payload step.
- Do not couple runtime exports to documentation files. `run_content.gd` remains authoritative shipped copy.
- Do not count offline-simulated action totals toward locked action achievements merely by delaying their popup until focus returns.
- Do not remove distinct threshold ladders or context-specific boss challenges under the label “duplicate.”
- Do not alter authoritative pitch timing/physics to animate the arm. Visual pose derives from cooldown/release state and preserves release snapshots.
- Preserve the accepted official-manifest allowlist and native update-test save isolation.
- Local Godot processes run sequentially because concurrent instances collide in shared engine state.

## Relevant repository state and discoveries

- The worktree contains accepted uncommitted changes for the remote-update/title loop plus a Web artifact generated before this new feedback. That Web artifact becomes stale as soon as this pass changes source and must not be published; the final deterministic pipeline replaces it once.
- `Content.BALL_UPGRADES` contains 26 replacement-shell IDs. `get_pitch_potency()` currently selects the maximum owned potency, so every row is a Payload multiplier. Saved ownership is ID-only and supports neutral optional fields without a schema break.
- Safe ball-profile axes are release Speed, additive Quality, air-Drag multiplier, and Payload. Recovery/lineup/tapping/body stats do not belong to a ball shell.
- Ordinary perk options already materialize level/rarity/corruption-adjusted numerical effects. Body adjective cards are the gap: UI currently renders only `+<adjective> body adjective`, while authoritative numerical effects live in the mapped legacy Body modifier.
- Mastery is credited before `_check_opponent_unlock()`, so both requested threshold-order cases are conceptually correct. The bug is opponent identity: mastery uses `resolved_opponent_index`, while the unlock check reads mutable `current_opponent`.
- Offline `_apply_resolution()` currently calls both volley-event recording and `check_achievements()` without a live/offline source policy, allowing action achievements from catch-up.
- The current catalog has 165 achievements. Many apparent overlaps are legitimate threshold or boss-context escalations; the pass needs a semantic-signature audit and save-compatible aliases only for true duplicates.
- The first M1 implementation pass confirmed that simply gating `result_totals` / lifetime counters in `_apply_resolution` is insufficient: `_record_volley_achievement_events` runs earlier during impact resolution. M1 must retain true lifetime statistics, add explicit persisted live-action achievement counters, and gate volley event metrics at their source.
- Name generation has large theoretical combinations but reuses the same human pools across adjacent sub-eras and collapses later alien/eldritch eras into two pools; deterministic cycling can still look repetitive.
- Mobile bottom navigation already has `LOG`, but it currently opens only the event log. Achievements, Story, Stats, and Help are mixed into the upgrade `TabContainer`.
- The live arm is renderer-only in `pitch_field.gd`; ball timing and immutable release snapshots live in `game_state.gd`. The accepted title state currently animates windup/outbound, but its forward arm motion must finish at outbound-ball spawn rather than continuing through the ball’s flight.
- Primary prose source currently available: `/Users/dustinrowland/.codex/attachments/3e977f02-3477-4480-a075-302f440f557f/pasted-text.txt`.

## Product and architecture decisions

1. **Ball profile model:** Each shell definition stores a cumulative exact profile. Intermediate shells rotate their primary change among Speed, Drag, Quality, and Payload; payload reaches the existing major human/alien/eldritch endpoint anchors through fewer, more meaningful jumps. The newest/highest owned shell replaces the full prior profile. Tooltips show the exact changed stat and the Loadout card shows the full current profile.
2. **Body card numbers:** Resolve adjective card copy from the same mapped Body-modifier effects used by gameplay. Flavor remains subordinate after a first-line numerical statement.
3. **Unlock identity:** `_check_opponent_unlock` receives the resolved opponent index explicitly. Only that index’s mastery/boss/reward state is evaluated; a stale volley cannot clear whichever opponent happens to be displayed.
4. **Online achievements:** Add an explicit live/offline resolution context. Volley events and durable action-count achievement metrics advance only for live resolutions. Offline still updates ordinary gameplay totals/rewards, but does not call achievement unlock presentation.
5. **Duplicate definition:** Same effective predicate, same threshold, and no genuinely distinct opponent/build/context. Escalating thresholds and named boss feats remain distinct. Removed IDs map to the kept funny ID so old earned credit and the total bonus are not silently lost.
6. **Writing source:** Add `docs/writing/story-voice-seed.md` with the user-authored passages and a concise voice checklist, plus a narrow repository instruction/reference so later narrative work reads it first.
7. **Mobile information architecture:** `UPGRADES` contains purchases only. `LOG` opens a touch-sized hub for Events, Achievements, Story, Stats, and Help; selecting one uses the existing overlay reparent/restore mechanism. Desktop tabs remain available.
8. **Pitch inspection:** The Arsenal summary stays in Loadout and opens a reusable read-only inspection surface; it is not an upgrade tab.
9. **Visual release pose:** Use a deterministic visual mapper: roughly the first 70–80% of cooldown slowly cocks the arm; the final fraction whips to the exact release geometry. Title windup follows the same story. No GameState timing changes are required.

## Milestones

### M1 — Core mechanics, ball profiles, and achievements

- Replace payload-only shells with cumulative multi-axis profiles while preserving IDs, unlock order, and tier endpoint anchors.
- Apply current-shell Speed/Quality/Drag/Payload at immutable volley creation and expose exact profile/delta copy.
- Render exact numerical Body-adjective perk effects from authoritative modifier data.
- Make unlock checks opponent-index explicit and cover both requested mastery-threshold cases plus stale-resolution identity.
- Add live/offline achievement context and online-only action metrics; audit true duplicate predicates and preserve removed-ID credit.
- Add focused progression/save/offline/content tests.

### M2 — Authorial seed, dramatic story, and name variety

- Add the durable prose/voice source and repository narrative-work pointer.
- Rewrite the prologue, Story explainer, every first-run human arrival, and relevant legacy migrated human beats in the stored voice.
- Rewrite the first genetic rebirth and Octathulhu threat from the supplied prose, and add the once-only post-rebirth Middle School beat without replaying it on every prestige.
- Remove coach-as-pitcher implications while keeping the recognizable league stage.
- Expand composable names/grammar and add deterministic anti-repetition coverage while preserving signatures.
- Add story-anchor, pool-volume, signature, and repetition regressions without brittle exact-literary-copy tests.

### M3 — Upgrade/Log/Loadout navigation and release animation

- Reorder purchase tabs and remove PITCH from the upgrade navigator.
- Add reusable Loadout Pitch Arsenal inspection for desktop and mobile.
- Add the mobile Log hub and remove non-purchase pages from the phone upgrade sequence.
- Update Story/Help onboarding and mobile touch/geometry tests.
- Animate live and title arms through rest → slow cock → fast forward release; visually inspect desktop and phone captures.

### M4 — Sol integration, balance acceptance, and one deterministic publication pipeline

- Review every delegated diff/evidence and close every requirement-ledger item.
- Run only invalidated focused checks, then one required release gate sequentially.
- Sanity-check ball redistribution and first-human progression against established endpoint/pace anchors.
- Stamp the accepted release metadata before the first final export.
- Build all platforms once from one identified accepted source revision and reuse the exact verified artifacts for GitHub Pages, owner-only Sites, GitHub release/update metadata, and supported macOS/Windows/Linux/browser downloads.
- Start one durable fan-out publication pipeline, record its run/commit/artifacts/destinations here, and report the aggregated result without rebuilding successful targets.

## Acceptance criteria

- At least one shell in each unlocked campaign tier advances Speed, Quality, and Drag without advancing Payload; the full current ball profile is mathematically visible.
- Purchasing later shells replaces one coherent profile and cannot stack every historical multiplier.
- Every perk card has concrete numerical effects; no Body adjective card says only that an adjective was added.
- Mastery crossed by a strikeout unlocks immediately; mastery crossed otherwise waits for the next strikeout; delayed resolutions cannot clear a different current opponent.
- Offline catch-up produces its normal idle rewards but cannot increment/unlock live action-count or volley achievements.
- No two visible achievements have the same semantic predicate/threshold/context; old earned duplicate IDs retain equivalent credit.
- The prose seed is stored in-repository and every human first-run chapter uses its dramatic/absurd voice. Coach Pitch never says the coach throws the player’s pitches.
- Generated ordinary batters show materially greater deterministic variety without altering authored boss names.
- Mobile UPGRADES begins Train/Facility/Ball/Body and contains purchases only. Mobile LOG exposes Events/Achievements/Story/Stats/Help. Loadout opens a read-only Arsenal.
- Live and title arms visibly cock slowly and whip to release exactly where the ball appears; released-ball snapshots and flight remain unchanged.
- The accepted source, Web/PWA, native artifacts, Pages, owner-only Sites, and GitHub release/update channels identify one synchronized revision.

## Validation ladder

### Milestone-focused

- Mechanics/content/save runner(s) covering ball profiles, old ownership, mastery identity/order, online/offline achievements, and semantic duplicate signatures
- `tests/overhaul_runner.gd`
- `tests/progression_audit.gd`
- `tests/ui_runner.gd -- --fresh`
- `tests/mobile_ui_runner.gd -- --fresh`
- Deterministic story/name content audit
- `git diff --check`

### Final accepted revision

- One sequential required release gate; do not immediately rerun worker-passing suites unless source corrections invalidated them
- Desktop and 390×844 browser acceptance for purchase order, Loadout Arsenal, mobile Log hub, story copy, perk numbers, and arm release
- One all-platform packager/orchestrator run after metadata stamping
- Exact artifact parity, checksums, update manifest, Pages, owner-only Sites, and GitHub release verification

## Progress

- [x] Preserved the accepted remote-update/title-loop worktree and unchanged-save-hash evidence.
- [x] Converted every Bullet Journal note into a requirement-ledger item.
- [x] Located and read the user’s original dramatic prose seed.
- [x] Completed read-only mechanics/content and UI/story architecture audits.
- [x] Complete and accept M1 through delegated Terra implementation and focused contract review.
- [x] Complete and accept M2 through one delegated Terra implementation milestone.
- [x] Complete and accept M3 through one delegated Terra implementation milestone.
- [x] Lock accepted v0.18.0 source revision `146ebc0` and run the one deterministic all-platform validation/package pipeline.
- [ ] Publish and verify the exact v0.18.0 artifacts across the approved synchronized destinations.

## M4 release record

- Accepted source: `146ebc0` (`Release No Hitter v0.18.0 source`)
- Version / save schema: `0.18.0` / `30`
- Release gate: PASS (`test_runner`, desktop UI, 390×844 mobile UI, macOS Universal, Windows x86_64/ARM64, Linux x86_64/ARM64, Browser, archive validation, Web parity)
- Sites wrapper build and four rendered-response tests: PASS, reusing the exact Web artifact
- Web PCK / Sites fingerprint: `6bce5c4d4b0935ec90b8f852801c66802372e6b9ad1cd44e9579568b54cd96ec`
- Browser ZIP: `062c7a12f02c1ed18d469054abfd49a4c531bcbace982f9754610199c5b0c5b3`
- All Desktop Platforms ZIP: `31f6c015ab5d1cf89977d8940a8ca0a5eaacc50ec4ae42a9d92adaf499ac7774`
- All Platforms ZIP: `3233bbe7d9f78ad536446cb2d57bab7c3f1620ff3ad90b21b33334adf92af3cf`
- Per-platform checksums are recorded in `release/No Hitter v0.18.0/SHA256SUMS.txt`.

## Exact next action

Commit the generated v0.18.0 Web/update metadata, push the synchronized artifact revision to `main`, publish the exact prebuilt archives to GitHub Releases, deploy the already-built Sites wrapper privately, verify Pages/Release/Sites once, and record the publication identifiers here. Do not rebuild successful artifacts.
