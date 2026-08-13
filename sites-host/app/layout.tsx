import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "One Foot Per Second",
  description:
    "A baseball idle game about becoming cosmically overqualified, one painfully slow pitch at a time.",
  icons: {
    icon: "/game/index.icon.png",
    shortcut: "/game/index.icon.png",
    apple: "/game/index.apple-touch-icon.png",
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  viewportFit: "cover",
  themeColor: "#050810",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
