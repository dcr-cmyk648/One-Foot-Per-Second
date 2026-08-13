export default function Home() {
  return (
    <main className="game-shell">
      <div className="loading-copy" aria-hidden="true">
        <strong>ONE FOOT PER SECOND</strong>
        <span>Warming up the one-foot-per-second fastball…</span>
      </div>
      <iframe
        className="game-frame"
        src="/game/index.html"
        title="Play One Foot Per Second"
        allow="autoplay; fullscreen; gamepad; clipboard-read; clipboard-write"
      />
      <noscript>This baseball universe requires JavaScript.</noscript>
    </main>
  );
}
