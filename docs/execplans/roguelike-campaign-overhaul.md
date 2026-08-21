# No Hitter Roguelike Campaign Overhaul — Execution Plan

## Status

The complete gameplay/UI overhaul is implemented and the delegated final-validation milestone is accepted. Core, progression, first-lifetime, desktop, and portrait suites pass; desktop/compact/phone captures were reviewed; and the slow multiverse diagnostic has current evidence through every league and the 5,000c level-100 gate. The final synchronized v0.17.0 Web and native artifacts are built, archive-verified, and browser-accepted. Only commit/push, GitHub release/Pages publication, Sites publication, and host verification remain.

## Goal

Turn the current linear 45-level idle campaign into a replayable 100-level baseball roguelite without losing the readable physical joke, strikeout-only economy, progressive spoiler reveals, or the distinct genetic, eldritch, and divine prestige layers.

The completed update must make each run produce meaningful build choices, make each new opponent materially harder, preserve useful backward farming, anchor speed and distance to authored physical scales, make story encounters legible, and keep old saves loadable across desktop, browser, installed PWA, GitHub Pages, and Sites.

## Product reconciliation

The notes describe one coherent structure when interpreted as follows:

1. **The run layer** supplies randomized level perks, pitch drafts, equipment, ball shells, expensive Facilities, and repeatable Training. These are the build decisions that make one trip through the leagues differ from another.
2. **Genetic prestige** supplies persistent biological tools, automation licenses, more arms, and better future draft odds. It should accelerate replay without deleting the need to build a new run.
3. **Eldritch prestige** supplies persistent reality-breaking tools: clones, corrupted perks, multiple Relic slots, overlapping volleys, portals, and stronger automation.
4. **Divine prestige** remains the complete-universe reset and unlocks the post-victory endless ladder.
5. **Mastery** serves two jobs without conflating them: all useful contact teaches the pitcher and improves that exact matchup, while only a completed strikeout can actually clear a level.
6. **Physical scale** stays honest in simulation. The visual camera may compress astronomical scale for legibility, but displayed distance, release speed, drag loss, plate speed, and flight time must describe the same released projectile.

## Current repository state

- The shared Godot project now has exactly 100 finite opponents: 33 human, 33 alien, 33 eldritch, and level-100 Octathulhu. Xylophax and Octathulhu also have separate unnumbered first-contact exhibitions.
- Save schema 28 migrates every earlier public save generation, including authored era-position mapping from the old 45-level ladder and deterministic legacy run perks/pitches.
- Browser, native, Pages, and Sites all consume the same gameplay source. Browser rendering may aggregate dense projectile visuals but may not change simulation results.
- The earlier uncommitted save-slot-summary work is retained in the major-release branch; summaries now include revealed prestige currencies without leaking future systems.
- The current high-resolution first-lifetime audit reaches first contact in roughly 8 hours 45 minutes, at the authored 115 mph human ceiling, with no human frontier below the 2.5% called-Strike floor. The full choice-aware multiverse audit is the final active balance gate.
- Working tree at the handoff boundary is intentionally dirty with the complete v0.17.0 overhaul: 28 tracked files modified plus new Campaign, RunContent, lapped-progress, overhaul-test, and ExecPlan files. No unrelated user edit has been reverted. `git diff --check` passes.

## Requirements

### Campaign topology and bosses

- Author 33 human levels, 33 alien levels, 33 eldritch levels, and one final Octathulhu fight: 100 finite levels.
- Use meaningful sub-era boundaries rather than five nearly identical opponents with renamed labels.
- End human baseball with a sticky Bambino Rex boss gate.
- Present the first impossible Xylophax encounter only after its story dialog is accepted. Fill a witnessed Grand-Slam humiliation meter before genetic rebirth becomes available.
- End alien baseball at Olympus Mound with playable Xylophax, four bats, planetary range, and roughly Mach 5000 end-state speed.
- Present the first impossible Octathulhu encounter only after its story dialog is accepted. Fill a witnessed Grand-Slam doom meter, then have Octathulhu eat the universe as the eldritch reset is revealed.
- Stage the eldritch replay as Earth's defense: an orbital mound, approaching gods at intervening planets, Earth-to-Pluto final range, and roughly 5000c end-state speed.
- Make Octathulhu the eight-bat level-100 boss and preserve God Prestige.
- After at least one God Prestige, reaching Octathulhu again unlocks a procedural endless ladder and leaves God Prestige available at any time.

### Perk and pitch draft layer

- Replace the current buy-everything body/pitch cadence with deterministic saved draft offers.
- A normal level clear creates a level-scaled perk choice. Default offer count is two; prestige can raise it.
- Normal offer rarity is rolled from Common upward and can be improved by prestige.
- Every authored sub-era boundary guarantees a materially stronger Rare-or-better perk offer and separately creates a pitch choice: learn a new pitch or improve an existing pitch.
- A league boss creates a boss-pitch offer. After the cheap genetic unlock, future Bambino clears also create a strongest-tier boss perk.
- A perk's level is the defeated level and directly scales its magnitude.
- Every offer is generated once, serialized, and cannot be rerolled by reloading.
- Manual Next Level waits on unresolved mandatory choices. Auto-advance may continue and queues every skipped choice for sequential resolution later.
- Add corrupted perks behind an eldritch upgrade. Each eligible offered card independently has a 20% replacement chance, multiplies its positive effect by a randomized 2–3×, and adds one meaningful random penalty.
- Give perks sarcastic names and feed body/build adjectives into the existing subtitle composition.

### Progression and mastery

- A called Strike grants base mastery; a completed strikeout grants a clear extra mastery award.
- Foul, Ball, Single, Double, and Triple grant small severity-aware mastery. Home Run and Grand Slam grant none.
- Filling mastery without a strikeout marks the opponent ready but cannot unlock the next level.
- If the strikeout itself crosses the threshold, it clears immediately.
- Once a finale's next strikeout could complete the level, replace the ordinary batter with the sticky boss. Leaving and returning keeps that boss active.
- Offline simulation may fill pre-boss mastery but must stop at the witnessed boss gate and cannot complete or skip it.
- Overmastery remains logarithmically useful. The bar gains repeat-fill visual layers that trend greener with each order of magnitude rather than freezing visually at 100%.

### Economy and balance

- Keep Training incremental and add x1/x10/x100 batching with exact rounded total costs and no partial accidental purchase.
- Remove duplicated costs from card descriptions; the action button is the sole price display.
- Keep Ball and Facility purchases as strong run-scoped choices. Reprice and gate them so frontier income usually funds one or two attractive purchases, not every newly revealed Facility.
- Preserve backward farming as a real choice when the frontier has poor XP per second.
- Make per-level difficulty jumps visible in Strike probability and completed-strikeout probability, with larger authored shocks at sub-era and league boundaries.
- Rebuild the deterministic purchase/draft simulators around actual choice scoring rather than buying every available item.

### Tapping and Determination

- Replace discrete timer jumps with a rolling 1–2 second tap-rate signal shared by manual and automatic taps.
- Convert tap rate through a smooth diminishing curve into Recovery, lineup, and flight multipliers.
- During flight, taps temporarily increase the active projectile's speed and reduce effective drag; they never teleport the ball.
- Every tap adds a small amount of Determination. Rename Frustration and its saved/trained/UI fields through a migration while retaining the uncapped logarithmic adaptation curve and strikeout reset.
- Add a multi-lap circular tap meter whose fill and color communicate live input intensity.
- Render one subtle pulsing dot per automatic tapper with an Auto-tapper label; pulse cadence must match its effective rate.

### Flight, camera, and combat visuals

- Replace the five-second logarithmic flight-time compression with authored physical distance/speed/drag timing. Story gates must prevent access to ranges that are functionally impossible for the current progression layer.
- Give alien distance meaningful atmosphere/drag loss and provide expensive mitigation upgrades.
- Snapshot every released ball's base pitch, speed, drag, path, source, target generation, and outcome inputs. Tap-derived flight modifiers act continuously on that snapshot and disappear at arrival.
- Unhit balls and Strikes continue through the plate and fade without changing into a generic ball. Only a hit creates a returned-ball trajectory.
- Scale pitcher/batter markers down much more aggressively with camera distance while retaining a small legibility floor. Do not imply a 200-foot mortal body.
- Arrange enemy arms and bats independently around the body. Reduce bat length and progress visibly through two, three, four, and eventually eight bats.
- Add a reciprocal multi-ball rule: balls beyond bat coverage sharply reduce contact; bats beyond simultaneous balls sharply improve it.
- Replace the genetic guaranteed Single/Double/Triple defense. Clone fielding first rolls immutable spatial coverage from clone count, then an upgradeable catch check, then an independently unlocked eligible-hit tier. Human catches retire the batter without strikeout XP; post-human catches preserve the count and batter.
- Add an eldritch upgrade that permits new windups while earlier volleys remain in flight. The active-flight model, save schema, renderer, and offline solver must handle multiple authoritative volleys.

### Equipment and Relics

- Limit normal equipment to one through three affixes regardless of rarity.
- Let rarity increase magnitude instead of affix count.
- Expand the affix pool across every current run stat and allow genuine tradeoff items with positive and negative values.
- Keep Power sorting useful but make comparison reflect build fit rather than assuming every higher-rarity item is strictly superior.
- Make each Relic grant one very large stat effect. Start with one slot and add repeatable or bounded Relic-slot purchases in the eldritch layer.
- Preserve no-auto-equip drops, explicit comparison, starring, inventory caps, Scrap, and time-travel rules.

### Story, names, achievements, and interface

- Add a spoiler-gated Story tab with newest-first default order and a Reverse Order toggle.
- Persist full story entries, dialog text, timestamps/order, and one-time presentation keys.
- Open a new game with the dramatic Little Timmy prologue and explicitly mention the Story tab.
- Add authored story beats at school/league/sub-era transitions, questionable build choices, first alien contact, genetic replay, first eldritch replay, Earth defense, cosmic victory, God Prestige, and endless play.
- Give genetic and eldritch replays distinct one-time variants without replaying the same popup every reset.
- Expand the composable name grammar, vocabulary, title forms, and signature-name exclusions enough that ordinary repeats become rare.
- Add the requested automation and speedrun achievements without removing distinct existing achievements.
- Preserve compact desktop/mobile cards, scroll-safe passive text, explicit actions, long-press/hover parity, progressive spoilers, save slots, and prestige-aware save summaries.
- Preserve the complete adjective chain in the subtitle. When clones exist, pluralize only the final body noun (`guy` → `guys`) rather than replacing the description.

### Save migration and release parity

- Advance the save schema and migrate all schema-25 data without wiping progress.
- Map the old 30/10/5 ladder into the new 33/33/33+1 topology by authored era position, not raw index multiplication.
- Convert owned body stages/modifiers and learned pitches into equivalent deterministic legacy run perks/pitch levels for the currently loaded run. Future prestige resets use the new draft system normally.
- Expand mastery/history arrays and preserve prestige currency, upgrades, gear, achievements, lifetime counters, story knowledge, and pending update checkpoints.
- Keep browser, installed PWA, macOS, Windows, Linux, Pages, and Sites on the same gameplay source and update manifest.

## Constraints and non-goals

- Do not make perfect randomized perks or equipment mandatory for progression.
- Do not let random draft generation create a softlock; every offered set needs a viable stat-category mix and deterministic fallback.
- Do not reveal genetic, alien, eldritch, divine, or endless content before the matching story boundary.
- Do not make human baseball visually absurd: one unresolved pitch, recognizable body scale, realistic top speed, and restrained Recovery remain the baseline.
- Do not award XP for catches, hits, partial counts, or mastery alone. Only a completed strikeout pays XP.
- Do not make active tapping mandatory for the audited idle pace.
- Do not let browser renderer ceilings change combat or rewards.

## Milestones

### M0 — Resolve product decisions and freeze the specification

- Answer the open decisions below.
- Update this plan with exact topology, draft cadence, reset scope, pacing targets, overlapping-flight semantics, and release channel.
- Produce the authored level/sub-era/story/perk content tables before changing simulation code.

### M1 — Data model, 100-level content, and save migration

- Introduce campaign descriptors, boss/exhibition descriptors, perk/pitch instance schemas, story journal schema, pending choice queue, multi-Relic loadout schema, and active-volley schema.
- Build schema-25 migration and deterministic old-level mapping.
- Add invariant tests for IDs, topology, unlock ordering, migration, spoiler reveal, and deterministic offers.

### M2 — Progression, mastery, bosses, and draft flow

- Implement mastery-by-outcome, strikeout completion bonus, ready-for-K gating, sticky bosses, offline stops, perk queue, pitch leveling, corrupted cards, and auto-advance queueing.
- Replace Grow/Build and Pitch purchase interactions according to the resolved decision.
- Add unit and aggregate-simulation parity tests.

### M3 — Economy, stats, physics, and prestige rebuild

- Re-anchor threat, rewards, Training batches, Facilities, ball shells, DNA/Arcana gains, and prestige upgrades.
- Implement literal physical travel, drag environments, tap-rate multipliers, Determination, overlapping volleys, clone fielding, reciprocal bat coverage, and Relic slots.
- Add deterministic first-run, first-rebirth, first-alien-clear, first-eldritch-clear, and first-cosmic-victory runners.

### M4 — Renderer and responsive interface

- Implement projectile pass-through/fade, multi-flight visual queues, camera scale, independent arms/bats, tap meter, auto-tapper pulses, layered mastery, perk/pitch dialogs, Story, Training batch control, updated Arsenal, and equipment/Relic views.
- Audit desktop wide/compact and 390×844 portrait layouts with interaction-safe scrolling and inspection.

### M5 — Story, names, achievements, endless mode, and help

- Author all first-run/replay story variants and seed migration journals.
- Expand names and achievements.
- Implement the post-God endless ladder and procedural difficulty/perk continuation.
- Rewrite Help and design/balance documentation around the shipped rules without spoilers.

### M6 — Balance acceptance and release

- Run optimal-ish no-loot simulations and randomized-seed sweeps; tune until all resolved pacing bands pass without perfect loot.
- Run repository-wide gameplay, migration, offline, UI, mobile, performance, Web parity, archive, and installed-update tests.
- Publish a versioned test build through the resolved preview/live channel, verify update metadata, and retain a rollback path.

## Acceptance criteria

- Exactly 100 authored finite levels with correct boss/story boundaries, followed by a gated endless ladder.
- A new run cannot reroll saved choices by reloading and cannot be softlocked by draft RNG.
- No ordinary level unlocks from mastery-only contact; the completing event is always a strikeout.
- Bambino, first-contact Xylophax, playable Xylophax, first-contact Octathulhu, and final Octathulhu cannot be bypassed offline.
- End-human, end-alien, and end-eldritch audited speeds land near the resolved 115 mph, Mach 5000, and 5000c anchors at their authored distances.
- Physical flight telemetry and visible movement agree, including tap acceleration and drag loss.
- Post-human replay is faster than a fresh run but still presents meaningful frontier odds, XP scarcity, and purchase choices.
- Random perks/equipment produce viable distinct builds while the no-loot/no-perfect-roll audit can finish.
- Existing schema-25 saves load with preserved permanent progress and a sensible equivalent current run.
- Desktop, phone, browser, PWA, and native packages remain at gameplay parity.

## Validation

- Core unit/invariant suite.
- Save fixtures for fresh, human, genetic, eldritch, divine, pending choice, pending boss, and multiple in-flight states.
- Exact-vs-aggregate probability and offline parity checks.
- Human and full-multiverse pacing simulations with a choice-aware purchase policy.
- Multi-seed draft viability distribution and worst-decile completion checks.
- 100-level progression audit and infinite-level monotonicity audit.
- Desktop progressive-interface and portrait mobile-interface audits.
- Projectile throughput/performance stress at designed browser/native ceilings.
- Web source parity, PWA update migration, all-platform packaging, Pages deployment, and Sites deployment.

## Resolved decisions

1. **Finite topology:** The finite campaign is 33 human + 33 alien + 33 eldritch levels plus level-100 Octathulhu. First-contact Xylophax and first-contact Octathulhu are unnumbered story exhibitions.
2. **Grow/Build replacement:** Ordinary Grow and Build XP purchases disappear. Their ages, adjectives, effects, and jokes become run-scoped drafted perks. Prestige controls remain persistent, and skipping age perks preserves the toddler challenge.
3. **Draft cadence:** Normal clears roll any perk rarity. Each authored sub-era boundary guarantees Rare-or-better and separately queues a pitch draft. Bosses queue boss-pitch rewards and, once unlocked, boss perks.
4. **Pacing bands:** The proposed 12-hour opening, approximately six-hour first replay, multi-rebirth alien campaign, and multi-ascension cosmic campaign are useful tuning landmarks rather than hard clocks. Feel, meaningful choices, and stable frontier probabilities take priority over hitting exact elapsed times.
5. **Overlapping-flight target:** If a volley's original batter leaves before impact, it loses targeting, visibly veers in a deterministic random direction, and quickly fades without resolving against a replacement.
6. **Testing channel:** After complete validation, publish directly to the live GitHub Pages testing build and keep Sites/native packages synchronized.

## Progress

- [x] Read and cross-reference the complete note set.
- [x] Audit current campaign, prestige, physics, mastery, tap, equipment, story, UI, save, release, and simulation systems.
- [x] Run the current first-lifetime and multiverse pacing baselines.
- [x] Reconcile the notes into one candidate architecture.
- [x] Resolve open decisions with the user.
- [x] Freeze the 100-level campaign, distance, perk, pitch, and story tables.
- [x] Add deterministic run choices, persistent pending queues, story journal state, schema-28 migration, and focused contract tests.
- [x] Add outcome-weighted Mastery, strikeout-only completion, sticky boss state, and offline boss protection.
- [x] Integrate drafted body/pitch effects and remove obsolete purchase paths.
- [x] Rebuild economy, tap signal, Determination, physical flight, overlapping volleys, fielding, equipment, and Relics.
- [x] Complete responsive run-choice/Story/Arsenal UI, story encounters, achievements, and endless play.
- [x] Pass focused data/save, first-lifetime progression, desktop interface, and 390×844 portrait-interface suites.
- [x] Run a full coarse-decision multiverse diagnostic through level 100 and one deeper eldritch ascension; isolate its eventual timeout to audit decision granularity rather than gameplay reachability.
- [x] Stabilize the delegated multiverse audit policy so its farm/push cadence rotates and its reset guard observes a complete strategy cycle.
- [x] Complete delegated responsive desktop/phone visual acceptance.
- [x] Fix the multiverse audit's final-boss policy so it holds level 100 for the witnessed winning K instead of taking an immediately preceding deeper ascension.
- [x] Run final repository-wide suites, Web parity, Sites adapter tests, real-browser responsive acceptance, and package every target.
- [ ] Publish synchronized Pages/Sites/native update releases and verify both live hosts.

## Discoveries

- The reported economy problem is measurable: the current first-lifetime audit buys 949 items and reaches several frontiers at roughly the same ~67% Strike chance before a late-human wall, then one large purchase jump trivializes the finale.
- The reported prestige problem is also measurable: the current first genetic replay reaches the alien boundary in about 2.5 hours with Recovery already far beyond human cadence, and later meta-progression hits the 20,000-pitches/s ceiling long before cosmic play.
- Current physical telemetry is internally exact before presentation compression, but resolved flight time is deliberately logarithmically clamped to five seconds. The overhaul must remove that clamp and rely on authored speed/range gates instead.
- Current fielding directly guarantees Single/Double/Triple protection in the genetic layer. It conflicts with the requested clone-coverage/catch model and should be replaced, not stacked.
- Current active pitch state stores only one pending volley. Supporting the requested eldritch overlap requires an authoritative queue, not a renderer-only trick.
- The stable `test_runner.gd` and `balance_runner.gd` entry points now delegate to the overhaul-aware contract and first-lifetime suites, so release scripts cannot accidentally validate retired 45-level rules.
- A 15-minute-decision multiverse audit confirmed an 8:45 first contact and healthy alien sub-era shocks, but was too slow at physical velocity licenses. The release runner now uses exact expected-income accounting at those gates and refuses savings plans over four hours so a rational prestige is preferred over an astronomical asymptotic Training bill.
- Human Recovery remains constrained by one unresolved pitch and an authored ceiling. Post-human cadence comes from explicit arms, clones, windup overlap, and time layers rather than leaking human Training into absurd early rates.
- The first visual review found three retired 45-level assumptions outside the simulation: title-art reveal thresholds, field environment thresholds, and final-boss preview indices. They now derive from the shared Campaign constants, so desktop/mobile art follows the same 33/33/33+1 topology as gameplay.
- Campaign body scale is already the authored intrinsic batter footprint. Removing a second legacy-size multiplier fixed gigantic early bodies; the opening 0.72 toddler scale and 1.08 pitcher scale now produce the requested 1.5:1 pitcher-to-toddler ratio before perspective compression.
- The choice-aware audit with an 11-hour post-eldritch decision interval proved the full finite ladder reachable in its first eldritch reality: level 100 appeared at day 69:14, the sticky eight-armed boss at day 70:01, and speed held the authored 5,000c anchor. The policy then rationally took a deeper ascension at a 0.0013% completed-strikeout chance.
- That same run formally timed out at day 120:00 on level 58 of its second reality after 7 resets, 13,122 purchase decisions, 15,013 Training ranks, 144 DNA purchases, and 34 Arcana purchases. The timeout is a runner artifact: eleven-hour purchase decisions are too coarse for a 120-day guardrail, while the run had already demonstrated every finite level and physical gate. A prior 12-hour attempt also exposed a modulo phase lock because 12 hours equals 24 of the runner's 30-minute farm blocks; future cadence must rotate through all three farm/push phases.
- There is no repository-local applicable `AGENTS.md`; the Sol/Terra/Spark policy supplied to the active task governs the remaining work. The next milestone is explicitly delegated rather than implemented in the Sol parent.
- A two-hour post-eldritch audit cadence rotates across all three half-hour farm/push phases. Its DNA-stall guard must wait six hours, one complete phase cycle, or farm returns can falsely reset a healthy run before the next frontier push.
- The corrected audit repeatedly reaches first eldritch ascension at day 2:16 with +408 Arcana and advances later realities normally. A complete cosmic-victory release gate remains intentionally slow through `simulate_active_time`: aggregate resolution advances at most one frontier per return and every choice boundary re-scores a large late-game economy. The earlier coarse audit reached level 100 at day 69:14 with the exact 5,000c anchor and positive final-K odds; focused contracts independently prove the witnessed level-100 K sets cosmic victory.
- That coarse audit exposed one test-policy bug rather than a gameplay wall: it took a deeper ascension at day 70:01 at the end of the interval that made Octathulhu ready, immediately before the next loop's witnessed-boss resolver. The runner now refuses strategic prestige after level 100 becomes available, so its next decision supplies the finite final K.
- Delegated desktop and 390×844 logical-layout suites pass. Primary capture review accepted the landscape title composition, compact 1179×720 play layout, 1256×696 wide-edge tri-pane, desktop Training/Story/equipment states, opening 1.5:1 pitcher-to-toddler scale, readable text, and unclipped controls. The native capture harness retains its physical desktop window while testing a 390×844 logical root, so its portrait PNG has surrounding desktop pixels; the headless logical-geometry suite is the authoritative native-mobile assertion and browser portrait rendering remains part of final Web acceptance.
- Final browser acceptance used a fresh local origin after the last export. The 1280×720 title and three-pane play screen, 1179×720 compact transition, and 390×844 portrait equipment and mandatory-choice windows all fit without page scrolling. The remaining desktop equipment-window defect was traced to a Web child-window title bar outside a 720-pixel canvas; the shipped build now uses an explicit in-content Close action, viewport-clamped geometry, and live recentering across responsive breakpoints.
- The final `package_all_platforms.sh` run passed the core, progressive-interface, and portrait-interface suites; exported and verified browser/PWA, Universal macOS, Windows x86_64/ARM64, and Linux x86_64/ARM64 targets; validated the DMG and every archive; and produced a 206 MB `No Hitter v0.17.0 All Platforms.zip`. `verify_web_parity.sh` passes, and the Sites adapter rebuild passes four rendered/runtime tests including segmented WebAssembly reconstruction.

## Exact next action

Perform Sol's final diff review, commit and push the exact accepted source/build state, publish the synchronized GitHub Pages/native release and approved Sites deployment, and verify both hosts without opening them for the user.
