#!/usr/bin/env bash
# Builds the web app for Cloudflare Pages.
#
# No offline service worker: Flutter's default (offline-first) keeps serving
# the previous build from the browser's cache, so deploys look "not live"
# until a visitor reloads more than once. The worker shipped here instead
# clears those caches, unregisters itself and reloads open tabs, so browsers
# that installed the old one pick up the current build on their next visit.
set -euo pipefail
cd "$(dirname "$0")/.."
"${FLUTTER:-$HOME/flutter-sdk/bin/flutter}" build web --release --pwa-strategy=none "$@"
cat > build/web/flutter_service_worker.js <<'JS'
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.map((k) => caches.delete(k)));
    await self.registration.unregister();
    const tabs = await self.clients.matchAll({ type: 'window' });
    tabs.forEach((tab) => tab.navigate(tab.url));
  })());
});
JS
echo "Built build/web (no offline cache; old service workers retire themselves)."
