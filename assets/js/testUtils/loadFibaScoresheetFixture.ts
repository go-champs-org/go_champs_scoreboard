import * as fs from 'fs';
import * as path from 'path';
import { fileURLToPath } from 'url';

// Repo root, resolved relative to this file's on-disk location
// (assets/js/testUtils -> assets/js -> assets -> repo root), so it does not
// depend on the process's current working directory when tests run.
// Uses import.meta.url (rather than __dirname) because this module is
// loaded as a real ES module by the "pdf-render" Jest project.
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const REPO_ROOT = path.resolve(__dirname, '..', '..', '..');

/**
 * Reads a fixture file from disk, given a path relative to the repo root
 * (e.g. "test/fixtures/fiba_scoresheet/normal_game.json").
 *
 * This is the single shared entry point both the JS PDF-rendering suite
 * (`assets/js/components/basketball_5x5/Reports/__pdf_tests__`) and the
 * Elixir regression suite
 * (`test/go_champs_scoreboard/sports/basketball/reports/fiba_scoresheet_regression_test.exs`)
 * conceptually point at the exact same fixture files under
 * `test/fixtures/fiba_scoresheet/`.
 */
export function loadFibaScoresheetFixture(
  relativePathFromRepoRoot: string,
): string {
  const absolutePath = path.resolve(REPO_ROOT, relativePathFromRepoRoot);
  return fs.readFileSync(absolutePath, 'utf-8');
}
