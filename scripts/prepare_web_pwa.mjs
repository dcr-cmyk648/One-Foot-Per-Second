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

const indexPath = join(webBuild, "index.html");
const lifecycleBridge = await readFile(join(projectRoot, "scripts", "web_lifecycle_bridge.js"), "utf8");
const lifecycleMarker = "<!-- no-hitter-lifecycle-bridge -->";
let indexHtml = await readFile(indexPath, "utf8");
if (!indexHtml.includes(lifecycleMarker)) {
  indexHtml = indexHtml.replace(
    "</head>",
    `${lifecycleMarker}\n<script>\n${lifecycleBridge}\n</script>\n</head>`,
  );
  await writeFile(indexPath, indexHtml);
}

const manifestPath = join(webBuild, "index.manifest.json");
const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
manifest.id = "./";
manifest.name = "No Hitter";
manifest.short_name = "No Hitter";
manifest.description = "An idle baseball game about allowing no hits from one foot per second to the end of reality.";
manifest.theme_color = "#050810";
manifest.icons = (Array.isArray(manifest.icons) ? manifest.icons : [])
  .filter((icon) => icon?.sizes !== "192x192")
  .concat([{ sizes: "192x192", src: iconName, type: "image/png", purpose: "any" }])
  .sort((left, right) => Number.parseInt(left.sizes, 10) - Number.parseInt(right.sizes, 10));
await writeFile(manifestPath, JSON.stringify(manifest));
