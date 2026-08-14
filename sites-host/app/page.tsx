export default function Home() {
  return (
    <main className="game-shell">
      <div className="loading-copy" aria-hidden="true">
        <strong>NO HITTER</strong>
        <span>Warming up the one-foot-per-second no-hitter…</span>
      </div>
      <iframe
        className="game-frame"
        src="/game/index.html"
        title="Play No Hitter"
        allow="autoplay; fullscreen; gamepad; clipboard-read; clipboard-write"
      />
      <noscript>This baseball universe requires JavaScript.</noscript>
    </main>
  );
}
