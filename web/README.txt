NO HITTER — BROWSER BUILD

This ZIP is a static website. Upload its contents without renaming the generated
files, and keep index.html at the web root. It does not require an application
server, database, account system, or installation step.

For local testing, browsers will not reliably run the game by double-clicking
index.html. From the source project, run:

  scripts/serve_web.sh

Then open http://127.0.0.1:8001/ in a modern Chromium-based browser or Firefox.
The build requires WebAssembly and WebGL 2. Safari is supported where its WebGL
implementation permits, but Chromium and Firefox are the primary targets.

GAMEPLAY PARITY

The browser and desktop packages are exports of the same Godot project, scenes,
content tables, economy, save schema, and tests. The browser presentation limits
the number of simultaneously visible late-game projectile representatives,
return balls, stars, and clone bodies; those limits never reduce simulated
pitches, rewards, loot, mastery, or progression.

PHONE LAYOUT

Portrait browsers rotate the field so the pitcher is at the bottom and the
batter is at the top. Upgrades, Loadout, Event Log, and Save controls open over
the field from the bottom navigation row. This is a browser presentation layer;
the underlying game and exported save format remain identical to desktop.

IPHONE HOME SCREEN INSTALL

On an iPhone, the bottom menu shows INSTALL while the game is running in a
browser. Tap it for the Apple-specific pathway: use Safari's Share button,
choose Add to Home Screen, then tap Add. The action disappears when the game is
launched from its Home Screen icon. EXPORT a backup before installing; if iOS
opens the installed game with fresh storage, use LOAD to bring the run across.

UPDATES AND OFFLINE PLAY

The generated service worker identifies each release by its content-derived
cache version. An open game asks the host for an update every five minutes. When
one is ready, the game shows SAVE & UPDATE; it does not reload until the player
chooses. The review recommends EXPORT first. The current run is validated,
mirrored with a rollback generation, and browser storage is flushed before the
new release activates. After one successful online load, the current build can also
start offline when the browser retains its cache.

Closing the game or suspending its tab simulates up to seven days. Strikeout XP
starts at 1% of the open-game award; Scorebook Study adds one percentage point
per rank up to 25% for the current body. Returning with earned XP shows a popup
with the exact deposit, elapsed time, and efficiency used.

CODEX SITES

The source project includes a Sites hosting shell that publishes this verified
Godot export without forking the game. Its build splits the WebAssembly file
into host-safe static segments and streams them back as the original runtime.
GitHub Pages remains available as a plain static-host fallback.

GITHUB PAGES

The source repository contains the ready site in web/ and an automated Pages
workflow. In GitHub, choose Settings > Pages > Source: GitHub Actions, then run
"Deploy browser game to GitHub Pages" or push the release to main. The workflow
verifies that the committed browser files still match both their artifact
checksums and the shared Godot gameplay source before publishing.

SAVES

Browser autosaves use that browser's local IndexedDB storage for this site and
rotate primary/rollback localStorage recovery mirrors. Writes retain the prior
validated generation; unreadable data is not silently overwritten. The EXPORT
button downloads a portable JSON backup. LOAD selects such a backup, validates
it, and asks for confirmation before replacing local progress. Use a backup
before clearing site data or changing browsers/devices. Private browsing or
restrictive storage settings may make autosaves temporary; the game warns when
the browser reports that condition.
