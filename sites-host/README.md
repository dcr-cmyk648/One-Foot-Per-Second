# No Hitter — Sites host

This is the production hosting adapter for the shared Godot game in the parent
repository. It contains no separate gameplay implementation.

Current synced game package: v0.16.4. Its index.pck SHA-256 is 3b4810df772090c94ff15eb1fd15354f3b962bb92f28ac6a75051a91743aa910.

`npm run build` first verifies that `../web/` matches the current Godot source,
then copies that exact browser export into `public/game/`. The large WebAssembly
runtime is divided into host-safe segments and streamed back as one
`application/wasm` response by the Worker. The root URL redirects to the direct
game document under `/game/`, keeping the full phone viewport while placing the
page inside its generated service worker's update scope.

## Local checks

```bash
npm ci
npm test
npm run start
```

Open `http://127.0.0.1:3000/`. The source export remains suitable for GitHub
Pages; this adapter only handles Codex Sites packaging and hosting constraints.

## Files generated during build

- `public/game/` — copied and segmented browser export
- `dist/` — Sites deployment artifact
- `.vinext/` and `.wrangler/` — local framework state

All generated directories are ignored. `.openai/hosting.json` stores the opaque
Sites project ID after the site is created.
