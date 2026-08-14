import assert from "node:assert/strict";
import test from "node:test";

const workerUrl = new URL("../dist/server/index.js", import.meta.url);
workerUrl.searchParams.set("test", `${process.pid}-${Date.now()}`);
const { default: worker } = await import(workerUrl.href);

const context = {
  waitUntil() {},
  passThroughOnException() {},
};

test("redirects the site root into the update-controlled game scope", async () => {
  const response = await worker.fetch(
    new Request("http://localhost/"),
    { ASSETS: { fetch: async () => new Response("Not found", { status: 404 }) } },
    context,
  );
  assert.equal(response.status, 302);
  assert.equal(response.headers.get("location"), "http://localhost/game/index.html");
});

test("serves the verified Godot page with revalidation headers", async () => {
  const gameHtml = `<!doctype html><html><head><base href="/game/"><title>No Hitter</title></head><body><canvas id="canvas"></canvas><script src="index.js"></script></body></html>`;
  const response = await worker.fetch(
    new Request("http://localhost/game/index.html", { headers: { accept: "text/html" } }),
    {
      ASSETS: {
        fetch: async (request) =>
          new URL(request.url).pathname === "/game/index.html"
            ? new Response(gameHtml, { headers: { "content-type": "text/html" } })
            : new Response("Not found", { status: 404 }),
      },
    },
    context,
  );
  assert.equal(response.status, 200);
  assert.equal(response.headers.get("cache-control"), "public, max-age=0, must-revalidate");
  const html = await response.text();
  assert.match(html, /<title>No Hitter<\/title>/i);
  assert.match(html, /<base href="\/game\/">/i);
  assert.match(html, /<canvas id="canvas"/i);
  assert.doesNotMatch(html, /iframe|codex-preview|SkeletonPreview|react-loading-skeleton/i);
});

test("never pins the release worker behind a long-lived host cache", async () => {
  const workerSource = "const CACHE_VERSION = 'test-release';";
  const response = await worker.fetch(
    new Request("http://localhost/game/index.service.worker.js"),
    {
      ASSETS: {
        fetch: async (request) =>
          new URL(request.url).pathname === "/game/index.service.worker.js"
            ? new Response(workerSource, { headers: { "content-type": "text/javascript" } })
            : new Response("Not found", { status: 404 }),
      },
    },
    context,
  );
  assert.equal(response.status, 200);
  assert.equal(response.headers.get("cache-control"), "public, max-age=0, must-revalidate");
  assert.equal(await response.text(), workerSource);
});

test("reassembles Sites-safe runtime segments as one wasm response", async () => {
  const pieces = new Map([
    ["/game/index.wasm.parts.json", new TextEncoder().encode(JSON.stringify({
      byteLength: 8,
      parts: [
        { path: "index.wasm.part-00", size: 4 },
        { path: "index.wasm.part-01", size: 4 },
      ],
    }))],
    ["/game/index.wasm.part-00", new Uint8Array([0, 97, 115, 109])],
    ["/game/index.wasm.part-01", new Uint8Array([1, 0, 0, 0])],
  ]);
  const response = await worker.fetch(
    new Request("http://localhost/game/index.wasm"),
    {
      ASSETS: {
        fetch: async (request) => {
          const bytes = pieces.get(new URL(request.url).pathname);
          return bytes ? new Response(bytes) : new Response("Not found", { status: 404 });
        },
      },
    },
    context,
  );
  assert.equal(response.status, 200);
  assert.equal(response.headers.get("content-type"), "application/wasm");
  assert.equal(response.headers.get("content-length"), "8");
  assert.deepEqual(new Uint8Array(await response.arrayBuffer()), new Uint8Array([0, 97, 115, 109, 1, 0, 0, 0]));
});
