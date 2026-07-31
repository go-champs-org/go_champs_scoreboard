// Wires up jest-image-snapshot's `toMatchImageSnapshot` matcher for the
// "pdf-render" Jest project (see jest.config.js). Reused as-is by any test
// in that project that needs to pixel-diff a rendered image - currently
// just assets/js/components/basketball_5x5/Reports/__pdf_tests__/FibaScoresheet.visual.test.tsx.
import { toMatchImageSnapshot } from 'jest-image-snapshot';

expect.extend({ toMatchImageSnapshot });
