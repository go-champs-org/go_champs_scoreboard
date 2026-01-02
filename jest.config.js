module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  roots: ['<rootDir>/assets'],
  testMatch: [
    '**/__tests__/**/*.+(ts|tsx|js)',
    '**/*.(test|spec).+(ts|tsx|js)'
  ],
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest',
  },
  moduleNameMapper: {
    '^@react-pdf/renderer$': '<rootDir>/assets/js/__mocks__/react-pdf-renderer.js',
  },
  collectCoverageFrom: [
    'assets/**/*.{ts,tsx}',
    '!assets/**/*.d.ts',
    '!assets/**/*.config.{ts,js}',
    '!assets/**/index.{ts,tsx}',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: [
    'text',
    'lcov',
    'html'
  ],
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
};
