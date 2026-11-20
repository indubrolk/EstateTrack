const CACHE = "estatetrack-shell-v1";
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches
      .open(CACHE)
      .then((cache) =>
        cache.addAll(["/", "/icon.svg", "/images/estate.webp", "/geist.woff2"]),
      )
      .then(() => self.skipWaiting()),
  );
});
self.addEventListener("activate", (event) =>
  event.waitUntil(self.clients.claim()),
);
self.addEventListener("message", (event) => {
  if (Array.isArray(event.data?.assets)) {
    const urls = event.data.assets.filter(
      (s) =>
        typeof s === "string" &&
        s.startsWith(self.location.origin + "/_next/static/"),
    );
    event.waitUntil(
      caches
        .open(CACHE)
        .then((cache) => Promise.allSettled(urls.map((s) => cache.add(s)))),
    );
  }
});
self.addEventListener("fetch", (event) => {
  const url = new URL(event.request.url);
  if (event.request.method !== "GET" || url.origin !== self.location.origin)
    return;
  if (event.request.mode === "navigate") {
    event.respondWith(
      fetch(event.request)
        .then(async (r) => {
          if (r.ok) {
            const c = await caches.open(CACHE);
            await c.put("/", r.clone());
          }
          return r;
        })
        .catch(() => caches.match("/")),
    );
    return;
  }
  if (
    url.pathname.startsWith("/_next/static/") ||
    ["/images/estate.webp", "/icon.svg", "/geist.woff2"].includes(url.pathname)
  ) {
    event.respondWith(
      caches.match(event.request).then(
        (r) =>
          r ||
          fetch(event.request).then(async (response) => {
            if (response.ok) {
              const c = await caches.open(CACHE);
              await c.put(event.request, response.clone());
            }
            return response;
          }),
      ),
    );
  }
});
