import { readFile, writeFile } from "node:fs/promises";
import { join, resolve } from "node:path";

const projectRoot = resolve(process.argv[2] || new URL("..", import.meta.url).pathname);
const projectSettings = await readFile(join(projectRoot, "project.godot"), "utf8");
const gameState = await readFile(join(projectRoot, "scripts", "game_state.gd"), "utf8");
const versionMatch = projectSettings.match(/^config\/version="([^"]+)"/m);
const saveVersionMatch = gameState.match(/^const SAVE_VERSION := (\d+)/m);
if (!versionMatch || !saveVersionMatch) {
  throw new Error("Could not read the game or save version");
}

const version = versionMatch[1];
const saveVersion = Number.parseInt(saveVersionMatch[1], 10);
const manifestPath = join(projectRoot, "distribution", "release-manifest.json");
const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
manifest.version = version;
manifest.save_version = saveVersion;
await writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);

const readmePath = join(projectRoot, "distribution", "README-FIRST.txt");
const readme = await readFile(readmePath, "utf8");
await writeFile(readmePath, readme.replace(/v\d+\.\d+\.\d+/g, `v${version}`));
