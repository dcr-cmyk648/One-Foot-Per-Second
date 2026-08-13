ONE FOOT PER SECOND — BROWSER BUILD

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

GITHUB PAGES

The source repository contains the ready site in web/ and an automated Pages
workflow. In GitHub, choose Settings > Pages > Source: GitHub Actions, then run
"Deploy browser game to GitHub Pages" or push the release to main. The workflow
verifies that the committed browser files still match both their artifact
checksums and the shared Godot gameplay source before publishing.

SAVES

Browser autosaves use that browser's local IndexedDB storage for this site. The
EXPORT button downloads a portable JSON backup. LOAD selects such a backup,
validates it, and asks for confirmation before replacing local progress. Use a
backup before clearing site data or changing browsers/devices. Private browsing
or restrictive storage settings may make autosaves temporary; the game warns
when the browser reports that condition.
