import { createHash } from "node:crypto";
import { readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const projectText = await readFile(resolve(root, "project.godot"), "utf8");
const versionMatch = projectText.match(/^config\/version="([^"]+)"$/m);
if (!versionMatch) {
  throw new Error("Could not read config/version from project.godot");
}

const version = versionMatch[1];
const pck = await readFile(resolve(root, "web", "index.pck"));
const pckSha = createHash("sha256").update(pck).digest("hex");
const siteRoot = resolve(root, "sites-host");

const packagePath = resolve(siteRoot, "package.json");
const packageManifest = JSON.parse(await readFile(packagePath, "utf8"));
packageManifest.version = version;
await writeFile(packagePath, `${JSON.stringify(packageManifest, null, 2)}\n`);

const lockPath = resolve(siteRoot, "package-lock.json");
const packageLock = JSON.parse(await readFile(lockPath, "utf8"));
packageLock.version = version;
packageLock.packages[""].version = version;
await writeFile(lockPath, `${JSON.stringify(packageLock, null, 2)}\n`);

const readmePath = resolve(siteRoot, "README.md");
const readme = await readFile(readmePath, "utf8");
const stamp = `Current synced game package: v${version}. Its index.pck SHA-256 is ${pckSha}.`;
const stampedReadme = readme.replace(
  /^Current synced game package:[^\n]*(?:\nthe shared browser packaging step before deployment\.)?$/m,
  stamp,
);
if (stampedReadme === readme && !readme.includes(stamp)) {
  throw new Error("Could not locate the Sites release stamp in README.md");
}
await writeFile(readmePath, stampedReadme);

console.log(`Stamped Sites adapter v${version} (${pckSha}).`);
