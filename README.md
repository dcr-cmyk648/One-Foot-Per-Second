# One Foot Per Second

A top-down baseball idle game about beginning three feet from a toddler with a one-foot-per-second wiffle-ball apology and discovering how unreasonable baseball can become.

This repository contains the playable **v0.11.0 browser-parity build** for Godot 4.7.1. Ready-to-share packages for browsers, macOS, Windows, and Linux are generated in `release/` from one shared game codebase.

## Share or install on another computer

Upload this single file to Google Drive (or any ordinary file host):

```text
release/One Foot Per Second v0.11.0 All Platforms.zip
```

It contains a static browser-site ZIP, a Universal Mac DMG, separate Intel/AMD and ARM Windows ZIPs, separate Intel/AMD and ARM Linux archives, source code, instructions, a platform manifest, and SHA-256 checksums. Recipients can play from an uploaded browser build or choose the native package matching their computer. Godot is not needed to play.

To rebuild every package after changing the game, run this from the project folder on a Mac:

```bash
./scripts/package_all_platforms.sh
```

The script runs the shared regression and progressive-interface suites; obtains the matching official Godot 4.7.1 export templates if they are absent; exports all six targets; checks the native binary architectures; smoke-tests the Mac build; verifies the browser payload and every archive; and produces the combined upload ZIP. The first run may download about 1.2 GB of official export templates. See Godot's [command-line export documentation](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_projects.html), [Web export documentation](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html), and [4.7.1 download archive](https://godotengine.org/download/archive/4.7.1-stable/).

The native packages are portable builds, not store submissions. The Mac app is ad-hoc signed but not notarized, and the Windows executables are unsigned, so a recipient may need to confirm the first launch using the safe instructions included in the bundle. Warning-free public distribution would require Apple and Windows signing identities. Android, iPhone/iPad, and consoles require separate platform work and are not included.

## Play in a browser

`release/One Foot Per Second v0.11.0/One Foot Per Second v0.11.0 Browser.zip` is a static Progressive Web App with `index.html` at its root. Upload the ZIP contents unchanged to a static host such as itch.io or GitHub Pages. It uses Godot's preferred single-threaded Web export, so it needs no database or application server. On iPhone, its INSTALL menu explains Safari's Add to Home Screen flow; on Android, it opens the native install prompt when Chrome makes one available and otherwise gives the matching menu steps. Installed phone versions remain on the same five-minute Web update channel. While the game is visible, supported browsers also request a screen wake lock and reacquire it after returning to the tab. A running tab offers to save, activate a newly cached build, and reload; it never interrupts a pitch with a forced update.

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

1. Open `release/One Foot Per Second v0.11.0 macOS Universal.dmg`.
2. Drag **One Foot Per Second.app** to Applications, or run it from the disk image.
3. If macOS asks for confirmation, Control-click the app, choose **Open**, and confirm.

The app is ad-hoc signed rather than notarized with a paid Apple certificate. It supports Apple Silicon and Intel Macs and does not require Godot.

## The rule that drives everything

Only a completed strikeout awards XP or opponent mastery. Partial strikes award nothing. Every hit awards nothing.

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

1. **Human baseball, levels 1–30:** backyard toddlers, youth leagues, school ball, college, the minors, and MLB. The first body reaches its hard limit at 211.6 mph—twice the 105.8 mph fastest pitch used as the real-world calibration—and faces Bambino Rex.
2. **Xylophax, level 31:** a one-minute courtesy exhibition of guaranteed Grand Slams. Xylophax then offers prenatal genetic engineering and a Time Machine, because the modifications have to begin when you are a baby.
3. **Alien baseball, levels 31–40:** genetic rebirths add arms, faster biology, fielding reflexes, count compression, and automation. Pitching rises through Mach notation toward a Mach 12 body limit.
4. **N'Kthra, level 41:** another unwinnable one-minute exhibition. Eldritch ascension destroys the current reality and moves your consciousness into another one.
5. **Eldritch baseball, levels 41–45:** mirror-reality bullpens, time compression, portals, causal baseballs, Ball-rog the Unstrikeable, and Octathulhu, God of the Eightfold Swing. Octathulhu only accepts a pitch at exactly light speed.
6. **Divine restoration:** after Octathulhu falls, God restores everything and offers one permanent blessing. All six can be collected across later universes; additional victories award stackable Halos.

Genetic rebirth awards `floor((body XP / 10B)^(1/3))` DNA before multipliers. Eldritch ascension awards `floor((DNA earned in this reality)^0.60)` Arcana before multipliers. Genetic rebirth resets the body and Locker but preserves mutations; eldritch ascension also erases DNA and genetics but preserves magic; divine restoration erases both lower layers but preserves divine rewards and lifetime statistics. Inherited Scorebook Cortex reduces each opponent's mastery target to 85% per rank, while excess farming begins at that same adjusted target. Reverse Terminator Wardrobe is the equipment exception: each rank carries one randomly selected equipped item through genetic time travel.

</details>

## Range, facilities, loot, and tactics

The mound has 15 selectable distances, from 3 feet to 100,000 light-years. Farther ranges multiply XP and increase batter threat. The opening 1 ft/s pitch genuinely takes three seconds to cross its three-foot gap. Later distances use logarithmic camera compression while Stats continues to show the true physical flight time.

Spend XP on nine additive fundamentals—speed, quality, active field tapping, recovery, offline efficiency, distance control, base lineup time, fair-hit delay, and pitch selection—fourteen pitch types, twenty-six evolving ball shells, and forty-two one-time facilities or increasingly indefensible interventions. Training unlocks gradually and keeps one ordinary purchase per displayed base stat. Facilities are rarer, expensive multipliers meant to feel consequential; several ask for a measured speed, a farther mound, or a strikeout achievement as well as a level. Every tab is ordered by unlock level, then cost, and its entries remain effect-hidden until all stated requirements are met. Pitch, Ball, and Facility each include a saved Hide Purchased toggle that removes only completed one-time entries from that catalog. Costs are rounded to readable whole numbers, while descriptions state only the concrete arithmetic. Maximum ranks and body limits stay out of ordinary descriptions until they actually become relevant. Pitch, Ball, and Facility purchases have separate tabs. Every learned pitch enters the automatic arsenal, with Pitch Calling increasingly favoring stronger options. The field's subtle live profile exposes all nine trained stats, the left loadout shows the player's current ball, arsenal, body, and facilities, and the batter's body, bat, and later equipment appear vertically on the batter's side.

The Achievements tab contains 100 milestones spread across human, genetic, alien, eldritch, and divine play. Every completion permanently adds one percentage point to XP income, stacking additively and surviving every prestige reset. The tab always reports the complete 100-slot count, but an entry whose subject has not been encountered is shown only as `HIDDEN ACHIEVEMENT`: its name, condition, progress, description, and future-layer heading are withheld. Unlocks produce a queued in-game toast and remain visible in Stats and portable saves.

Click or tap unobstructed field space to hurry the active wind-up, ball flight, or batter-lineup timer by 5% and produce a quick cyan ring at the input point. Field Hustle can raise one tap to 8%, but taps can provide only 50% of any timer; at least half always remains idle time.

Completed strikeouts also have a 12% chance to drop a wearable item; hits never do. The first career strikeout guarantees Little Timmy's Oversized Cap, and a pity roll guarantees a parcel by the tenth eligible dry roll. Drops show a brief rarity-colored field callout and never equip themselves. Six human slots—Hat, Jersey, Jock Strap, Glove, Pants, and Cleats—appear as compact letter squares at the field's lower-right. A seventh anonymous slot becomes a Relic after human baseball. An equipped square uses only its rarity color—Common gray, Magic blue, Rare gold, Legendary orange, or Unique purple—without a redundant icon. Clicking a square opens a slot-by-slot Locker whose aggregate loadout is explicitly separated from each item's bonuses. Item text is passive for easy phone scrolling; every row has bounded Equip, Compare, and protection-star controls. Browser mouseover shows all stats and signed differences from the equipped piece; holding a phone item for 0.55 seconds opens the same phone-safe comparison window, while ordinary taps and drags remain available for scrolling. The comparison window has explicit Swap, two-step Trash, and Keep actions. Every item has an integer Power derived from its real affixes; lists sort highest-Power first. Each slot keeps 10 items, and overflow removes the lowest-Power eligible item while equipped and starred items are protected. Cleared gear becomes persistent Scrap equal to item level times rarity value; Scrap is saved but intentionally has no spend yet. Legendary and Unique rolls are genuinely rare rather than routine. The genetic Autonomic Wardrobe Lobe is the optional auto-equip-best upgrade.

Mastery continues beyond an opponent's unlock target. Each doubling of excess mastery adds a small logarithmic strikeout-XP multiplier and improves rarity and affix-roll odds. The item level remains capped to the opponent being farmed, so an overmastered toddler can drop an unusually good level-one cap but never late-game gear.

Gear is a capped sidegrade: a complete loadout can add at most 15% speed, 18% recovery, 0.50 quality, 25% strikeout XP, 20% mastery, and 15% distance XP. Training and prestige can clear the complete campaign with loot disabled. Gear speed is applied after the body's era cap, so a good outfit can exceed 211.6 mph, Mach 12, or 1c without being required to reach any gate. Post-human Symbiotic Wardrobe Dermis multiplies item effects by 1.20 per rank before those aggregate caps. Mirror clones dilute aggregate equipment bonuses until One-Size-Fits-All-Realities Uniform teaches every clone how clothing works.

Moving backward to farm an easier opponent is always allowed. Advancing is tactical: a high-reward alien with a long count can be worse XP per second than a reliable earlier strikeout. Genetic automation can advance, train, and select the best opponent/range pair while the game is running.

## Visual scalability contract

The simulation is the only source of outbound pitches. Human play follows one strict cycle: wind-up, choose a learned pitch, sample its exact speed, release one immutable ball, let it complete its whole flight, resolve it at the batter, and only then begin the next cooldown. The chosen pitch briefly appears over the pitcher and its speed remains in the field's upper-left. A release event contains no public outcome, so stopping the pitcher cannot telegraph a hit. The pitcher dial is cyan during wind-up and gold during flight; the separate home-plate dial fills while the next batter approaches. Missed strikes and Balls preserve their incoming screen speed and line beyond the batter, then fade gradually. No frame time, upgrade click, empty plate, or resumed animation can manufacture a ball or a catch-up burst.

After human baseball, extra arms, clones, and time layers provide potential throwing sources. Separate simultaneous-ball upgrades make progressively larger salvos usable, culminating in a designed 2,048-ball volley. The desktop GPU-instanced stream reserves 4,000 outbound projectiles, so it renders every designed outbound ball one-for-one. The browser profile reserves 512 and labels weighted representatives beyond that point; only drawing is reduced, never simulation, XP, mastery, or loot. Dense starfields and return volleys are batched, and only unreadable clone-limb detail is reduced when formations overlap. A ten-second native endgame stress profile measured 44–60 FPS across launch, impact, and return phases on the development Mac's Radeon Pro 560X, with most samples at 58–60; a fresh field remains locked at 60 FPS. A separate **20,000 balls/second** safety ceiling keeps all economy math finite.

Every released projectile snapshots its pitch type, source, exact randomized speed, duration, curve, trail, and color. Upgrades affect future throws only. Mound arrows can move the pitcher while that ball continues unchanged, and choosing another unlocked batter retargets the unresolved interaction without inventing another pitch. The opening throw is one large, nearly straight ball with no fake trail. Extra arms release simultaneous volleys from separate hands; clones and time layers unlock progressively wider anime salvos and missile streaks. Fair hits and Fouls send visible balls back into the field, while saved hits return toward the bullpen and preserve the count.

The camera begins at a 3.6× close-up. Pitcher and batter share the same point-and-ring graphic language; the fresh pitcher is about 50% larger than the toddler and grows smoothly with strength toward twice the original size. The pitching arm is a short bat-like rectangle that drives forward, and the ball leaves from its exact tip. Small arrows beside the pitcher move the mound. Backing away zooms out so later formations and contextually huge opponents remain legible. Departed batters clear toward the upper-right and replacements enter from the lower-left. Human leagues use muted grass; later environments change only when their campaign layers are revealed.

The 1600×1000 installed interface opens maximized with a 1280×800 desktop minimum. On a portrait browser viewport, the field turns vertically so the pitcher is below the batter; desktop sidebars become touch-sized Upgrades, Loadout, Log, and Save overlays, and outcome cards wrap into two rows. Upgrade overlays retain the live XP balance and use explicit 44-pixel tab controls. Mound movement becomes a stacked up/down control to the pitcher's right, and the equipment browser uses an in-content Close action that stays clear of iOS window chrome. This responsive layer changes presentation only. Future campaign tabs, currencies, statistics, upgrade lists, and Guide text remain hidden until their corresponding story reveal.

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

The regression suite covers all eight outcomes, strikeout-only rewards, Foul and Ball counts, walks, hit resets, protected counts, Grand Slam immunity, randomized pitch selection and exact speed snapshots, the release/flight/impact state machine, capped field-tap acceleration and synchronized tap cues, one-live-ball human rules, post-human 2,048-ball volleys, immutable projectiles, live mound/opponent controls, constant-speed misses, empty-plate suppression, both visible timers, replacement timing and direction, randomized opponent loadouts, deterministic high-variety era naming, all five loot tiers, Power sorting, rarity-colored slots, no-auto-equip drops, equipment caps/amplification/clone dilution, starred 10-item pruning, Scrap, adjusted mastery targets, post-cap mastery farming, all 100 achievement IDs and exact additive rewards, secret disclosure, per-tab purchase filters, typed hard reset, save migration, offline-efficiency rewards, cosmic completion, and seven-day aggregate simulation. The desktop interface audit clicks every visible tab at every reveal layer and checks stable size, bounds, hover comparison data, explicit item actions, offline-return summary, tier catalogs, anonymous achievement cards, unlock toasts, and spoiler gating; the portrait audit checks the rotated lane, phone overlays, scroll-safe passive equipment rows, hold-to-inspect, touch-sized actions and filters, compact controls, and lossless return to desktop layout.

The deterministic greedy benchmarks explicitly disable loot, proving that perfect gear—or any gear—is not a progression requirement. The v0.11.0 human lifetime reaches the first alien exhibition after roughly 37 hours 30 minutes, while the complete multi-reset audit reaches cosmic victory after roughly 63 days 18 hours. The full audit is documented in [docs/BALANCE.md](docs/BALANCE.md) and [docs/DESIGN.md](docs/DESIGN.md).

## Save data

The game autosaves every ten seconds, saves on exit or browser focus loss, and simulates up to seven days of offline progress. Offline strikeout XP starts at 1% of the normal open-game award; the level-5 Scorebook Study training adds one percentage point per rank up to 25% for the current body. Returning with earned XP opens a summary showing time away, XP deposited, and the efficiency used. **EXPORT** writes a portable, readable JSON backup; **LOAD** validates a selected backup and shows its version, level, and XP before asking permission to replace the current run. Browser autosaves use IndexedDB for the hosting site, and the UI warns if the browser reports non-persistent storage. On macOS the ordinary local save is normally at:

```text
~/Library/Application Support/Godot/app_userdata/One Foot Per Second/one_foot_per_second_save.json
```

Save version 15 additionally preserves achievements, their lifetime trigger counters, peak speed/range/rarity records, and each one-time catalog's Hide Purchased preference. Older saves silently backfill every achievement provable from their persisted history without producing a wall of unlock popups. All earlier migration behavior remains intact, including Field Hustle and offline-efficiency defaults, Scrap, additive Training conversion, batter-cooldown splitting, quality-rank consolidation, Belt-to-Jock-Strap conversion, added outcomes, and retired prestige mappings.
