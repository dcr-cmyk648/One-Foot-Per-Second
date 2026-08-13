import { createHash } from "node:crypto";
import { cp, mkdir, readFile, readdir, rm, writeFile } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const siteRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const sourceRoot = resolve(siteRoot, "..", "web");
const targetRoot = resolve(siteRoot, "public", "game");
const partBytes = 16 * 1024 * 1024;

const digest = (data) => createHash("sha256").update(data).digest("hex");

await rm(targetRoot, { recursive: true, force: true });
await mkdir(targetRoot, { recursive: true });

for (const entry of await readdir(sourceRoot, { withFileTypes: true })) {
  if (!entry.isFile() || entry.name === "index.wasm" || entry.name === ".gdignore") {
    continue;
  }
  await cp(join(sourceRoot, entry.name), join(targetRoot, entry.name));
}

const gameHtmlPath = join(targetRoot, "index.html");
const gameHtml = await readFile(gameHtmlPath, "utf8");
if (!gameHtml.includes("<base href=\"/game/\">")) {
  await writeFile(
    gameHtmlPath,
    gameHtml.replace("<head>", "<head>\n\t\t<base href=\"/game/\">"),
  );
}

const wasm = await readFile(join(sourceRoot, "index.wasm"));
const parts = [];
for (let offset = 0, index = 0; offset < wasm.length; offset += partBytes, index += 1) {
  const bytes = wasm.subarray(offset, Math.min(offset + partBytes, wasm.length));
  const path = `index.wasm.part-${String(index).padStart(2, "0")}`;
  await writeFile(join(targetRoot, path), bytes);
  parts.push({ path, size: bytes.length, sha256: digest(bytes) });
}
await writeFile(
  join(targetRoot, "index.wasm.parts.json"),
  `${JSON.stringify({ byteLength: wasm.length, sha256: digest(wasm), parts }, null, 2)}\n`,
);
console.log(`Synced the verified Godot build into ${parts.length} Sites-safe runtime segments.`);
