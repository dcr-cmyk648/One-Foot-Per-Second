# Changelog

## 0.9.0 — The bullpen discovers hyperlinks

- Added a maintained Godot Web export target using the Compatibility renderer, the preferred single-threaded template, adaptive browser-canvas sizing, and a static-site package suitable for ordinary Web hosting.
- Kept browser and native gameplay on one codepath: every scene, content table, probability, economy rule, prestige layer, loot roll, migration, and regression test is shared. The browser profile aggregates only incoherent late-game presentation after 512 outbound balls, 96 returns, 96 stars, or 16 visible clone bodies.
- Added browser-aware suspension catch-up. Losing browser focus saves immediately; returning advances the same bounded offline simulation instead of losing idle time or replaying a burst of visual pitches.
- Added portable EXPORT and LOAD controls on every platform. Browser export downloads JSON and browser load uses the host file picker; desktop builds use native file dialogs. Imports reject malformed, oversized, unrelated, or future-version files and show a hard replacement confirmation before applying migrations and autosaving.
- Added repeatable browser-only and complete all-platform packaging scripts, static-host instructions, artifact validation, and a shared release manifest so the Web build is rebuilt from the same version as every desktop package.
- Added a checked-in, tested GitHub Pages site and deployment workflow. Source and artifact manifests make the workflow fail closed if shared gameplay changes without a matching Web export or if a compiled browser file is altered.

## 0.8.0 — A suspiciously well-funded bullpen

- Rebuilt ordinary Training as seven gradually unlocked additive fundamentals: Speed, Quality, Recovery, Distance Control, Lineup Hustle, fair-hit recovery, and Pitch Calling. The default field now shows every trained base stat in one compact, tooltip-driven live profile.
- Split batter replacement tuning into two independent axes. Lineup Hustle reduces the universal replacement baseline, while Shake It Off reduces only the extra delay caused by fair hits; walks keep the Single delay but do not receive hit-only reductions.
- Expanded the Facility ladder from twenty to forty-two expensive, one-time multipliers spanning backyard gear, Suspicious Vitamins, real training hardware, increasingly obvious steroids, alien laboratories, and eldritch infrastructure. Several purchases use speed, distance, or strikeout achievement gates in addition to level gates.
- Enforced unlock-level ordering within Training, Pitch, Ball, and Facility tabs. A revealed tier shows its whole catalog, but locked entries disclose only their requirements; concrete effects remain hidden until every gate is met.
- Added Autonomic Wardrobe Lobe, a genetic convenience upgrade that equips the highest-Power item in each unlocked slot. Equipped squares and Locker rows are now unmistakable, and the larger constrained popup keeps item text and favorite stars inside their rows.
- Made high rarity meaningful: ordinary drops are now 78% Common, 18% Magic, 3.7% Rare, 0.27% Legendary, and 0.03% Unique before opponent mastery modifies the roll. Power remains the sole primary sort and overflow rule.
- Cached milestone and equipment aggregation, reused at-bat calculations across each UI refresh, and replaced the field's all-slot projectile scan with an active-instance set.
- Batched dense starfields and return volleys and bounded only visually incoherent clone-limb detail. All 2,048 designed outbound endgame balls still render one-for-one; a ten-second launch/impact/return stress run measures 44–60 FPS on the development Mac's Radeon Pro 560X, with most samples at 58–60, versus a 60 FPS fresh field.
- Advanced saves to version 13 with migration from multiplicative training ranks, the new split cooldown axes, the expanded facility state, and Autonomic Wardrobe.
- Rebalanced and re-audited the loot-free game. The first human championship now takes about 37.5 active hours, and the complete multi-reset route reaches Octathulhu at exactly 1c after about 68 days 21 hours.

## 0.7.0 — The umpire remembers Balls now

- Added Foul and Ball as full pitch outcomes. Fouls advance the Strike count but cannot produce strike three; four Balls walk a human batter, clear the count, and trigger Single-length turnover without paying XP. Post-human opponents gradually require only three, then two Balls.
- Replaced the aggregate approximation with an exact absorbing at-bat model over live Strike and Ball counts. Offline progress now accounts for Fouls at two strikes, walks, protected-hit self-loops, simultaneous volleys, terminal outcomes, and each outcome's full lineup delay.
- Made learned pitches a real automatic arsenal. Every release selects a pitch, Pitch Calling biases the mix toward stronger options, each pitch samples an exact speed from its own range, and the field identifies both the pitch and its measured speed.
- Allowed mound changes and opponent selection while a pitch is in flight. Released speed, type, trajectory duration, and release distance stay immutable; choosing another batter changes only which batter receives the unresolved pitch.
- Expanded the human-readable ball progression from twelve to twenty-six shells, keeping all thirty human levels recognizably human and reserving Railgun Jackets, plasma, and reality-breaking baseballs for their proper story tiers.
- Consolidated three redundant additive quality trainings into Command Drills and added distinct axes for pitch selection and distance control. Multiple systems may still affect the same family when their operations are meaningfully different—for example, additive command and a separate multiplier—but ordinary Training no longer presents cosmetic duplicates.
- Gave every completed plate appearance a believable three-second lineup-change baseline, with compact outcome cards showing only probability and added delay. The Ball meter, pitch meter, on-deck meter, pitch-name popup, and constant-speed miss trails now reflect the authoritative state directly.
- Added a permanent-progress reset guarded by an exact uppercase `RESET` confirmation, and kept all post-human systems and language hidden until their story reveals.
- Advanced saves to version 12, including live Ball count and immutable selected-pitch/speed data, plus migration of legacy quality-training ranks.
- Rebalanced and re-audited the loot-free campaign. The deterministic first human lifetime now lasts about 39.5 active hours and the first complete universe about 66.5 active days.

## 0.6.0 — The ball now waits for causality

- Replaced loose pitch-rate batching with an explicit wind-up → immutable flight → impact state machine. Human baseball permits exactly one unresolved ball: cooldown begins only after impact, no result is exposed at release, and an empty plate can never create pitches or a return-time burst.
- Added separate gold flight and cyan pitch-cooldown dials. The opening cycle is now visibly four seconds of wind-up followed by the literal three-second, three-foot lob; upgrades affect only future releases.
- Added post-human simultaneous-ball capacity as its own prestige axis. Extra arms and clones provide throwing sources, while Parallel Pitching Lobes and Non-Euclidean Bullpen Geometry raise the usable cap to a designed 2,048-ball final volley, still rendered one-for-one inside the 4,000-projectile pool.
- Added integer Diablo-style Power calculated from real affixes. Locker rows sort by Power and overflow removes the lowest-Power unstarred, unequipped item. Equipped slot squares now use rarity colors rather than cosmetic item hues.
- Added per-batter body and equipment rolls. The opponent's body, bat, later clothing, and post-human Relic appear as a vertical loadout on the batter's side and contribute small, explicitly tooled threat modifiers.
- Separated authored individual names from reusable batter classes: Little Timmy and increasingly ominous titled characters rotate within ordinary classes such as Wiffle-Bat Toddler and MLB Champion.
- Split Pitch, Ball, and Facility purchases into independent tabs, narrowed the right panel again, added eight interstitial human facilities/interventions (including Suspicious Vitamins), removed the opponent bat from the player's loadout, and simplified the opponent header to name plus class.
- Strengthened On-Deck Hurry-Up to `Batter cooldown ×0.930` per rank. Range-arrow tooltips now identify the exact destination, XP multiplier, and threat change.
- Advanced saves to version 11, preserving an unresolved pitch's outcome, remaining time, and original duration as well as current batter identity.

## 0.5.0 — The equipment popup is less powerful than a Single

- Replaced the wide Locker tab and left-sidebar outfit list with seven compact field-corner slot squares and a focused equipment popup. Hat, Jersey, Jock Strap, Glove, Pants, and Cleats are human slots; the anonymous seventh square reveals a post-human Relic slot after the human campaign.
- Reduced storage to 10 items per slot and added item stars. Equipped and starred items survive weakest-first auto-scrap; favorites, the new slots, and equipped state persist in save version 9. Version-8 Belt gear migrates to Jock Strap.
- Added uncapped post-target opponent mastery. Each excess-mastery doubling grants a small logarithmic strikeout-XP bonus and improves rarity and affix-roll quality, while drops remain item-level-capped to that batter.
- Made all purchases in the current human, alien, or eldritch catalog visible together. Entries beyond the player's level show only their unlock requirement and conceal their effect; future story tiers remain entirely hidden.
- Narrowed and stabilized the right upgrade panel, shortened its tab labels, simplified outcome cards to name plus probability, and moved completed-strikeout XP into a separate small readout. Batter popups now contain only the outcome name.
- Kept the pitcher cooldown dial visible while earlier pitches remain in flight. Missed strikes continue beyond the plate at their unchanged incoming screen speed and fade gradually.
- Fixed a long-frame clock-order bug that could replay several later results as a rapid mixed-color burst, age a newly created contact twice, and skip the visible batter cooldown. Live exact simulation now stops at the first terminal pitch, the visual clock advances before release batches, and terminal events discard stale later pitches.
- Expanded regression coverage for irregular-frame cadence, terminal Single suppression, full turnover preservation, constant-speed missed strikes, starred overflow, slot migration/gating, post-cap mastery, popup inventory, tier catalogs, and fixed tab geometry.

## 0.4.0 — Properly dressed for the apocalypse

- Added strikeout-only Diablo-style clothing drops across Hat, Jersey, Glove, Pants, Cleats, and Belt slots, with five meaningful rarities, randomized affixes, item levels, a guaranteed first cap, 12% later drop chance, ten-roll pity, and a readable Locker.
- Capped complete-outfit bonuses as optional sidegrades, applied speed gear after body limits, diluted gear across unequipped clones, and added the later clone-uniform upgrade. Deterministic campaign audits continue to complete with loot disabled.
- Enforced 20 stored items per slot and deterministic weakest-first overflow pruning while protecting equipped items.
- Made ordinary time travel erase clothing, added Reverse Terminator Wardrobe to retain one random equipped slot per rank, and kept reality destruction absolute.
- Rebuilt the pitcher in the batter's point-and-ring visual language. The fresh pitcher is roughly 50% larger than the toddler, grows smoothly with strength toward ×2, and inherits the same logarithmic camera perspective as contextually sized opponents.
- Replaced the pitching limb with a short rectangular arm that moves toward the plate and releases each immutable projectile from its exact tip.
- Added a circular pitcher wind-up meter driven by authoritative release credit, alongside the existing plate-side batter-arrival meter. The pitcher meter yields while a ball is in flight or the plate is empty.
- Added On-Deck Hurry-Up as a sixth ordinary training axis, multiplying every batter replacement cooldown by ×0.985 per rank.
- Directed every outcome-specific batter exit toward the upper-right and each replacement entrance from the lower-left.
- Made the interface progressive: future opponents, purchases, currencies, automation, mutations, magic, clones, reality statistics, divine rewards, Rebirth controls, and Guide explanations remain hidden until their story boundary is reached.
- Removed premature body-cap and maximum-rank language. Reaching a velocity limit now leaves a clickable contextual explanation with a spoiler-light hint.
- Fixed tab switching and responsive layout: Stats no longer forces the tab panel wider, all pages keep one footprint, long content scrolls independently, and the projectile footer can no longer collapse into vertical letters.
- Added a progressive-interface audit that cycles every visible tab at fresh, genetic, eldritch, and divine states, checks reveal gating and geometry, and is required by the all-desktop packager.
- Rebalanced the loot-free first universe to a roughly 10-hour human clear and 7-day 4.5-hour cosmic victory, preserving eight meaningful lower-layer resets.

## 0.3.1 — One ball, one consequence

- Unified live simulation and rendering around authoritative pitch-release events, eliminating decorative low-rate balls with no matching outcome.
- Stopped all new pitches and rapid arm motion while the plate is empty, with no catch-up burst when a batter returns.
- Added a circular on-deck timer beside home plate that fills through each hit-specific replacement delay and accelerates with Time Compression.
- Expanded the bottom outcome headings and strikeout payout text from baseball abbreviations to full names.
- Tightened the opening camera from 3× to 3.6×, increased close-up ball scale, reduced the opening pitcher, and removed its oversized outer ring.
- Added regression coverage for autonomous-spawn prevention, exact release counts, empty-plate suppression, and the batter-arrival timer.
- Added repeatable macOS Universal, Windows x86_64/ARM64, and Linux x86_64/ARM64 packaging, a Google-Drive-ready all-platform bundle, portable save-transfer instructions, checksums, and a release manifest.

## 0.3.0 — Three strikes, several realities

- Rebuilt the economy so only a completed strikeout awards XP or opponent mastery. Partial strikes and every kind of hit award zero.
- Added Grand Slam above Home Run. It always ends the at-bat, clears the count, bypasses every protection effect, and creates the longest replacement delay.
- Kept all 30 human opponents at the canonical three-strike count, raised alien counts from four to nine, and gave the five eldritch opponents counts of 12, 18, 28, 42, and 64.
- Added Compressed Strike Genome, which removes one required post-human strike per rank without reducing the original strikeout bounty.
- Added Prehensile Outfield Reflex, which protects Singles, then Doubles, then Triples and holds the count.
- Made mirror clones catch an independently stacking share of ordinary hits and added Bullpen Portals as a second independent protection layer.
- Added strikeout, saved-hit, current-count, batter-cooldown, and six-outcome persistence in save version 7, with migration from the previous five-outcome model.
- Rebuilt dense simulation around complete at-bat renewal cycles, including saved balls, hit-specific downtime, long strike counts, and strikeout-only income.
- Changed multi-arm rendering to simultaneous volleys. Each released ball continues to snapshot immutable source, path, speed, color, and travel time.
- Added six distinct return paths and batter exits, compact numeric display for enormous eldritch counts, `COUNT LOST`/`COUNT HELD` calls, and returned-ball visuals for protected hits.
- Replaced the old Season/Rings layer with a three-tier story: genetic Time-Machine rebirth, reality-destroying eldritch ascension, and post-Octathulhu divine restoration.
- Added 11 genetic upgrades, 8 eldritch upgrades, 6 collectible divine blessings, and stackable Halos.
- Calibrated the first human finale to 211.6 mph, alien biology to Mach 12, and Octathulhu's final gate to exactly 1c.
- Expanded and renamed the 45-opponent campaign around Xylophax, N'Kthra, Ball-rog, and Octathulhu.
- Rebalanced the complete first universe to roughly ten days of active production, with a roughly 11.5-hour first human lifetime and meaningful intermediate DNA/Arcana harvests.
- Rewrote the regression, progression, first-lifetime, and full-multiverse audits around the new economy.

## 0.2.0 — The ladder fights back

- Rebuilt opponent difficulty around hand-tuned era anchors and a roughly ten-hour single-layer prototype campaign.
- Added fourteen pitch types, twelve ball evolutions, twelve equipment milestones, explicit opponent counters, normalized costs, and cosmic-victory state.
- Added deterministic progression, automation, save-migration, renderer, and large-offline-batch audits.

## 0.1.4 — The count is negotiable

- Added remaining-strike diamonds, strike depletion effects, refill timing, and a post-human count experiment.

## 0.1.3 — Please send another toddler

- Turned each opponent level into a class of rotating named batters with outcome-specific replacement timing and exit animation.

## 0.1.2 — Closer, shorter, and pointed the right way

- Maximized the window, enlarged typography, added the left loadout, moved range arrows onto the field, corrected the bat swing, shortened the arm, and matched ball release to the hand.

## 0.1.1 — The mound backs away

- Added 15 pitching distances, immutable projectiles, top-down logarithmic zoom, planetary/space backgrounds, straight opening throws, late anime arcs, distinct batters, returned balls, rounded costs, and exact effect text.

## 0.1.0 — Playable prototype

- Built the first automatic pitching loop, 45-opponent ladder, scalable GPU-instanced field, saving, offline progress, macOS export, and headless tests.
