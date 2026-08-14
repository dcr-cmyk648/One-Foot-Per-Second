# Changelog

## 0.12.0 — The title is also a threat

- Renamed the game **No Hitter** across the live interface, install metadata, native packages, browser manifest, documentation, and Sites shell. Existing browser URLs, app identifiers, and the original local-data directory remain stable so installed saves continue working.
- Added exactly 101 permanent achievements across the complete human, genetic, alien, eldritch, and divine campaign. Each completion adds one additive percentage point to all XP income and survives every prestige layer.
- Added the fully secret `No Hitter` achievement: after a divine restoration begins a clean attempt, defeat the complete campaign through Octathulhu without allowing any fair hit. Clone- or portal-saved contact still spoils the attempt; known prestige exhibitions pause for their reset instead of forcing scripted hits on repeat universes.
- Added a dedicated achievement browser with live progress, completed styling, tier totals, a permanent-bonus summary, and queued gold unlock toasts.
- The browser always shows all 101 achievement slots, but undiscovered subjects are represented only as `HIDDEN ACHIEVEMENT`. Their real name, description, requirement, progress, future tier heading, and tooltip remain anonymous until encountered or completed.
- Achievement toasts now put the exact completed condition in smaller text beneath the achievement name.
- Reduced active field-tap power to one third of its former value: 1.7% initially and 2.7% with maximum Field Hustle. Taps explicitly accelerate recovery, immutable flight, and the full next-batter handoff while keeping the authoritative and visible lineup timers synchronized.
- Corrected Grand Slam's desktop and phone inspection text to say explicitly that no fielder, clone, portal, or blessing can save it; Home Runs retain ordinary hit-save behavior.
- Removed the native phone TabBar entirely, including its persistent miniature overflow arrows. The large accessible controls now show the current tab and position themselves.
- Rotated batter exits and entrances with the portrait field so hit batters leave along the correct phone foul side and replacements approach from the opposite side.
- Every called Strike now banks one count-share of opponent mastery even before the strikeout is complete. Mastery immediately improves the odds against that exact batter on an uncapped logarithmic curve; authored mastery targets increased by 12% to preserve the campaign's intended length.
- Added an uncapped logarithmic Frustration bonus that grows during a strikeout drought, resets on a completed strikeout, and appears in the compact strip beneath the outcome cards. Its asymptotic meter communicates diminishing returns without pretending the bonus has a hard cap.
- Rebuilt catalog entries as passive scrollable descriptions with separate touch-sized Buy buttons, preventing a phone drag from purchasing an upgrade while keeping the spend action obvious.
- Retuned generated human identities toward ordinary names, initials, and family names, reserving ornate epithets and increasingly strange structures for later eras while preserving authored bosses.
- Added an explicit browser-update review warning recommending a portable Export first, a synchronous secondary save mirror, a longer IndexedDB flush window, and automatic recovery when the primary browser filesystem unexpectedly starts empty.
- Added three manual save slots to the installed phone Web interface. Each slot shows its level, spendable XP, and timestamp and can be saved or staged for confirmation without replacing portable Export/Load.
- Added persistent lifetime counters and peak records for active field taps, saved hits, pitch speed, mound distance, and loot rarity. Save version 16 preserves clean-run eligibility, migrates older runs, and silently backfills only achievements their saved history can prove.
- Added a saved per-tab `HIDE PURCHASED` toggle to Pitch, Ball, and Facility. Each filter hides only completed one-time entries in its own catalog while preserving locked and available options.
- Extended the full regression and interface matrix to validate catalog size and uniqueness, exact additive XP math, prestige permanence, secret reveal rules, save migration, anonymous desktop/phone cards, touch-sized filters, and unlock toasts.
- Re-audited no-loot pacing with achievements, per-Strike adaptation, and Frustration active: the first human lifetime reaches Xylophax in roughly 41 hours 30 minutes, and the complete deterministic multiverse reaches cosmic victory in roughly 58 days 15 hours.

## 0.10.9 — The pants have a nametag

- Mobile Locker rows now reserve a high-contrast two-line summary with the complete item name followed by Power, rarity, and item level; Compare is no longer required to identify a drop.
- The phone Upgrades overlay now pins all nine current effective stats above the tabs so every purchase can be evaluated without closing the menu.
- Removed the TabBar's tiny native overflow arrows on phone layouts. The explicit 44-pixel previous/next controls are now the only mobile upgrade-tab navigation.
- Clicking or tapping open field space now advances the active recovery, flight, or batter-lineup timer by 5% and draws a brief expanding ring at the exact input point. Taps are hard-capped to half of each timer, preserving the idle pace.
- Added the early-human Field Hustle training axis: six ranks add 0.5 percentage points per tap, reaching 8% without raising the per-timer 50% contribution cap.

## 0.10.8 — The pants demand informed consent

- Loot no longer auto-equips into empty slots. New drops produce a compact rarity-colored field callout; automatic highest-Power equipment remains available only through Autonomic Wardrobe Lobe.
- Rebuilt Locker rows as passive, scroll-friendly item text with separate touch-sized Equip, Compare, and protection-star controls. Desktop browser hover shows the complete stat comparison. Phone/S-Pen layouts suppress the covering native tooltip; a stationary 0.55-second hold opens the comparison without consuming touch events, while an eight-pixel drag cancels inspection so scrolling remains native.
- Added a borderless, phone-contained item comparison window showing all six candidate stats beside the currently equipped piece with signed changes, full names, Power, rarity, level, and explicit Equip/Swap, Keep, and two-step Trash actions.
- Separated `EQUIPPED ITEM`, `THIS ITEM`, and `TOTAL LOADOUT BONUSES` throughout the Locker so aggregate effects cannot be mistaken for one piece's affixes.
- Added persistent Scrap. Automatic overflow clearing and manual Trash award item level multiplied by Common/Magic/Rare/Legendary/Unique values of 1/3/8/20/50; the saved bank is visible in the Locker and deliberately has no spend yet.
- Added Inherited Scorebook Cortex, a three-rank genetic upgrade that multiplies actual mastery requirements by 0.85 per rank. Bars, unlock checks, cosmic completion, and overmastery farming share the adjusted threshold.
- Added Symbiotic Wardrobe Dermis, a four-rank post-human node that multiplies equipment effects by 1.20 per rank before the existing moderate aggregate caps.
- Replaced the short repeating batter-name loop with deterministic era-aware component pools and sixteen formats, covering mononyms, initials, nicknames, origins, ordinary names, and increasingly absurd titles without destabilizing save files.
- Replaced the short repeating batter-name rotation with a deterministic, era-aware combinatorial generator. Sixteen formats mix single names, first/last names, middle names or initials, nicknames, origins, titles, and Elden-Ring-style epithets while preserving every authored signature boss.
- Extended offline summaries and live loot calls with recovered Scrap, advanced the save schema to version 14, and added migration, loot, prestige, comparison-window, and phone-scroll regression coverage.

## 0.10.7 — The dugout has thumbs now

- Browser flight impacts now resolve on the exact rendered arrival frame instead of waiting as long as one coarse idle-simulation tick after the visible ball reaches the plate.
- Locker favorite stars and all remaining lock/check/direction markers now use plain text or code-drawn icons, eliminating browser missing-font boxes throughout the interface.

- Rebalanced Little Timmy from roughly a 30.5% to a 40% called-Strike chance, raising the complete opening at-bat's strikeout chance above 10%. The first strikeout now pays 5 XP instead of 15; early base payouts add one XP per opponent until the ordinary three-Strikes-times-five bounty resumes at level 11.
- Replaced the tiny phone upgrade-tab affordances with explicit 44-by-44 previous and next controls, while keeping the current spendable XP visible in the Upgrades overlay.
- Removed font-dependent direction glyphs from browser navigation. Batter selection and upgrade traversal now use code-drawn back/forward icons, while mound movement uses code-drawn left/right or portrait up/down controls; every phone target is at least 44 pixels and the mound pair stays stacked to the pitcher's right.
- Compacted long overmastery summaries and reduced the portrait field minimum just enough to keep the header, full game view, outcomes, and bottom navigation together at 390×844; tapping the compact mastery line opens its complete explanation.
- Made the phone equipment browser borderless and added a large in-content Close button, so iOS status chrome cannot make its only exit unreachable.
- Added closable tap-inspection sheets that reuse desktop tooltip explanations for result cards, opponent equipment, live profile rows, stat help, and loadout summaries.
- Added Android Progressive Web App installation through Chrome's native prompt with an on-device fallback guide. The 192-pixel manifest icon and existing service-worker update path keep installed Android copies web-updated alongside iPhone Home Screen copies.
- Added a best-effort Screen Wake Lock request while a browser game is visible, with automatic reacquisition after tab or app suspension and another attempt on player input.
- Expanded the portrait interface audit across mobile installation states, XP visibility, tab traversal, mound controls, tappable details, and the equipment-window escape path.

## 0.10.6 — The scorebook does not study itself

- Offline strikeout XP now begins at 1% of the normal open-game award instead of silently paying the full rate. Exact plate appearances, mastery, loot, batter state, and the seven-day catch-up window remain simulated.
- Added the level-gated Scorebook Study fundamental. Each of its 24 ranks adds one percentage point of offline XP efficiency, raising the current body's rate from 1% to 25%.
- Added Offline to the compact field profile and full Stats view, with a plain-language tooltip explaining what the percentage controls.
- Returning after offline XP was earned now opens a responsive summary with the exact XP deposited, elapsed time, efficiency used, completed strikeouts, and any locker parcels found.
- Split accelerated foreground pacing audits from genuine offline catch-up, and added reward-multiplier, save-default, popup, and compact-interface regression coverage.

## 0.10.5 — Put baseball on the Home Screen

- Added an INSTALL action to the browser phone menu on eligible iPhones, with concise Safari Share → Add to Home Screen instructions.
- The install action automatically stays hidden on non-iOS platforms and when the game is already running as a standalone Home Screen app.
- Added iPhone web-app metadata, Apple touch-icon validation, standalone-manifest validation, and a portable-save warning for possible iOS storage separation.

## 0.10.4 — Wide means wide again

- Fixed a responsive-state lock that could leave a 720-pixel-tall browser in compact mode forever after the window had once crossed the narrow breakpoint.
- Compact mode now returns to the full interface at the measured-safe 1280×696 boundary, while an already-wide window retains a small width-only buffer to prevent resize flicker.
- Added regression coverage for compact-to-wide resize sequences at ordinary browser heights.

## 0.10.3 — Everything fits in the ballpark

- Replaced the one-pixel wide/compact switch with measured-safe width and height thresholds plus a small hysteresis band, eliminating clipped right panels and resize flicker at the boundary.
- Added a dense wide-browser layout that keeps the full loadout, field, upgrades, outcomes, and event log visible in one viewport down to the smallest width that is allowed to retain wide mode.
- Flattened the save, export, load, and reset controls into one compact header row and removed unused header height.
- Compressed every outcome card to two lines by placing its lineup-delay time beside the outcome name. Compact landscape mode now keeps all eight probabilities in one row, while phones retain the readable four-by-two grid.
- Added edge-case layout coverage for both sides of the breakpoint, the full hysteresis range, late-game prestige metrics, and the longest final-boss presentation.

## 0.10.2 — The browser remembers it is a window

- Made resized browser windows switch to the compact overlay interface whenever width or height can no longer hold the desktop panels. The whole page now has vertical overflow access as a final safety net, so controls cannot become permanently cropped below a short window.
- Kept the milestone subtitle visible beneath the title on every layout. It begins with “A baseball game about a regular ol’ guy,” becomes “A baseball game about a big boi” after the first steroid purchase, and continues changing only after the matching alien, genetic, eldritch, and divine discoveries.
- Removed the redundant checkmark from equipped field slots. Their letters remain stable and their rarity-colored border continues to show what is equipped at a glance.
- Added a checked-in Codex local-environment action named Open Game with the play icon. It launches the current native build on demand and falls back to the Godot project when no export exists; builds no longer need to be opened automatically after an update.
- Added regression coverage for ordinary resized landscape windows, page overflow access, phone subtitle visibility, milestone copy, and icon-free equipped slots.

## 0.10.1 — Retina remembers that pixels have density

- Fixed high-density browser displays treating device pixels as interface pixels. The Web build now applies the browser display scale to its fluid canvas, so iPhone text, controls, and character models render at readable CSS-pixel size instead of shrinking by the device pixel ratio.
- Narrowed the phone's Live Throw Profile so it clears the centered pitcher while retaining every base statistic.
- Moved the opening pitcher's rectangular throwing arm to the right-handed side in both portrait and landscape field orientations, without changing any pitch mechanics.
- Added an update-aware Progressive Web App export. Open browser games check for a new release every five minutes, show a compact opt-in update banner, save and flush the run before activating it, and keep the existing build playable offline while an update waits.
- Extended the portrait-interface audit to enforce the compact profile clearance, high-density scale normalization, right-handed arm orientation, and phone-safe update prompt.

## 0.10.0 — The ballpark turns sideways

- Added a browser-only responsive phone interface. Portrait play rotates the field into a vertical lane with the pitcher below and batter above, while desktop and installed builds retain the established top-down landscape layout.
- Replaced phone-width sidebars with full-screen Upgrades, Loadout, Event Log, and Save overlays reachable from a persistent touch-sized navigation row. Outcome cards wrap into a legible grid and secondary renderer text yields space to the game.
- Kept phone presentation on the shared Godot scene and simulation rather than creating a second game. Saves, unlocks, economy, content, input, pitch physics, and every nonvisual rule remain identical across browser and native exports.
- Added a dedicated portrait-interface regression suite covering field orientation, overlay reparenting, compact controls, and restoration of the desktop layout.
- Added an OpenAI Sites hosting shell that embeds the verified Godot export and streams its large WebAssembly runtime from host-safe segments. The Sites build refuses stale browser artifacts, while GitHub Pages remains a static fallback from the same checked-in export.

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
