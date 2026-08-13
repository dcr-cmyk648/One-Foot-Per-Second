import { copyFile, readFile, writeFile } from "node:fs/promises";
import { join, resolve } from "node:path";

const [projectRootArgument, webBuildArgument] = process.argv.slice(2);
if (!projectRootArgument || !webBuildArgument) {
  throw new Error("Usage: node scripts/prepare_web_pwa.mjs PROJECT_ROOT WEB_BUILD_DIR");
}

const projectRoot = resolve(projectRootArgument);
const webBuild = resolve(webBuildArgument);
const iconName = "index.192x192.png";
await copyFile(join(projectRoot, "assets", "icon-192.png"), join(webBuild, iconName));

const manifestPath = join(webBuild, "index.manifest.json");
const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
manifest.id = "./";
manifest.short_name = "One Foot Per Second";
manifest.description = "An idle baseball game about pitching from one foot per second to the end of reality.";
manifest.theme_color = "#050810";
manifest.icons = (Array.isArray(manifest.icons) ? manifest.icons : [])
  .filter((icon) => icon?.sizes !== "192x192")
  .concat([{ sizes: "192x192", src: iconName, type: "image/png", purpose: "any" }])
  .sort((left, right) => Number.parseInt(left.sizes, 10) - Number.parseInt(right.sizes, 10));
await writeFile(manifestPath, JSON.stringify(manifest));
