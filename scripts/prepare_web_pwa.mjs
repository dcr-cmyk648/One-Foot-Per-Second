import { copyFile, readFile, writeFile } from "node:fs/promises";
import { join, resolve } from "node:path";

const [projectRootArgument, webBuildArgument] = process.argv.slice(2);
if (!projectRootArgument || !webBuildArgument) {
  throw new Error("Usage: node scripts/prepare_web_pwa.mjs PROJECT_ROOT WEB_BUILD_DIR");
}

const projectRoot = resolve(projectRootArgument);
const webBuild = resolve(webBuildArgument);
const iconName = "index.192x192.png";
const projectSettings = await readFile(join(projectRoot, "project.godot"), "utf8");
const versionMatch = projectSettings.match(/^config\/version="([^"]+)"/m);
if (!versionMatch) {
  throw new Error("Could not read config/version from project.godot");
}
const version = versionMatch[1];
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

const repository = "dcr-cmyk648/One-Foot-Per-Second";
const tag = `v${version}`;
const assetBase = `https://github.com/${repository}/releases/download/${tag}`;
// GitHub Release asset uploads normalize spaces in filenames to dots. Generate
// the public name GitHub actually serves instead of a plausible-but-missing
// percent-encoded local filename.
const assetUrl = (name) => `${assetBase}/${encodeURIComponent(name.replaceAll(" ", "."))}`;
const updateManifest = {
  schema: 1,
  channel: "stable",
  version,
  release_page: `https://github.com/${repository}/releases/tag/${tag}`,
  downloads: {
    macos: assetUrl(`No Hitter v${version} macOS Universal.dmg`),
    windows_x86_64: assetUrl(`No Hitter v${version} Windows x86_64.zip`),
    windows_arm64: assetUrl(`No Hitter v${version} Windows ARM64.zip`),
    linux_x86_64: assetUrl(`No Hitter v${version} Linux x86_64.tar.gz`),
    linux_arm64: assetUrl(`No Hitter v${version} Linux ARM64.tar.gz`),
  },
};
await writeFile(
  join(webBuild, "update-manifest.json"),
  `${JSON.stringify(updateManifest, null, 2)}\n`,
);
