# EndLiveModal Refactoring

This directory contains the refactored EndLiveModal component that now supports different basketball views with appropriate behaviors and UI. The business logic has been extracted into testable utility functions and reusable custom hooks.

## Structure

### Files
- `../EndLiveModal.tsx` - Main entry point that routes to appropriate modal based on view type
- `BasicEndLiveModal.tsx` - Simple confirmation modal for BASIC view (thin component)
- `MediumEndLiveModal.tsx` - Enhanced modal with report generation for MEDIUM view (thin component)
- `useProcessingState.ts` - Custom React hook for processing state management
- `timeValidation.ts` - Pure functions for time-based validations
- `endLiveFlows.ts` - Business logic for different end live flows
- `processingState.ts` - State management utilities for async operations
- `__tests__/` - Unit tests for utility functions and custom hooks (no React component tests)

## Architecture Philosophy

### Testable Business Logic
All business logic has been extracted into pure functions and utility modules:

- **Time Validation** (`timeValidation.ts`) - Game duration calculations and warnings
- **End Live Flows** (`endLiveFlows.ts`) - Core business logic for ending games
- **Processing State** (`processingState.ts`) - State management utilities for async operations
- **Custom Hook** (`useProcessingState.ts`) - Reusable stateful logic for processing workflows

### Thin React Components
React components are kept minimal and only handle:
- UI rendering
- User interactions
- Calling utility functions and custom hooks
- Managing local component state through hooks

### Custom React Hooks
Custom hooks encapsulate reusable stateful logic:
- **`useProcessingState`** - Manages async processing workflows with start/complete/error/retry states
- Provides stable function references with `useCallback`
- Encapsulates complex state transitions in a testable way

### Unit Testing Strategy
- ✅ **Test utility functions** - Pure functions with clear inputs/outputs
- ✅ **Test custom hooks** - Using `@testing-library/react` with `renderHook`
- ❌ **No React component tests** - Components are thin wrappers around utilities and hooks
- ✅ **Comprehensive coverage** - All business logic paths tested in isolation

## Features by View

### BASIC View
- Simple confirmation dialog
- 45-minute warning if game started recently
- Basic message explaining what happens when ending live mode
- Immediate end without report generation

### MEDIUM View
- Enhanced confirmation dialog
- 45-minute warning if game started recently
- Detailed message mentioning automatic report generation
- Information about which reports will be generated (FIBA scoresheet)
- Loading state during report generation/upload
- Modal cannot be closed during processing
- Error handling with retry functionality
- Progress indication

## Usage

The API remains unchanged for callers:

```tsx
<EndLiveModal
  game_state={gameState}
  showModal={showModal}
  onCloseModal={onCloseModal}
  pushEvent={pushEvent}
/>
```

The component internally routes to the appropriate modal based on `game_state.view_settings_state.view`.

## Utility Functions

### `timeValidation.ts`
```typescript
shouldShowEarlyEndWarning(startedAt: string): boolean
getGameDurationInMinutes(startedAt: string): number
```

### `endLiveFlows.ts`
```typescript
executeBasicEndLive(callbacks: EndLiveCallbacks): void
executeMediumEndLive(gameId: string, apiBaseUrl: string, callbacks: ReportGenerationCallbacks): Promise<void>
```

### `processingState.ts`
```typescript
createProcessingStateManager(initialState?: ProcessingState): ProcessingStateManager
updateProcessingState(current: ProcessingStateManager, newState: ProcessingState, error?: string): ProcessingStateManager
resetProcessingState(): ProcessingStateManager
```

### `useProcessingState.ts` (Custom Hook)
```typescript
useProcessingState(initialState?: ProcessingState): UseProcessingStateReturn

interface UseProcessingStateReturn {
  processingManager: ProcessingStateManager;
  startProcessing: () => void;
  completeProcessing: () => void;
  setError: (error: string) => void;
  retry: () => void;
  reset: () => void;
}
```

## Error Handling

The MEDIUM view includes comprehensive error handling:
- Network errors during report generation
- File upload failures
- Retry mechanism with hook-managed state
- User-friendly error messages
- Proper state management during async operations

## Future Extensibility

The structure is designed to easily accommodate new view types:
1. Create a new modal component (e.g., `AdvancedEndLiveModal.tsx`)
2. Add the view case to `../EndLiveModal.tsx`
3. Add any new translation keys
4. Reuse existing hooks and utilities
5. Update tests for new business logic

The pattern keeps the caller API stable while allowing internal complexity to grow as needed. Custom hooks can be reused across different modal types for consistent behavior.