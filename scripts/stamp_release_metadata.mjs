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

// Keep the OS-visible executable metadata on the same version as the PCK and
// update manifest. These fields previously remained at 0.14.0 even as native
// builds advanced, which made installed-build diagnostics needlessly opaque.
const exportPresetsPath = join(projectRoot, "export_presets.cfg");
const exportPresets = await readFile(exportPresetsPath, "utf8");
const stampedExportPresets = exportPresets
  .replace(/^application\/short_version="[^"]+"$/gm, `application/short_version="${version}"`)
  .replace(/^application\/version="[^"]+"$/gm, `application/version="${version}"`)
  .replace(/^application\/file_version="[^"]+"$/gm, `application/file_version="${version}.0"`)
  .replace(/^application\/product_version="[^"]+"$/gm, `application/product_version="${version}.0"`);
if (stampedExportPresets === exportPresets && !exportPresets.includes(`application/short_version="${version}"`)) {
  throw new Error("Could not stamp native export versions");
}
await writeFile(exportPresetsPath, stampedExportPresets);

const manifestPath = join(projectRoot, "distribution", "release-manifest.json");
const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
manifest.version = version;
manifest.save_version = saveVersion;
await writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);

const readmePath = join(projectRoot, "distribution", "README-FIRST.txt");
const readme = await readFile(readmePath, "utf8");
await writeFile(readmePath, readme.replace(/v\d+\.\d+\.\d+/g, `v${version}`));
