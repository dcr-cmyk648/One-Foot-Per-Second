NO HITTER v0.20.0
ALL-PLATFORMS RELEASE

Choose the browser package or the native package matching the computer that
will run the game. Godot is not required, no administrator account is required,
and the game does not install services or modify the registry.

BROWSER

"No Hitter v0.20.0 Browser.zip" is a static website. Upload its
contents unchanged to a static host with index.html at the web root, then share
that URL. See WEB-README.txt in the browser package for local testing and save
details. It cannot be run reliably by double-clicking index.html.

MACOS — INTEL OR APPLE SILICON

1. Open "No Hitter v0.20.0 macOS Universal.dmg".
2. Drag No Hitter into Applications, or run it from the disk image.
3. The build is ad-hoc signed but not Apple-notarized. On first launch,
   Control-click the app and choose Open. If macOS still blocks it, open
   System Settings > Privacy & Security and choose Open Anyway.

Do not disable Gatekeeper globally. A warning-free public macOS release requires
an Apple Developer ID certificate and notarization.

WINDOWS

1. Most Windows PCs use the x86_64 ZIP. Windows-on-ARM devices use the ARM64 ZIP.
2. Extract the whole ZIP, then open "No Hitter.exe".
3. The EXE is not commercially code-signed. If Microsoft Defender SmartScreen
   appears, choose More info, verify that the file came from the person who sent
   it to you, then choose Run anyway.

The Windows build is portable: it has no installer and does not require admin
rights. A warning-free public Windows release requires a trusted code-signing
certificate.

LINUX

1. Intel/AMD Linux computers use the x86_64 archive. ARM Linux computers use
   the ARM64 archive.
2. Extract the entire .tar.gz archive.
3. Double-click the executable and allow it to run, or launch it in a terminal.
   If needed: chmod +x "No Hitter.x86_64"

SAVES AND OFFLINE PROGRESS

The game saves every ten seconds and on clean exit. Saves are local to the user:

macOS:
  ~/Library/Application Support/Godot/app_userdata/One Foot Per Second/

Windows:
  %APPDATA%\Godot\app_userdata\One Foot Per Second\

Linux:
  ~/.local/share/godot/app_userdata/One Foot Per Second/

The renamed game deliberately keeps this original data directory. The save is
named one_foot_per_second_save.json. Normal updates retain that data automatically;
the in-game EXPORT and IMPORT buttons are the optional portable backup and
cross-device transfer path.
Automatic writes validate a pending generation and retain the previous valid
save as one_foot_per_second_save.backup.json. An unreadable or newer-schema save
is protected from automatic overwrite until LOAD or an explicit typed RESET.
Browser autosaves are local to that browser and site; EXPORT is recommended
before deliberately clearing site data, changing browsers, or changing devices.

UPDATES

Browser/Home Screen installs stay on the automatic Web update channel. Native
macOS, Windows, and Linux builds check the official release manifest at startup
and every five minutes while open. When a newer package is ready, the game offers
EXPORT BACKUP, LATER, or a direct download for the current operating system.
The replacement build reuses the same external save directory listed above.

Native packages cannot safely replace their own running executable without
commercial platform signing. Install the downloaded replacement over the old
copy (or replace the portable folder); progress remains outside the app. For the
most seamless app-like update experience, install the browser PWA instead.

Offline catch-up simulates up to seven days. Strikeout XP and Mastery begin at 1%
of their open-game awards and asymptotically approach 75% with Scorebook Study.
A return popup shows the exact deposit and multiplier that were used.

CONTENTS

- macOS Universal DMG: Intel and Apple Silicon Macs
- Windows x86_64 ZIP: ordinary 64-bit Intel/AMD Windows PCs
- Windows ARM64 ZIP: Windows-on-ARM PCs
- Linux x86_64 tar.gz: ordinary 64-bit Intel/AMD Linux PCs
- Linux ARM64 tar.gz: 64-bit ARM Linux PCs
- Browser ZIP: static WebAssembly/WebGL 2 site for modern browsers
- Source ZIP: Godot 4.7.1 project for unsupported systems and development
- SHA256SUMS.txt: hashes for verifying that downloads are unchanged
- release-manifest.json: machine-readable version and platform inventory

There are no native Android, iPhone/iPad, or console packages in this release.
The browser build is installable from Safari's Add to Home Screen action and
Chrome's Android install prompt while remaining on the Web update channel.
