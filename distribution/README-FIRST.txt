ONE FOOT PER SECOND v0.10.0
ALL-PLATFORMS RELEASE

Choose the browser package or the native package matching the computer that
will run the game. Godot is not required, no administrator account is required,
and the game does not install services or modify the registry.

BROWSER

"One Foot Per Second v0.10.0 Browser.zip" is a static website. Upload its
contents unchanged to a static host with index.html at the web root, then share
that URL. See WEB-README.txt in the browser package for local testing and save
details. It cannot be run reliably by double-clicking index.html.

MACOS — INTEL OR APPLE SILICON

1. Open "One Foot Per Second v0.10.0 macOS Universal.dmg".
2. Drag One Foot Per Second into Applications, or run it from the disk image.
3. The build is ad-hoc signed but not Apple-notarized. On first launch,
   Control-click the app and choose Open. If macOS still blocks it, open
   System Settings > Privacy & Security and choose Open Anyway.

Do not disable Gatekeeper globally. A warning-free public macOS release requires
an Apple Developer ID certificate and notarization.

WINDOWS

1. Most Windows PCs use the x86_64 ZIP. Windows-on-ARM devices use the ARM64 ZIP.
2. Extract the whole ZIP, then open "One Foot Per Second.exe".
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
   If needed: chmod +x "One Foot Per Second.x86_64"

SAVES AND OFFLINE PROGRESS

The game saves every ten seconds and on clean exit. Saves are local to the user:

macOS:
  ~/Library/Application Support/Godot/app_userdata/One Foot Per Second/

Windows:
  %APPDATA%\Godot\app_userdata\One Foot Per Second\

Linux:
  ~/.local/share/godot/app_userdata/One Foot Per Second/

The save is named one_foot_per_second_save.json. The in-game EXPORT and LOAD
buttons are the preferred way to move or back up progress on every platform.
Browser autosaves are local to that browser and site; use EXPORT before clearing
site data, changing browsers, or changing devices.

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
