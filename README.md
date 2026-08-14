# No Hitter

A top-down baseball idle game about beginning three feet from a toddler with a one-foot-per-second wiffle-ball apology and discovering how unreasonable baseball can become.

This repository contains the playable **v0.14.0 browser-parity build** for Godot 4.7.1. Ready-to-share packages for browsers, macOS, Windows, and Linux are generated in `release/` from one shared game codebase.

## Share or install on another computer

Upload this single file to Google Drive (or any ordinary file host):

```text
release/No Hitter v0.14.0 All Platforms.zip
```

It contains a static browser-site ZIP, a Universal Mac DMG, separate Intel/AMD and ARM Windows ZIPs, separate Intel/AMD and ARM Linux archives, source code, instructions, a platform manifest, and SHA-256 checksums. Recipients can play from an uploaded browser build or choose the native package matching their computer. Godot is not needed to play.

To rebuild every package after changing the game, run this from the project folder on a Mac:

```bash
./scripts/package_all_platforms.sh
```

The script runs the shared regression and progressive-interface suites; obtains the matching official Godot 4.7.1 export templates if they are absent; exports all six targets; checks the native binary architectures; smoke-tests the Mac build; verifies the browser payload and every archive; and produces the combined upload ZIP. After a successful desktop package, it deletes superseded generated release folders and archives while retaining the complete current version. Source history, saves, and the current playable build are unaffected. The first run may download about 1.2 GB of official export templates. See Godot's [command-line export documentation](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_projects.html), [Web export documentation](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html), and [4.7.1 download archive](https://godotengine.org/download/archive/4.7.1-stable/).

The native packages are portable builds, not store submissions. The Mac app is ad-hoc signed but not notarized, and the Windows executables are unsigned, so a recipient may need to confirm the first launch using the safe instructions included in the bundle. Warning-free public distribution would require Apple and Windows signing identities. Android, iPhone/iPad, and consoles require separate platform work and are not included.

## Play in a browser

`release/No Hitter v0.14.0/No Hitter v0.14.0 Browser.zip` is a static Progressive Web App with `index.html` at its root. Upload the ZIP contents unchanged to a static host such as itch.io or GitHub Pages. It uses Godot's preferred single-threaded Web export, so it needs no database or application server. On iPhone, its INSTALL menu explains Safari's Add to Home Screen flow; on Android, it opens the native install prompt when Chrome makes one available and otherwise gives the matching menu steps. Installed phone versions remain on the same five-minute Web update channel. While the game is visible, supported browsers also request a screen wake lock and reacquire it after returning to the tab. Visibility, page-hide/show, freeze, and resume events are recorded outside the frozen game loop, so returning from an iOS suspension reliably converts the wall-clock gap into offline progress even when Safari reports one giant frame. A running tab offers a reviewable update with separate Export, Later, and Update actions, flushes the primary/rollback save mirrors, and falls back cleanly if activation stalls. The title-screen Resume picker and the in-game SAVES menu both expose an autosave plus three device-local manual slots on desktop and phone; portable Export/Import remains the cross-device path. On iOS, selecting an exported backup directly from the Files picker can use Google Drive when the Drive provider is enabled in Files; a Web app cannot silently browse a private Drive account without a separately configured Google OAuth application.

To build only the browser package, or serve the current build locally:

```bash
./scripts/package_web.sh
./scripts/serve_web.sh
```

Then open `http://127.0.0.1:8001/`. WebAssembly and WebGL 2 are required; current Chromium-based browsers and Firefox are the primary targets. The browser and desktop packages contain the same scenes, content, simulation, progression, and save schema. Only the visual ceilings differ: desktop keeps the 4,000-projectile pool, while the browser draws up to 512 outbound representatives, 96 returns, 96 stars, and 16 clone bodies before aggregating presentation. Gameplay math remains exact.

### Publish with Codex Sites

The `sites-host/` project is a deliberately thin production shell around the verified Godot export. It does not duplicate gameplay: its build first checks `web/` against the shared Godot source, copies that exact export, divides the large WebAssembly runtime into host-safe segments, and serves the reassembled runtime as one ordinary `application/wasm` response. Codex Sites can therefore publish the game directly while GitHub Pages remains an independent fallback.

### Publish with GitHub Pages

The repository includes a tested static site in `web/` and a Pages workflow at `.github/workflows/pages.yml`. In the GitHub repository, open **Settings → Pages**, set **Source** to **GitHub Actions**, and run **Deploy browser game to GitHub Pages** (or push to `main`). The workflow checks both the shared-source manifest and every browser artifact before it deploys, so a stale browser export cannot silently publish.

`./scripts/package_web.sh` exports from the same Godot project used by the desktop packages, refreshes `web/`, and regenerates both manifests. To verify parity without rebuilding:

```bash
./scripts/verify_web_parity.sh
```

Commit the refreshed `web/` directory whenever gameplay source changes. The compiled WebAssembly file is deliberately stored in ordinary Git rather than Git LFS so GitHub Pages can deploy a self-contained site from a normal checkout.

## Play on macOS

1. Open `release/No Hitter v0.14.0 macOS Universal.dmg`.
2. Drag **No Hitter.app** to Applications, or run it from the disk image.
3. If macOS asks for confirmation, Control-click the app, choose **Open**, and confirm.

The app is ad-hoc signed rather than notarized with a paid Apple certificate. It supports Apple Silicon and Intel Macs and does not require Godot.

## The rule that drives everything

Only a completed strikeout awards XP. Every called Strike immediately banks one count-share of opponent mastery, but partial counts still award zero XP. Every hit awards neither XP nor mastery.

- Human batters always require three strikes.
- Fouls add a strike unless the batter already has two. Four Balls produce a walk, which ends the plate appearance like a Single without awarding XP.
- An unprotected hit clears the count and sends the batter away. Singles create a short gap, Home Runs a long one, and the new Grand Slam tier creates a twelve-second humiliation.
- Grand Slams are always terminal. No fielder, clone, portal, or divine blessing can save one.
- Alien batters require four through nine strikes. Genetic count compression can reduce post-human requirements, never below three, while preserving the original larger payout.
- Eldritch batters require 12, 18, 28, 42, and finally 64 strikes. Genetic fielders, mirror clones, and bullpen portals let ordinary hits preserve an unfinished count.

The eight compact outcome cards show only the name, live probability, and added lineup delay for Grand Slam, Home Run, Triple, Double, Single, Foul, Ball, and Strike. A separate small line shows the XP paid by a completed strikeout. Desktop details live in tooltips; phones expose the same explanations in closable tap-inspection sheets, including opponent equipment and compact profile data. Player-loot rows remain passive so mouse wheels and touch drags scroll normally. Separate Equip and Compare controls handle changes and open the bounded full-stat comparison.

## Campaign details (full spoilers)

The shipped interface reveals each layer only when its story encounter is reached. Developer documentation necessarily describes the complete progression; expand this section only if that is what you want.

<details>
<summary>Reveal the complete campaign and prestige rules</summary>


There are 45 opponent classes backed by era-specific, composable names and titles, producing thousands of readable individual batter identities.

1. **Human baseball, levels 1–30:** you begin as a regular ol’ toddler and may spend XP to grow through five optional human ages while facing backyard toddlers, youth leagues, school ball, college, the minors, and MLB. Each age changes the subtitle, body loadout, stats, and rendered size without raising the 211.6 mph human cap. Clearing the league without ever growing earns the secret **Past Your Bedtime** achievement.
2. **Xylophax, level 31:** a witnessed one-minute exhibition of guaranteed Grand Slams. Offline time cannot satisfy it and no amount of mastery or Frustration creates a lottery. A small red **HELP** button then appears; clicking it summons a portal stranger whose Time Machine permanently unlocks prenatal genetic rebirth.
3. **Alien baseball, levels 31–40:** genetic rebirths add arms, faster biology, fielding reflexes, count compression, and automation. Pitching rises through Mach notation toward a Mach 12 body limit.
4. **N'Kthra, level 41:** another unwinnable one-minute exhibition. Eldritch ascension destroys the current reality and moves your consciousness into another one.
5. **Eldritch baseball, levels 41–45:** mirror-reality bullpens, time compression, portals, causal baseballs, Ball-rog the Unstrikeable, and Octathulhu, God of the Eightfold Swing. Octathulhu only accepts a pitch at exactly light speed.
6. **God Prestige:** after Octathulhu falls, God thanks you for saving the universe, asks whether the best reward would be doing it all again, restores everything, and offers one permanent blessing. All six can be collected across later universes; additional victories award stackable Halos.

Genetic rebirth awards `floor((body XP / 10B)^(1/3))` DNA before multipliers. Eldritch ascension awards `floor((DNA earned in this reality)^0.60)` Arcana before multipliers. Genetic rebirth resets the body and Locker but preserves mutations; eldritch ascension also erases DNA and genetics but preserves magic; God Prestige erases both lower layers but preserves blessings, Halos, achievements, and lifetime statistics. Inherited Scorebook Cortex reduces each opponent's mastery target to 85% per rank, while excess farming begins at that same adjusted target. Reverse Terminator Wardrobe is the equipment exception: each rank carries one randomly selected equipped item through genetic time travel.

</details>

## Range, facilities, loot, and tactics

The campaign has 15 level-assigned distances, from 3 feet to 100,000 light-years. Selecting an opponent automatically selects that level's thematic range, preventing "always move closer" from becoming a mandatory income ritual. Farther stages multiply XP and increase batter threat. The opening 1 ft/s pitch genuinely takes three seconds to cross its three-foot gap. Later distances use logarithmic camera compression while Stats continues to show the true physical flight time.

Spend XP on six ordered body ages in **GROW UP**, nine additive fundamentals—speed, quality, active field tapping, recovery, offline efficiency, distance control, base lineup time, fair-hit delay, and pitch selection—twenty-two pitch types, twenty-six evolving ball shells, and eighty-six one-time facilities or increasingly indefensible interventions. Training unlocks gradually and keeps one ordinary purchase per displayed base stat. Repeatable Speed adds `0.50 ft/s`; repeatable Command adds only `0.04` quality, while actual velocity also improves quality. Facilities and long-term projects supply the larger multiplicative gains and savings goals, from neighborhood lessons through professional research campuses. Several ask for a measured speed, a campaign level that supplies a required range, or a strikeout achievement. Every tab is ordered by unlock level, then cost, and its entries remain effect-hidden until all stated requirements are met. Pitch, Ball, and Facility each include a saved Hide Purchased toggle that removes only completed one-time entries from that catalog. Costs are rounded to readable whole numbers, while descriptions state only the concrete arithmetic. Maximum ranks and body limits stay out of ordinary descriptions until they actually become relevant. Pitch, Ball, and Facility purchases have separate tabs. Every learned pitch enters the automatic arsenal, with Pitch Calling increasingly favoring stronger options. The Live Throw Profile is limited to the current immutable throw—pitch, release speed, plate speed, air drag, travel time, quality, and range—while all nine general trained stats remain in Status. The left loadout shows the player's current ball, arsenal, body, and facilities, and the batter's body, bat, and later equipment appear vertically on the batter's side. Genetic bodies and later reset layers occupy GROW UP but do not exist in visible UI copy until their story encounters have been completed.

The live XP balance keeps two decimal places only while it is below one point and uses whole XP below 1,000. Once suffixes begin, it keeps roughly three useful digits (`1.23K`, `1.6M`) so spending within the same million remains visible.

The Achievements tab contains 108 milestones spread across human, genetic, alien, eldritch, and divine play. Every completion permanently adds one percentage point to XP income, stacking additively and surviving every prestige reset. Achievement copy is a passive mouse-wheel/touch-drag surface; a bounded Details button opens inspection, and a saved Hide Achieved filter removes completed cards only. The tab always reports the complete 108-slot count, but an entry whose subject has not been encountered is shown only as `HIDDEN ACHIEVEMENT`: its name, condition, progress, description, and future-layer heading are withheld. The fully secret No Hitter challenge remains the final catalog entry: following a God Prestige restoration, clear the complete campaign through Octathulhu without allowing fair contact. Even a hit rescued by clones or a portal spoils that attempt. Unlocks produce a queued in-game toast and remain visible in Status and portable saves.

Click or tap unobstructed field space to hurry whichever foreground timer is active: wind-up, ball flight, or the complete next-batter handoff. A tap begins at 1.7% of that timer and produces a quick cyan ring at the input point. Field Hustle can raise one tap to 2.7%, but taps can provide only 50% of any timer; at least half always remains idle time.

Completed strikeouts also have a 12% chance to drop a wearable item; hits never do. The first career strikeout guarantees Little Timmy's Oversized Cap, and a pity roll guarantees a parcel by the tenth eligible dry roll. Drops show a brief rarity-colored field callout and never equip themselves. Six human slots—Hat, Jersey, Jock Strap, Glove, Pants, and Cleats—appear as compact letter squares at the field's lower-right. A seventh anonymous slot becomes a Relic after human baseball. An equipped square uses only its rarity color—Common gray, Magic blue, Rare gold, Legendary orange, or Unique purple—without a redundant icon. Clicking a square opens a slot-by-slot Locker whose aggregate loadout is explicitly separated from each item's bonuses. Item text is passive for easy phone scrolling; every row has bounded Equip, Compare, and protection-star controls. Browser mouseover shows all stats and signed differences from the equipped piece; holding a phone item for 0.55 seconds opens the same phone-safe comparison window, while ordinary taps and drags remain available for scrolling. The comparison window has explicit Swap, two-step Trash, and Keep actions. Every item has an integer Power derived from its real affixes; lists sort highest-Power first. Each slot keeps 10 items, and overflow removes the lowest-Power eligible item while equipped and starred items are protected. Cleared gear becomes persistent Scrap equal to item level times rarity value; Scrap is saved but intentionally has no spend yet. Legendary and Unique rolls are genuinely rare rather than routine. The genetic Autonomic Wardrobe Lobe is the optional auto-equip-best upgrade.

Mastery continues beyond an opponent's unlock target. Each doubling of excess mastery adds a small logarithmic strikeout-XP multiplier and improves rarity and affix-roll odds. The item level remains capped to the opponent being farmed, so an overmastered toddler can drop an unusually good level-one cap but never late-game gear.

Gear is a capped sidegrade: a complete loadout can add at most 15% speed, 18% recovery, 0.50 quality, 25% strikeout XP, 20% mastery, and 15% distance XP. Training and prestige can clear the complete campaign with loot disabled. Gear speed is applied after the body's era cap, so a good outfit can exceed 211.6 mph, Mach 12, or 1c without being required to reach any gate. Post-human Symbiotic Wardrobe Dermis multiplies item effects by 1.20 per rank before those aggregate caps. Mirror clones dilute aggregate equipment bonuses until One-Size-Fits-All-Realities Uniform teaches every clone how clothing works.

Moving backward to farm an easier opponent is always allowed and also restores that opponent's authored range. Advancing is tactical: a high-reward alien with a long count can be worse XP per second than a reliable earlier strikeout. Genetic **Migratory Baseball Instinct** purchases one human auto-advance destination per rank; eldritch **Interstellar Road-Trip Itinerary** purchases one alien destination per rank. **Autonomic Coaching Lobe** licenses independently selected Training auto-buy stats, one per rank, and **Front Office Outside Time** later unlocks independent Pitch, Ball, Facility, and Grow Up auto-buy switches. Auto-scouting remains a separate choice.

## Visual scalability contract

The simulation is the only source of outbound pitches. Human play follows one strict cycle: wind-up, choose a learned pitch, sample its exact speed, release one immutable ball, let it complete its whole flight, resolve it at the batter, and only then begin the next cooldown. The chosen pitch briefly appears over the pitcher and its speed remains in the field's upper-left. A release event contains no public outcome, so stopping the pitcher cannot telegraph a hit. The pitcher dial is cyan during wind-up and gold during flight; the separate home-plate dial fills while the next batter approaches. Missed strikes and Balls preserve their incoming screen speed and line beyond the batter, then fade gradually. No frame time, upgrade click, empty plate, or resumed animation can manufacture a ball or a catch-up burst.

After human baseball, extra arms, clones, and time layers provide potential throwing sources. Separate simultaneous-ball upgrades make progressively larger salvos usable, culminating in a designed 2,048-ball volley. The desktop GPU-instanced stream reserves 4,000 outbound projectiles, so it renders every designed outbound ball one-for-one. The browser profile reserves 512 and labels weighted representatives beyond that point; only drawing is reduced, never simulation, XP, mastery, or loot. Dense starfields and return volleys are batched, and only unreadable clone-limb detail is reduced when formations overlap. A ten-second native endgame stress profile measured 44–60 FPS across launch, impact, and return phases on the development Mac's Radeon Pro 560X, with most samples at 58–60; a fresh field remains locked at 60 FPS. A separate **20,000 balls/second** safety ceiling keeps all economy math finite.

Every released projectile snapshots its pitch type, source, exact randomized release speed, release range, air drag, plate speed, duration, curve, trail, and color. Human fields model air resistance; alien and eldritch vacuum fields do not. Upgrades affect future throws only. Choosing another unlocked batter immediately sets that level's range for future pitches and retargets the unresolved interaction, but the ball already in flight keeps its original distance, drag, path, and timing. The opening throw is one large, nearly straight ball with no fake trail. Extra arms release simultaneous volleys from separate hands; clones and time layers unlock progressively wider anime salvos and missile streaks. Fair hits and Fouls send visible balls back into the field, while saved hits return toward the bullpen and preserve the count.

The camera begins at a 3.6× close-up. Character rings have a separate close-range ceiling so neither player covers home plate; the ball and environment retain the stronger zoom. Pitcher and batter share the same point-and-ring graphic language, and the fresh toddler pitcher remains about 50% larger than the opposing toddler for readability. Purchased ages establish progressively larger body-size floors, while trained strength, equipment payload, extra arms, clones, and time layers continue a saturating climb toward twice the original intrinsic size. Batter size remains class- and era-specific, from small children through huge aliens and gods, and both sides share the same distance perspective. The pitching arm is a short bat-like rectangle that drives forward, and the ball leaves from its exact tip. Level progression moves the mound and zooms out automatically so later formations and contextually huge opponents remain legible. Departed batters clear toward the upper-right and replacements enter from the lower-left. Human leagues use muted grass; later environments change only when their campaign layers are revealed. The title screen follows the same rule: its animated abstract matchup changes with the farthest discovered era and never previews aliens, the void, or divine baseball before the player has reached them.

The 1600×1000 installed interface opens maximized with a 1280×800 desktop minimum. On a portrait browser viewport, the field turns vertically so the pitcher is below the batter; desktop sidebars become touch-sized Upgrades, Status, Log, and Saves overlays, and outcome cards wrap into two rows. Upgrade overlays retain the live XP balance and use explicit 44-pixel controls around a large current-section card. Mound movement becomes a stacked up/down control to the pitcher's right, and the equipment browser uses an in-content Close action that stays clear of iOS window chrome. Update warnings use phone-bounded copy and actions. This responsive layer changes presentation only. Future campaign currencies, statistics, upgrade lists, and Guide text remain hidden until their corresponding story reveal.

## Run from source

Install Godot 4.7.1 and open `project.godot`, or run:

```bash
godot --path .
```

Development-only profiles disable saving:

```bash
godot --path . -- --fresh
godot --path . -- --stress-render
```

## Verification

```bash
godot --headless --path . --script res://tests/test_runner.gd
godot --headless --path . --script res://tests/balance_runner.gd
godot --headless --path . --script res://tests/multiverse_balance_runner.gd
godot --headless --path . --script res://tests/progression_audit.gd
godot --headless --path . --script res://tests/ui_runner.gd -- --fresh
godot --headless --path . --script res://tests/mobile_ui_runner.gd -- --fresh
```

The regression suite covers all eight outcomes, strikeout-only XP, per-Strike mastery, matchup adaptation, outcome-weighted logarithmic Frustration, optional body aging and its visual/stat effects, the toddler-only league clear, Foul and Ball counts, walks, hit resets, protected counts, Grand Slam immunity, both witnessed HELP transitions, randomized pitch selection, immutable release/plate-speed/drag snapshots, the release/flight/impact state machine, capped field-tap acceleration and synchronized tap cues, one-live-ball human rules, post-human 2,048-ball volleys, level-assigned ranges and opponent retargeting, constant-speed misses, empty-plate suppression, both visible timers, replacement timing and direction, randomized opponent loadouts, deterministic high-variety era naming, all five loot tiers, Power sorting, rarity-colored slots, no-auto-equip drops, equipment caps/amplification/clone dilution, starred 10-item pruning, Scrap, adjusted mastery targets, post-cap mastery farming, all 108 achievement IDs and exact additive rewards, licensed human/alien auto-advance capacity, per-stat/per-catalog automation, God Prestige, No Hitter clean-run invalidation, secret disclosure, explicit scroll-safe actions, saved catalog and achievement filters, typed hard reset, schema migration and protected recovery generations, cross-platform manual slots, title-screen save selection and spoiler-gated art, iOS-style giant-delta offline recovery, offline-efficiency rewards, cosmic completion, and seven-day aggregate simulation. The desktop interface audit clicks every visible tab at every reveal layer and checks stable size, bounds, hover comparison data, explicit item and upgrade actions, the HELP scene, offline-return summary, tier catalogs, anonymous achievement cards, unlock toasts, and spoiler gating; the portrait audit checks the rotated lane, phone overlays, scroll-safe passive rows, hold-to-inspect, touch-sized actions and filters, current-section cards, bounded update warnings, compact controls, manual save slots, and lossless return to desktop layout.

The deterministic greedy benchmarks explicitly disable loot, proving that perfect gear—or any gear—is not a progression requirement. With the velocity/Command split, expensive project lane, per-Strike adaptation, level-assigned ranges, and larger mastery targets active, the v0.14.0 human lifetime reaches the first alien exhibition after roughly 26 hours 30 minutes, while the complete multi-reset audit reaches cosmic victory after roughly 49 days 6 hours. The full audit is documented in [docs/BALANCE.md](docs/BALANCE.md) and [docs/DESIGN.md](docs/DESIGN.md).

## Save data

The game autosaves every ten seconds, saves and mirrors on exit or browser backgrounding, and simulates up to seven days of offline progress. The Web bridge records page visibility outside Godot so iOS page-hide/show, freeze/resume, and giant resumed-frame deltas all recover the same wall-clock gap exactly once. Offline strikeout XP starts at 1% of the normal open-game award; the level-5 Scorebook Study training adds one percentage point per rank up to 25% for the current body. Returning with earned XP opens a summary showing time away, XP deposited, and the efficiency used. **EXPORT** writes a portable, readable JSON backup; **LOAD** validates a selected backup and shows its version, level, and XP before asking permission to replace the current run.

Each automatic write is validated before replacing the primary file and retains the previous valid generation. Unreadable data is preserved rather than overwritten, an older cached build refuses to replace a newer save schema, and autosaving locks if no valid generation can be recovered. Browser builds add rotating primary/rollback localStorage mirrors to IndexedDB and recover a mirror that demonstrably contains more lifetime progress. Installed phone Web apps additionally expose three manual local slots with their level, spendable XP, and timestamp; Export remains the cross-device backup. Before activating a cached browser update, the game recommends Export, mirrors the save, requests an IndexedDB flush, and waits before reloading. The UI also warns if the browser reports non-persistent storage. On macOS the ordinary local save is normally at:

```text
~/Library/Application Support/Godot/app_userdata/One Foot Per Second/one_foot_per_second_save.json
```

Save version 21 preserves body age, the toddler-clear proof, exact in-flight plate speed/drag, selected auto-buy settings, and licensed human/alien auto-advance capacity. Version-20's former one-purchase all-human Auto-advance migrates to all 29 human destination licenses. Earlier saves retain every resource, achievement, clean No Hitter eligibility, lifetime trigger counter, peak record, catalog filter, protected primary/rollback generation, and prior migration. The renamed game intentionally continues using the original `One Foot Per Second` application-data directory and `one_foot_per_second_save.json` filename, so existing installed saves need no manual move. Older saves silently backfill every achievement provable from persisted history without producing a wall of unlock popups; their first certifiable No Hitter attempt begins after the next God Prestige. All earlier migration behavior remains intact, including age inference, Frustration conversion, Field Hustle and offline-efficiency defaults, Scrap, additive Training conversion, batter-cooldown splitting, quality-rank consolidation, Belt-to-Jock-Strap conversion, added outcomes, and retired prestige mappings.
