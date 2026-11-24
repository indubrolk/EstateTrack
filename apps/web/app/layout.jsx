import "./globals.css";
export const metadata = {
  title: "EstateTrack · Estate workspace",
  description: "Tea estate attendance, harvest and wage management.",
};
export default function Layout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
