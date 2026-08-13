import assert from "node:assert/strict";
import test from "node:test";

const workerUrl = new URL("../dist/server/index.js", import.meta.url);
workerUrl.searchParams.set("test", `${process.pid}-${Date.now()}`);
const { default: worker } = await import(workerUrl.href);

const context = {
  waitUntil() {},
  passThroughOnException() {},
};

test("serves the verified Godot page directly at the site root", async () => {
  const gameHtml = `<!doctype html><html><head><base href="/game/"><title>One Foot Per Second</title></head><body><canvas id="canvas"></canvas><script src="index.js"></script></body></html>`;
  const response = await worker.fetch(
    new Request("http://localhost/", { headers: { accept: "text/html" } }),
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
  const html = await response.text();
  assert.match(html, /<title>One Foot Per Second<\/title>/i);
  assert.match(html, /<base href="\/game\/">/i);
  assert.match(html, /<canvas id="canvas"/i);
  assert.doesNotMatch(html, /iframe|codex-preview|SkeletonPreview|react-loading-skeleton/i);
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
