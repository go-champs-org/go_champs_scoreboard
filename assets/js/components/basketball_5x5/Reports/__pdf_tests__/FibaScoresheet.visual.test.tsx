// This suite shares its fixtures with the Elixir regression suite at
// test/go_champs_scoreboard/sports/basketball/reports/fiba_scoresheet_regression_test.exs
// (see test/fixtures/fiba_scoresheet/*.json). See
// test/fixtures/fiba_scoresheet/README.md for the full two-suite
// architecture, how to add a new scenario/fixture here, and how to update
// baseline images intentionally.
//
// Unlike the rest of the Jest suite, this project runs with a real,
// unmocked @react-pdf/renderer (see jest.config.js's "pdf-render" project),
// so it actually renders each fixture to a real PDF, rasterizes each page
// to a PNG via pdfjs-dist + @napi-rs/canvas (see
// ../../../../testUtils/renderPdfToPages.ts for the full rationale), and
// pixel-diffs the result against a committed baseline via
// jest-image-snapshot - replacing an earlier text-snapshot mechanism (an
// npm package that extracted PDF text for snapshotting, since removed as a
// dependency of this repo entirely) that this suite superseded once a real
// captured production game
// (test/fixtures/fiba_scoresheet/real_games/final-cbi-05-10-2026.expected.json)
// made visual regression worthwhile. Text extraction is still used here,
// but only for fast smoke-check assertions (team names present) ahead of
// the heavier pixel comparison - and it now comes from pdfjs-dist itself
// (which we already need for rasterization), so that older package isn't
// needed anywhere in this design.

import React from 'react';
import { pdf } from '@react-pdf/renderer';

import FibaScoresheet, { parseFibaScoresheetData } from '../FibaScoresheet';
import { loadFibaScoresheetFixture } from '../../../../testUtils/loadFibaScoresheetFixture';
import { renderPdfToPages } from '../../../../testUtils/renderPdfToPages';

async function renderToPdfBuffer(
  scoresheetData: ReturnType<typeof parseFibaScoresheetData>,
): Promise<Buffer> {
  const stream = await pdf(
    <FibaScoresheet scoresheetData={scoresheetData} />,
  ).toBuffer();

  const chunks: Buffer[] = [];
  for await (const chunk of stream as unknown as AsyncIterable<Buffer>) {
    chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
  }
  return Buffer.concat(chunks);
}

interface FixtureCase {
  name: string;
  path: string;
  expectedNumPages: number;
  expectedStrings: string[];
}

const fixtures: FixtureCase[] = [
  {
    name: 'normal_game',
    path: 'test/fixtures/fiba_scoresheet/normal_game.json',
    // team_a.score=5, team_b.score=4 (<=160, no extended page);
    // info.game_report is blank (no game-report page)
    expectedNumPages: 2,
    expectedStrings: ['Eagles', 'Hawks'],
  },
  {
    name: 'game_with_deleted_event',
    path: 'test/fixtures/fiba_scoresheet/game_with_deleted_event.json',
    // team_a.score=4, team_b.score=0
    expectedNumPages: 2,
    expectedStrings: ['Comets', 'Meteors'],
  },
  {
    name: 'game_with_corrected_payload',
    path: 'test/fixtures/fiba_scoresheet/game_with_corrected_payload.json',
    // team_a.score=3, team_b.score=1
    expectedNumPages: 2,
    expectedStrings: ['Suns', 'Sharks'],
  },
  {
    name: 'game_with_out_of_order_add',
    path: 'test/fixtures/fiba_scoresheet/game_with_out_of_order_add.json',
    // team_a.score=3, team_b.score=0
    expectedNumPages: 2,
    expectedStrings: ['Bulls', 'Bucks'],
  },
  {
    name: 'real_game_final_cbi_05_10_2026',
    path: 'test/fixtures/fiba_scoresheet/real_games/final-cbi-05-10-2026.expected.json',
    // A real, anonymized production game's contract (team names/scores are
    // real, people are anonymized). team_a.score=81, team_b.score=64 (both
    // <=160, no extended page); info.game_report is blank (no game-report
    // page). Note: this fixture deliberately has no `game_id` key and null
    // info.actual_start_datetime/actual_end_datetime - stripped by the
    // Elixir suite because they're non-deterministic on replay, not a bug.
    expectedNumPages: 2,
    expectedStrings: ['PINHEIROS', 'SESI FRANCA'],
  },
];

// Render scale for the PDF -> pixel conversion. Higher = more legible /
// larger baseline images, at the cost of slower rasterization and bigger
// committed PNGs. 2 is a starting point chosen for legibility at a
// reasonable file size, not a final tuned value - revisit once real
// baselines exist and have been reviewed.
const RENDER_SCALE = 2;

// jest-image-snapshot's pixelmatch-based diff threshold.
//
// Note on units (verified by reading
// node_modules/jest-image-snapshot/src/diff-snapshot.js directly, since
// this is easy to misread): despite the `'percent'` name,
// `failureThreshold` is compared against `diffPixelCount / totalPixels` -
// a raw 0-1 fraction, not a 0-100 percentage. So `0.01` means "1% of
// pixels may differ", not "0.01%".
//
// Verified directly in this environment (five renders of the same fixture
// in one process, and separately two renders in two separate process
// invocations, produced byte-identical PNGs every time - consistent with
// FibaScoresheet.tsx registering no custom fonts, so there's no
// OS-font-substitution nondeterminism to absorb) that rendering is fully
// deterministic here, so a tight threshold is safe. That determinism check
// is also what caught the units mix-up above: an initial `0.01` "percent"
// (i.e. 1% - allowing ~20,000 px on this page's ~2M-pixel raster) was far
// too loose - a deliberate one-fixture score edit (5 -> 55) only changed
// 109 px (a diffRatio of ~0.0000543, i.e. ~0.0054%) and still passed.
// `0.00002` (0.002%, ~40 px here) was chosen instead: tight enough to
// catch that same single-character content change with room to spare,
// while still leaving a small non-zero allowance rather than requiring
// byte-for-byte equality. Treat this as tunable, not final, once more
// baselines have been reviewed over time.
const IMAGE_SNAPSHOT_OPTIONS = {
  failureThreshold: 0.00002,
  failureThresholdType: 'percent' as const,
};

describe.each(fixtures)(
  'FibaScoresheet PDF rendering: $name',
  ({ name, path, expectedNumPages, expectedStrings }) => {
    it('renders a PDF whose pages match the contract and a golden image snapshot', async () => {
      const rawJson = loadFibaScoresheetFixture(path);
      const scoresheetData = parseFibaScoresheetData(rawJson);

      const buffer = await renderToPdfBuffer(scoresheetData);
      expect(buffer.length).toBeGreaterThan(0);

      const { numPages, pages } = await renderPdfToPages(buffer, RENDER_SCALE);

      expect(numPages).toBe(expectedNumPages);
      expect(pages).toHaveLength(expectedNumPages);

      pages.forEach((page, pageIndex) => {
        // Fast, clear-failure-message smoke check before the heavier pixel
        // comparison below.
        for (const expectedString of expectedStrings) {
          expect(page.text).toContain(expectedString);
        }

        expect(page.png).toMatchImageSnapshot({
          ...IMAGE_SNAPSHOT_OPTIONS,
          customSnapshotIdentifier: `${name}-page-${pageIndex + 1}`,
        });
      });
    });
  },
);
