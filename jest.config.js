module.exports = {
  projects: [
    {
      displayName: 'jsdom',
      preset: 'ts-jest',
      testEnvironment: 'jsdom',
      roots: ['<rootDir>/assets'],
      testMatch: [
        '**/__tests__/**/*.+(ts|tsx|js)',
        '**/*.(test|spec).+(ts|tsx|js)',
      ],
      testPathIgnorePatterns: [
        '/node_modules/',
        '<rootDir>/assets/js/components/basketball_5x5/Reports/__pdf_tests__/',
      ],
      transform: {
        '^.+\\.(ts|tsx)$': 'ts-jest',
      },
      moduleNameMapper: {
        '^@react-pdf/renderer$':
          '<rootDir>/assets/js/__mocks__/react-pdf-renderer.js',
      },
      setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
    },
    {
      displayName: 'pdf-render',
      testEnvironment: 'node',
      roots: [
        '<rootDir>/assets/js/components/basketball_5x5/Reports/__pdf_tests__',
      ],
      testMatch: ['**/*.visual.test.tsx'],
      // @react-pdf/renderer (and its whole @react-pdf/* dependency chain) is
      // pure ESM with no CommonJS build, so this project (unlike the jsdom
      // one) runs its TS/TSX as real ECMAScript modules rather than
      // transpiling everything down to CommonJS. This requires Node's
      // `--experimental-vm-modules` flag, wired up via the `test`/
      // `test:watch`/`test:coverage` npm scripts in package.json.
      extensionsToTreatAsEsm: ['.ts', '.tsx'],
      transform: {
        '^.+\\.(ts|tsx)$': ['ts-jest', { useESM: true }],
      },
      // Intentionally no moduleNameMapper override for @react-pdf/renderer here:
      // this project loads the real library and performs real PDF rendering.
      setupFilesAfterEnv: [
        '<rootDir>/assets/js/testUtils/i18nTestSetup.ts',
        '<rootDir>/assets/js/testUtils/imageSnapshotSetup.ts',
        '<rootDir>/assets/js/testUtils/suppressKnownWarnings.ts',
      ],
    },
  ],
  collectCoverageFrom: [
    'assets/**/*.{ts,tsx}',
    '!assets/**/*.d.ts',
    '!assets/**/*.config.{ts,js}',
    '!assets/**/index.{ts,tsx}',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
};
