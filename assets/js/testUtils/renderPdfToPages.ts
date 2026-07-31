// Rasterizes a rendered PDF (as produced by `@react-pdf/renderer`'s
// `pdf(...).toBuffer()`) into per-page PNG images plus extracted text, for
// use by the "pdf-render" Jest project's visual-regression tests
// (assets/js/components/basketball_5x5/Reports/__pdf_tests__).
//
// Stack, and why (verified directly against this repo's pinned Node
// version, v18.20.4, before committing to it - see the plan doc's
// "Suite 2 (current)" section for the full rationale):
//
// - `pdfjs-dist@4.8.69` is pinned exactly: it's the last 4.x release whose
//   `engines` field still says `node >= 18` (4.9.155+ requires Node >= 20).
//   We import its "legacy" Node-compatible build
//   (`pdfjs-dist/legacy/build/pdf.mjs`) rather than the default `main`
//   entry (`build/pdf.mjs`), which targets browsers/bundlers. The package
//   has no `exports` map restricting subpath imports, so this resolves via
//   plain Node file resolution.
// - `pdfjs-dist`'s own built-in Node canvas support (`NodeCanvasFactory` in
//   its bundled source) dynamically loads the classic `canvas` package
//   (node-canvas, cairo/pango-based, needs native compilation at install
//   time) - exactly what we're avoiding. Instead we supply our own
//   `CanvasFactory` backed by `@napi-rs/canvas` (prebuilt native bindings
//   per-platform, no compilation step, `engines: node >= 10`). This is the
//   documented extension point: `getDocument()` accepts a `CanvasFactory`
//   *class* (not a pre-built instance - passing an instance via the older
//   `canvasFactory` option still works but is deprecated as of this
//   version, verified via `pdfjs-dist`'s own deprecation warning) which it
//   instantiates itself and calls `.create()`/`.reset()`/`.destroy()` on -
//   the same shape as `pdfjs-dist`'s internal `BaseCanvasFactory`
//   (see node_modules/pdfjs-dist/types/src/display/canvas_factory.d.ts).
// - `standardFontDataUrl` points at `pdfjs-dist`'s own bundled standard
//   fonts directory so PDF standard fonts (e.g. Helvetica, which
//   `@react-pdf/renderer` falls back to since `FibaScoresheet.tsx` and its
//   subcomponents register no custom fonts - verified via
//   `grep -rn "Font.register\|fontFamily"` returning zero matches) resolve
//   to real glyph data instead of a lower-fidelity substitution.
import * as path from 'path';
import { fileURLToPath } from 'url';
import { createCanvas, type Canvas } from '@napi-rs/canvas';
// eslint-disable-next-line @typescript-eslint/no-var-requires
import * as pdfjsLib from 'pdfjs-dist/legacy/build/pdf.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const REPO_ROOT = path.resolve(__dirname, '..', '..', '..');
const STANDARD_FONT_DATA_URL = `${path.resolve(
  REPO_ROOT,
  'node_modules/pdfjs-dist/standard_fonts',
)}/`;

// A minimal canvas factory matching pdfjs-dist's `BaseCanvasFactory`
// interface, backed by @napi-rs/canvas instead of the DOM or node-canvas.
// pdfjs-dist instantiates this itself (`new CanvasFactory({ ownerDocument,
// enableHWA })`), so the constructor must accept (and can ignore) those
// options.
class NapiCanvasFactory {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  constructor(_options?: { ownerDocument?: unknown; enableHWA?: boolean }) {}

  create(width: number, height: number): { canvas: Canvas; context: unknown } {
    if (width <= 0 || height <= 0) {
      throw new Error('Invalid canvas size');
    }
    const canvas = createCanvas(width, height);
    return { canvas, context: canvas.getContext('2d') };
  }

  reset(
    canvasAndContext: { canvas: Canvas | null },
    width: number,
    height: number,
  ): void {
    if (!canvasAndContext.canvas) {
      throw new Error('Canvas is not specified');
    }
    if (width <= 0 || height <= 0) {
      throw new Error('Invalid canvas size');
    }
    canvasAndContext.canvas.width = width;
    canvasAndContext.canvas.height = height;
  }

  destroy(canvasAndContext: {
    canvas: Canvas | null;
    context: unknown | null;
  }): void {
    if (!canvasAndContext.canvas) {
      throw new Error('Canvas is not specified');
    }
    canvasAndContext.canvas.width = 0;
    canvasAndContext.canvas.height = 0;
    canvasAndContext.canvas = null;
    canvasAndContext.context = null;
  }
}

export interface RenderedPage {
  /** PNG-encoded rasterization of the page, for pixel-diff snapshotting. */
  png: Buffer;
  /** Extracted text content, for fast smoke-check assertions. */
  text: string;
}

export interface RenderedPdf {
  numPages: number;
  pages: RenderedPage[];
}

/**
 * Rasterizes every page of a PDF buffer into a PNG image plus its extracted
 * text, using pdfjs-dist (for parsing/rendering/text-extraction) and
 * @napi-rs/canvas (for the actual pixel surface + PNG encoding).
 *
 * @param pdfBuffer The full PDF file contents, e.g. from
 *   `pdf(<Doc />).toBuffer()` drained into a Buffer.
 * @param scale Render scale for the PDF -> pixel conversion (higher = more
 *   legible / larger images). Callers should treat this as a tunable
 *   starting point, not a final tuned value - see the visual test file's
 *   own comment on this.
 */
export async function renderPdfToPages(
  pdfBuffer: Buffer,
  scale = 2,
): Promise<RenderedPdf> {
  const loadingTask = (pdfjsLib as any).getDocument({
    data: new Uint8Array(pdfBuffer),
    CanvasFactory: NapiCanvasFactory,
    standardFontDataUrl: STANDARD_FONT_DATA_URL,
  });

  const doc = await loadingTask.promise;
  const canvasFactory = new NapiCanvasFactory();
  const pages: RenderedPage[] = [];

  try {
    for (let pageNumber = 1; pageNumber <= doc.numPages; pageNumber++) {
      const page = await doc.getPage(pageNumber);
      try {
        const viewport = page.getViewport({ scale });
        const { canvas, context } = canvasFactory.create(
          Math.ceil(viewport.width),
          Math.ceil(viewport.height),
        );

        await page.render({ canvasContext: context as any, viewport })
          .promise;

        const textContent = await page.getTextContent();
        const text = textContent.items
          .map((item: any) => ('str' in item ? item.str : ''))
          .join(' ');

        pages.push({ png: canvas.toBuffer('image/png'), text });
      } finally {
        page.cleanup();
      }
    }
  } finally {
    await doc.destroy();
  }

  return { numPages: doc.numPages, pages };
}
