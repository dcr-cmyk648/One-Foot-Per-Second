# No Hitter

A top-down baseball idle roguelike about beginning three feet from a toddler with a one-foot-per-second wiffle-ball apology and discovering how unreasonable baseball can become.

This repository contains the shared Godot 4.7.1 source and tested v0.17.2 exports for browser/PWA, macOS, Windows, Linux, GitHub Pages, and Codex Sites. Every platform uses the same campaign, simulation, save schema, and progression. Browser-only rendering limits reduce visual clutter without changing results.

## Play or share

The live browser build is published through [GitHub Pages](https://dcr-cmyk648.github.io/One-Foot-Per-Second/). The Web build is also a Progressive Web App:

- iPhone/iPad: open in Safari, use Share → Add to Home Screen.
- Android: use Chrome’s Install action when offered, or Add to Home screen from its menu.
- Installed Web versions stay on the automatic update channel and can keep the screen awake while visible.

The complete local distribution is:

```text
release/No Hitter v0.17.2 All Platforms.zip
```

It contains the browser ZIP, a Universal macOS DMG, x86_64 and ARM64 Windows ZIPs, x86_64 and ARM64 Linux archives, source, instructions, manifests, and checksums. Godot is not required to play an export.

Native packages are portable, ad-hoc/unsigned test builds rather than store submissions. They check the stable manifest at startup and every five minutes, then offer the correct replacement package. Saves live outside the application, so replacing the app or portable folder retains progress. Browser/PWA installation is the seamless in-place update path.

## Build

Install Godot 4.7.1, then run the project directly:

```bash
godot --path .
```

Build only the verified browser package:

```bash
./scripts/package_web.sh
```

Build and verify every supported package on macOS:

```bash
./scripts/package_all_platforms.sh
```

The complete packager runs shared gameplay, desktop UI, and 390×844 portrait suites; installs official export templates when missing; exports six targets; verifies binary architectures, archives, and the Mac smoke launch; creates checksums; and prunes generated packages from older releases. The first template install is large. Generated packages and build folders are reproducible and are not source.

## Core rules

Only a completed strikeout awards XP.

- Called Strikes award the largest ordinary Mastery share; lesser contact awards a little; Home Runs and Grand Slams award none.
- Mastery immediately improves the exact matchup. Filling the bar makes the opponent ready, but the next level opens only on a strikeout.
- Human baseball always uses three Strikes and four Balls. Fouls stop adding Strikes at two; a walk behaves like a Single.
- Unsaved hits clear the count and replace the batter. Larger hits add longer waits. Grand Slams can never be saved.
- Every level sets its own physical range, threat, bounty, body scale, and opponent equipment. Range affects flight and difficulty, never XP.
- Overmastery adds small logarithmic matchup, XP, and loot benefits while loot level remains capped to that opponent.
- Bad outcomes and active tapping add Determination. Its bonus is uncapped but logarithmic and resets on a strikeout.

The opening pitch is physically literal: one foot per second across three feet for three seconds. Human speed ends near 115 mph. Later story layers anchor their finales near Mach 5,000 and 5,000c.

## The run-build layer

Every numbered clear queues a saved perk draft. The defeated level sets perk level; rarity sets its strength. Three-level sub-era finales guarantee Rare-or-better perk choices; every fifth level and each authored boss separately queues a Pitch draft that learns a pitch or improves one already known. Boss drafts contain the strangest options. Prestige can add offer choices, improve rarity, unlock boss perks, and eventually corrupt a card into a 2–3× positive effect with a random penalty.

Offers are generated once from the saved run seed and serial. Reloading cannot reroll them. Auto-advance may queue many rewards, but all remain selectable in order.

This replaces purchased ages, builds, and pitches. Skipping age perks keeps the player a toddler; the next sequential age becomes increasingly likely when the run falls behind its normal life stage, but is never forced. Age cards state their exact Speed, Quality, Recovery, and Size change. Chosen adjectives still compose in the subtitle. PITCH is a read-only Arsenal. BODY contains the current run and only the persistent sections the story has revealed.

XP spending is intentionally split:

- TRAIN: small uncapped repeatable improvements, with exact x1/x10/x100 batches.
- BALL: replacement shells and payload identity.
- FACILITY: expensive one-time multiplicative savings targets.
- Equipment: optional randomized build sidegrades rather than required progression.

## Campaign details (full spoilers)

<details>
<summary>Reveal all campaign and prestige layers</summary>

The finite campaign has exactly 100 numbered levels:

1. **Human baseball, levels 1–33:** eleven sub-eras from backyard toddlers through professional baseball. Bambino Rex becomes the sticky final batter once the next strikeout could complete the league. Aggressive no-loot audit policies reach first contact in roughly 9–11 hours at the 115 mph human ceiling.
2. **First-contact Xylophax:** an unnumbered, unwinnable exhibition. Pitching waits for the arrival dialog. Xylophax remains at the plate, hits guaranteed Grand Slams, taunts the player, and fills a witnessed humiliation meter. Offline play cannot fill it. HELP summons a portal stranger and performs the first prenatal genetic rebirth.
3. **Alien baseball, levels 34–66:** several genetic lives add arms, stronger biology, count compression, draft control, automation, and probabilistic clone fielding. The final planetary league plays from Olympus Mound. Xylophax carries four bats and requires a body approaching Mach 5,000.
4. **First-contact Octathulhu:** another unnumbered, witnessed Grand-Slam exhibition. When its doom meter fills, Octathulhu eats the universe and reveals eldritch ascension.
5. **Eldritch baseball, levels 67–99:** a rebuilt reality returns to Earth, establishes an orbital pitching platform, and defends the solar system from approaching gods. Clone, portal, corrupted-perk, overlapping-volley, Relic, and causality upgrades become available.
6. **Octathulhu, level 100:** the eight-bat final boss at Earth-to-Pluto range, with the pitching body approaching 5,000 times light speed.
7. **God Prestige:** God thanks the player for saving the universe and suggests doing it all again. Permanent blessings and Halos persist. Returning to Octathulhu after a God reset unlocks procedural Extra Innings, and another God reset remains available at any time.

Genetic rebirth resets the run and equipment for DNA based on run XP. Eldritch ascension also resets DNA/genetics for Arcana based on DNA earned in the reality. God Prestige resets both lower layers while preserving divine rewards, achievements, story knowledge, and lifetime history.

</details>

## Multi-ball combat and visuals

Human play permits one unresolved pitch. Post-human arms and clones create real simultaneous balls; later eldritch geometry permits new windups while earlier volleys are still in flight.

Every ball in a volley shares the sampled pitch but resolves independently. Balls beyond the opponent’s simultaneous bat count compound a large contact penalty; surplus bats apply the reciprocal advantage. Matching outcomes become Double Strike, Triple Single, and similar calls. Mixed outcomes appear together and stack bases, lineup delays, Strikes, and Balls.

A released projectile owns immutable pitch, speed, drag, plate speed, duration, path, color, source, and target generation. New purchases affect only later throws. Missed balls pass through the plate and fade; only contact creates a return trajectory. If an old overlapping volley loses its batter, it loses targeting, veers away, and quickly fades without resolving against the replacement.

Native rendering reserves the complete designed 2,048-ball finite volley. The browser renders up to 512 weighted outbound representatives once exact drawing would become unreadable. Simulation, rewards, Mastery, loot, and saves remain exact.

## Gear, story, and achievements

Strikeout drops copy one visible player-wearable slot and rarity from the defeated batter. Items never auto-equip by default. Ordinary gear has one to three affixes; rarity increases magnitude, every run stat is eligible, and real positive/negative tradeoffs support builds. Each slot stores ten items; equipped/starred items are protected and overflow becomes Scrap. Relics grant one enormous stat and gain more slots through eldritch progression.

The spoiler-gated Story tab keeps every revealed popup, newest first, with a saved Reverse Order switch. A fresh run opens at three feet and one foot per second; each first-lifetime human chapter receives its own arrival blurb when the new level is actually entered. Names use era-specific composable grammar; authored bosses reserve their signatures.

The game contains 165 permanent achievements at +0.5% XP each. Unknown secret entries occupy anonymous slots without leaking their names, conditions, progress, or future systems. The extreme secret No Hitter requires a complete post-victory campaign without a single fair hit.

## Browser, phone, and responsive behavior

Wide desktop uses a three-column layout. Short or narrow windows collapse sidebars before clipping. Portrait Web rotates the field so the pitcher is below the batter and presents Upgrades, Status, Log, and Saves as bounded overlays. Passive text remains scrollable; only explicit buttons buy, equip, compare, or open details. Desktop hover and stationary mobile hold expose the same details, and dragging cancels hold inspection.

The title art, Help, tabs, save summaries, achievements, environments, and currencies disclose only systems the current save has encountered.

## Saves and updates

The game autosaves every ten seconds and on clean exit/backgrounding, with up to seven days of offline catch-up. Offline efficiency scales both XP and Mastery, and the return popup reports the deposit. SAVES exposes the autosave plus three manual device-local slots. EXPORT/IMPORT is the optional portable and cross-device backup path.

Writes use validated pending, primary, and backup generations. Browser builds add rotating persistent mirrors and a dedicated pre-update checkpoint, flush storage before activation, and select the most advanced valid generation after reload. An older cached build refuses to overwrite a newer schema.

Save schema 28 migrates all public saves. Former 30/10/5 campaign positions map by authored place inside their league; old age/build/pitch ownership becomes equivalent deterministic legacy run state. Prestige balances, upgrades, gear, achievements, story, pending drafts, active volleys, lifetime counters, and update checkpoints are preserved. The renamed game deliberately retains its original application-data folder:

```text
macOS:  ~/Library/Application Support/Godot/app_userdata/One Foot Per Second/
Windows: %APPDATA%\Godot\app_userdata\One Foot Per Second\
Linux:  ~/.local/share/godot/app_userdata/One Foot Per Second/
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

The suites cover campaign topology, deterministic drafts, old-save migration, strikeout-only income, exact count-state math, mastery gating, sticky witnessed bosses, physical speed/range anchors, tap-rate behavior, immutable multi-volley state, reciprocal bats, clone fielding, equipment/Relics, prestige, endless play, spoiler disclosure, save/update recovery, and desktop/phone layout bounds. The no-loot runners prove that randomized gear and perfect draft rolls are not progression requirements.

See [docs/DESIGN.md](docs/DESIGN.md), [docs/BALANCE.md](docs/BALANCE.md), and [CHANGELOG.md](CHANGELOG.md) for the complete rules, measured pacing, and release history.

## Hosting

`web/` is the checked-in Pages/PWA artifact. `./scripts/package_web.sh` refreshes it and `./scripts/verify_web_parity.sh` checks source hashes, artifact hashes, and update metadata.

`sites-host/` is a thin Codex Sites adapter around that exact verified export. Its build re-checks parity, copies the game, and packages the WebAssembly runtime for Sites. It never forks gameplay.
