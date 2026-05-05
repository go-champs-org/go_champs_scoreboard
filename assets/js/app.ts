// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html';
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from 'phoenix';
import { LiveSocket } from 'phoenix_live_view';
import topbar from '../vendor/topbar';
import LiveReact, { initLiveReact } from 'phoenix_live_react';
import Scoreboard from './components/Scoreboard';
import StreamViews from './components/StreamViews';
import ReportViewer from './shared/ReportViewer';

// Initialize i18n
import i18n from './i18n';

// load react components
const hooks = { LiveReact };
const csfrElem = document.querySelector("meta[name='csrf-token']");
const csrfToken = csfrElem ? csfrElem.getAttribute('content') : 'token';
const liveSocket = new LiveSocket('/live', Socket, {
  heartbeatIntervalMs: 25_000, // Send heartbeat every 25s to prevent Heroku H15 (55s idle timeout)
  longPollFallbackMs: false, // Disable longpoll fallback - WebSocket only
  hooks,
  params: { _csrf_token: csrfToken },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' });
window.addEventListener('phx:page-loading-start', (_info) => topbar.show(300));
window.addEventListener('phx:page-loading-stop', (_info) => topbar.hide());

// Function to show WebSocket blocked banner
function showWebSocketBlockedBanner() {
  if (document.getElementById('ws-blocked-banner')) return;

  const banner = document.createElement('div');
  banner.id = 'ws-blocked-banner';
  banner.style.cssText =
    'position:fixed;top:0;left:0;right:0;z-index:9999;margin:0;border-radius:0;background-color:#970c10;text-align:center;padding:0.75rem 1.5rem;';
  banner.className = 'notification is-warning';
  banner.innerHTML = `
    <strong>⚠️ ${i18n.t('system.connection.websocketBlockedTitle')}</strong>
    ${i18n.t('system.connection.websocketBlockedMessage')}
    <button class="delete" onclick="document.getElementById('ws-blocked-banner').remove()"></button>
  `;
  document.body.prepend(banner);
}

// connect if there are any LiveViews on the page
liveSocket.connect();

// Check WebSocket connection status after initial connection attempt
// Only show banner if there are LiveView elements on the page that need a connection
setTimeout(() => {
  // Check if there are any LiveView elements on the page
  const hasLiveView = document.querySelector('[data-phx-main]') !== null;

  if (hasLiveView) {
    const socket = liveSocket.getSocket();
    if (!socket.isConnected()) {
      // LiveView failed to connect - likely WebSocket is blocked
      console.error('[LiveView] Failed to establish WebSocket connection');
      showWebSocketBlockedBanner();
    } else {
      console.log('[LiveView] Successfully connected via WebSocket');
    }
  }
}, 2000);

// Optionally render the React components on page load as
// well to speed up the initial time to render.
// The pushEvent, pushEventTo and handleEvent props will not be passed here.
document.addEventListener('DOMContentLoaded', (e) => {
  initLiveReact();
});

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
window.Components = {
  ReportViewer,
  Scoreboard,
  StreamViews,
};
