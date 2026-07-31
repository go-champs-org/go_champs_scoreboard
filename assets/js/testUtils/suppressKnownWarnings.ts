// Suppresses one specific, known-benign `console.warn` from
// @react-pdf/renderer's image-fetching code (`fetchImage` in
// node_modules/@react-pdf/layout/lib/index.js, which calls
// `console.warn(e.message)` whenever it can't resolve an
// `<Image src={...}>`). Several anonymized fields in our test fixtures
// point at deliberately-unfetchable placeholder values - signature
// placeholders like "SIGNATURE-0003", and `https://example.invalid/...`
// logo/sponsor URLs - all from lib/mix/tasks/fiba_scoresheet.export_game.ex's
// anonymization pass - so this fires routinely and is expected. In
// production, every `signature`/`logo_url` field is either null or a real,
// fetchable value, so this is specific to these test fixtures.
//
// The underlying error's exact message isn't stable enough to match on
// text: it's been observed as both a raw `ENOENT: ...` message and (in this
// environment, depending on Node/undici's fetch internals) a generic
// "fetch failed" - and neither form includes which URL/src actually failed,
// so no message-based pattern can reliably distinguish "our known-benign
// fixture placeholder" from "an unrelated real bug" anyway. Instead this
// checks the call stack for the one thing that *is* stable: warnings
// genuinely originating from `fetchImage` in `@react-pdf/layout`. Anything
// else still prints normally.
function isFromReactPdfFetchImage(): boolean {
  const stack = new Error().stack ?? '';
  return stack.includes('@react-pdf/layout') && stack.includes('fetchImage');
}

const originalWarn = console.warn;

console.warn = (...args: unknown[]) => {
  if (isFromReactPdfFetchImage()) {
    return;
  }
  originalWarn(...args);
};
