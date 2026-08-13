# One Foot Per Second — Sites host

This is the production hosting adapter for the shared Godot game in the parent
repository. It contains no separate gameplay implementation.

`npm run build` first verifies that `../web/` matches the current Godot source,
then copies that exact browser export into `public/game/`. The large WebAssembly
runtime is divided into host-safe segments and streamed back as one
`application/wasm` response by the Worker. The root URL serves the game directly
so the canvas can use the full phone viewport without iframe scaling.

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
