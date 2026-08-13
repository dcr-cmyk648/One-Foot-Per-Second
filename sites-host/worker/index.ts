/** Cloudflare Worker entry point for the vinext-starter template. */
import { handleImageOptimization, DEFAULT_DEVICE_SIZES, DEFAULT_IMAGE_SIZES } from "vinext/server/image-optimization";
import handler from "vinext/server/app-router-entry";

interface Env {
  ASSETS?: Fetcher;
  IMAGES: {
    input(stream: ReadableStream): {
      transform(options: Record<string, unknown>): {
        output(options: { format: string; quality: number }): Promise<{ response(): Response }>;
      };
    };
  };
}

interface ExecutionContext {
  waitUntil(promise: Promise<unknown>): void;
  passThroughOnException(): void;
}

// Image security config. SVG sources with .svg extension auto-skip the
// optimization endpoint on the client side (served directly, no proxy).
// To route SVGs through the optimizer (with security headers), set
// dangerouslyAllowSVG: true in next.config.js and uncomment below:
// const imageConfig: ImageConfig = { dangerouslyAllowSVG: true };

const worker = {
  async fetch(request: Request, env: Env | undefined, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/") {
      // Keep the document inside the generated service worker's /game/ scope.
      // That lets a tab which stays open for days discover and activate releases.
      return Response.redirect(new URL("/game/index.html", request.url), 302);
    }

    if (url.pathname === "/game/index.wasm" && env?.ASSETS) {
      return streamGameWasm(request, env.ASSETS);
    }

    if (url.pathname.startsWith("/game/") && env?.ASSETS) {
      const gameAsset = await fetchStaticAsset(request, env.ASSETS, url.pathname);
      if (gameAsset.ok) {
        const headers = new Headers(gameAsset.headers);
        if (
          url.pathname === "/game/index.html" ||
          url.pathname === "/game/index.manifest.json" ||
          url.pathname === "/game/index.service.worker.js"
        ) {
          headers.set("Cache-Control", "public, max-age=0, must-revalidate");
        }
        return new Response(gameAsset.body, { status: gameAsset.status, headers });
      }
    }

    if (url.pathname === "/_vinext/image" && env?.ASSETS) {
      const allowedWidths = [...DEFAULT_DEVICE_SIZES, ...DEFAULT_IMAGE_SIZES];
      return handleImageOptimization(request, {
        fetchAsset: (path) => env.ASSETS.fetch(new Request(new URL(path, request.url))),
        transformImage: async (body, { width, format, quality }) => {
          const result = await env.IMAGES.input(body).transform(width > 0 ? { width } : {}).output({ format, quality });
          return result.response();
        },
      }, allowedWidths);
    }

    return handler.fetch(request, env as Env, ctx);
  },
};

interface WasmPart {
  path: string;
  size: number;
}

interface WasmManifest {
  byteLength: number;
  parts: WasmPart[];
}

function fetchStaticAsset(request: Request, assets: Fetcher, path: string): Promise<Response> {
  const assetRequest = new Request(new URL(path, request.url));
  return assets.fetch(assetRequest);
}

async function streamGameWasm(request: Request, assets: Fetcher): Promise<Response> {
  const manifestResponse = await fetchStaticAsset(request, assets, "/game/index.wasm.parts.json");
  if (!manifestResponse.ok) {
    return new Response("Game runtime manifest unavailable", { status: 503 });
  }
  const manifest = (await manifestResponse.json()) as WasmManifest;
  if (!Array.isArray(manifest.parts) || manifest.parts.length === 0) {
    return new Response("Game runtime manifest is invalid", { status: 503 });
  }

  const partResponses = await Promise.all(
    manifest.parts.map((part) => fetchStaticAsset(request, assets, `/game/${part.path}`)),
  );
  if (partResponses.some((response) => !response.ok || response.body === null)) {
    return new Response("Game runtime segment unavailable", { status: 503 });
  }
  const headers = new Headers({
    "Content-Type": "application/wasm",
    "Content-Length": String(manifest.byteLength),
    "Cache-Control": "public, max-age=0, must-revalidate",
    "X-Content-Type-Options": "nosniff",
  });
  if (request.method === "HEAD") {
    return new Response(null, { status: 200, headers });
  }

  let partIndex = 0;
  let activeReader: ReadableStreamDefaultReader<Uint8Array> | null = null;
  const body = new ReadableStream<Uint8Array>({
    async pull(controller) {
      while (partIndex < partResponses.length) {
        activeReader ??= partResponses[partIndex].body!.getReader();
        const chunk = await activeReader.read();
        if (!chunk.done) {
          controller.enqueue(chunk.value);
          return;
        }
        activeReader.releaseLock();
        activeReader = null;
        partIndex += 1;
      }
      controller.close();
    },
    async cancel(reason) {
      if (activeReader !== null) {
        await activeReader.cancel(reason);
      }
    },
  });
  return new Response(body, { status: 200, headers });
}

export default worker;
