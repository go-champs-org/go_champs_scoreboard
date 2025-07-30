// Test setup file for Jest
// Add global test utilities and mocks here

import '@testing-library/jest-dom';

// Mock fetch API for tests
const mockFetch = jest.fn();
(global as any).fetch = mockFetch;

// Clear all mocks before each test
beforeEach(() => {
  jest.clearAllMocks();
});

// Add custom matchers or global test utilities here
// expect.extend({
//   Add custom Jest matchers if needed
// });
