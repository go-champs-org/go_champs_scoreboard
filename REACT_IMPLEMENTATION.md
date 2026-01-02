# React Implementation Guide - GoChampsScoreboard

This document explains how React components are integrated with Phoenix LiveView in the GoChampsScoreboard application, including architecture patterns, communication flows, and best practices.

## Phoenix LiveView + React Integration

### Entry Point

The main React entry point is [`Scoreboard.tsx`](assets/js/components/Scoreboard.tsx), which serves as the bridge between Phoenix LiveView and React components.

```typescript
// Phoenix LiveView passes these props to React
interface ScoreboardProps {
  api_token: string;
  env: string;
  game_data: string;                    // JSON string from LiveView
  recent_events_data: string;          // JSON string from LiveView
  feature_flags_data?: string;         // JSON string from LiveView
  pushEvent: (event: string, payload: any) => void;      // Send to LiveView
  pushEventTo: (event: string, payload: any, selector: string) => void;
  handleEvent: (event: string, callback: (payload: any) => void) => void;
}
```

### Communication Flow

```
Phoenix LiveView ←→ Scoreboard.tsx ←→ Sport Components (Basketball, etc.)
      ↑                    ↑                      ↑
  Server State      Context Providers     Business Logic Utils
```

1. **LiveView → React**: Data flows from Phoenix through JSON strings (`game_data`, `recent_events_data`)
2. **React → LiveView**: Events flow back through `pushEvent()` functions
3. **React Internal**: Components call pure utility functions for business logic

### Component Registry Pattern

```typescript
const ScoreboardRegistry = {
  basketball: Main,           // Basketball 5x5 component
  default: () => <h1>Not Found</h1>,
};

// Dynamic component loading based on sport_id
const Component = ScoreboardRegistry[game_state.sport_id];
```

## Folder Structure

```
assets/js/
├── components/
│   ├── Scoreboard.tsx                    # Main entry point
│   ├── basketball_5x5/                   # Basketball-specific components
│   │   ├── Main.tsx                     # Basketball main component
│   │   ├── EndLiveModal/               # Feature-specific folder
│   │   │   ├── BasicEndLiveModal.tsx   # Thin UI component
│   │   │   ├── MediumEndLiveModal.tsx  # Thin UI component
│   │   │   ├── useProcessingState.ts   # Custom React hook
│   │   │   ├── timeValidation.ts       # Pure business logic
│   │   │   ├── endLiveFlows.ts         # Pure business logic
│   │   │   ├── processingState.ts      # State management utils
│   │   │   └── __tests__/              # Unit tests for utilities & hooks
│   │   └── Reports/                    # Report generation
│   └── shared/                         # Shared components
├── features/                           # Feature-specific modules
├── hooks/                             # Shared custom React hooks
├── i18n/                              # Internationalization
├── shared/                            # Shared utilities
└── types.ts                           # TypeScript definitions
```

## Architecture Philosophy

Our application follows a **business logic separation pattern** where React components are kept as thin as possible, with all business logic extracted into pure functions that can be easily unit tested.

## React Component Guidelines

### Keep Components Thin

React components should primarily handle:
- **Rendering UI** based on props and state
- **Event handling** by calling business logic functions  
- **State management** through React hooks (useState, custom hooks)
- **Custom hooks** for reusable stateful logic
- **Communication** with Phoenix LiveView through `pushEvent`

### What Components Should NOT Do

❌ **Avoid business logic in components:**
```typescript
// BAD: Business logic in component
const EndLiveModal = ({ game_state, pushEvent }: Props) => {
  const handleEndLive = () => {
    // Don't do time calculations here
    const startedAt = new Date(game_state.live_state.started_at);
    const now = new Date();
    const duration = now.getTime() - startedAt.getTime();
    const shouldWarn = duration <= 45 * 60 * 1000;
    
    if (shouldWarn && !confirm('Game started recently. Sure?')) return;
    
    // Don't do complex async logic here
    if (game_state.view === 'MEDIUM') {
      generateReports().then(() => {
        pushEvent('end-game-live-mode', { assets: [...] });
      }).catch(error => {
        setError(error.message);
      });
    } else {
      pushEvent('end-game-live-mode', {});
    }
  };
};
```

✅ **Extract business logic to pure functions:**
```typescript
// GOOD: Thin component calling business functions
const EndLiveModal = ({ game_state, pushEvent, onClose }: Props) => {
  const [processingManager, setProcessingManager] = useState(() => 
    createProcessingStateManager('idle')
  );
  
  const shouldShowWarning = shouldShowEarlyEndWarning(game_state.live_state.started_at);

  const handleEndLive = async () => {
    const callbacks = {
      pushEvent,
      onCloseModal: onClose,
      onProcessingStart: () => setProcessingManager(current => 
        updateProcessingState(current, 'generating')
      ),
      onError: (error: string) => setProcessingManager(current => 
        updateProcessingState(current, 'error', error)
      ),
    };

    if (game_state.view === 'BASIC') {
      executeBasicEndLive(callbacks);
    } else {
      await executeMediumEndLive(game_state.id, apiHost, callbacks);
    }
  };
};
```

## Business Logic Extraction Patterns

### 1. Time & Date Logic

Extract time calculations into pure functions:

```typescript
// timeValidation.ts
export function shouldShowEarlyEndWarning(startedAt: string): boolean {
  const FORTY_FIVE_MINUTES_MS = 45 * 60 * 1000;
  const gameStartTime = new Date(startedAt);
  const now = new Date();
  return now.getTime() - gameStartTime.getTime() <= FORTY_FIVE_MINUTES_MS;
}

export function getGameDurationInMinutes(startedAt: string): number {
  const gameStartTime = new Date(startedAt);
  const now = new Date();
  return Math.floor((now.getTime() - gameStartTime.getTime()) / (1000 * 60));
}

// timeValidation.test.ts
describe('timeValidation', () => {
  it('returns true for games started less than 45 minutes ago', () => {
    const thirtyMinutesAgo = new Date(Date.now() - 30 * 60 * 1000).toISOString();
    expect(shouldShowEarlyEndWarning(thirtyMinutesAgo)).toBe(true);
  });
});
```

### 2. Async Flow Logic

Extract complex async operations:

```typescript
// endLiveFlows.ts
export interface EndLiveCallbacks {
  pushEvent: (event: string, payload: any) => void;
  onCloseModal: () => void;
}

export interface ReportGenerationCallbacks extends EndLiveCallbacks {
  onProcessingStart: () => void;
  onProcessingComplete: () => void;
  onError: (error: string) => void;
}

export function executeBasicEndLive(callbacks: EndLiveCallbacks): void {
  callbacks.pushEvent('end-game-live-mode', {});
  callbacks.onCloseModal();
}

export async function executeMediumEndLive(
  gameId: string,
  apiBaseUrl: string,
  callbacks: ReportGenerationCallbacks
): Promise<void> {
  try {
    callbacks.onProcessingStart();
    
    const onSuccess = (fileReference: FileReference) => {
      callbacks.onProcessingComplete();
      callbacks.pushEvent('end-game-live-mode', {
        assets: [{ type: 'fiba-scoresheet', url: fileReference.publicUrl }]
      });
      callbacks.onCloseModal();
    };

    await generatorAndUploaders.fibaScoresheet({
      goChampsApiBaseUrl: apiBaseUrl,
      gameId,
      onSuccess,
      onError: (error) => callbacks.onError(error.message),
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    callbacks.onError(message);
  }
}
```

### 3. State Management Logic

Extract state management patterns:

```typescript
// processingState.ts
export type ProcessingState = 'idle' | 'generating' | 'error';

export interface ProcessingStateManager {
  state: ProcessingState;
  error: string | null;
  isProcessing: boolean;
}

export function createProcessingStateManager(initialState: ProcessingState = 'idle'): ProcessingStateManager {
  return {
    state: initialState,
    error: null,
    isProcessing: initialState === 'generating',
  };
}

export function updateProcessingState(
  current: ProcessingStateManager,
  newState: ProcessingState,
  error?: string
): ProcessingStateManager {
  return {
    state: newState,
    error: newState === 'error' ? (error || 'Unknown error') : null,
    isProcessing: newState === 'generating',
  };
}
```

### 4. Custom React Hooks

Wrap stateful logic in custom hooks for reusability and testability:

```typescript
// useProcessingState.ts
import { useState, useCallback } from 'react';

export interface UseProcessingStateReturn {
  processingManager: ProcessingStateManager;
  startProcessing: () => void;
  completeProcessing: () => void;
  setError: (error: string) => void;
  retry: () => void;
  reset: () => void;
}

export function useProcessingState(initialState: ProcessingState = 'idle'): UseProcessingStateReturn {
  const [processingManager, setProcessingManager] = useState(() => 
    createProcessingStateManager(initialState)
  );

  const startProcessing = useCallback(() => {
    setProcessingManager(current => updateProcessingState(current, 'generating'));
  }, []);

  const completeProcessing = useCallback(() => {
    setProcessingManager(current => updateProcessingState(current, 'idle'));
  }, []);

  const setError = useCallback((error: string) => {
    setProcessingManager(current => updateProcessingState(current, 'error', error));
  }, []);

  const retry = useCallback(() => {
    setProcessingManager(resetProcessingState());
  }, []);

  return {
    processingManager,
    startProcessing,
    completeProcessing,
    setError,
    retry,
  };
}

// Component using the hook
const MediumEndLiveModal = ({ game_state, pushEvent, onClose }: Props) => {
  const { processingManager, startProcessing, completeProcessing, setError } = useProcessingState('idle');
  
  const handleEndLive = async () => {
    const callbacks = {
      pushEvent,
      onCloseModal: onClose,
      onProcessingStart: startProcessing,
      onProcessingComplete: completeProcessing,
      onError: setError,
    };

    await executeMediumEndLive(game_state.id, apiHost, callbacks);
  };

  return (
    <Modal>
      {processingManager.isProcessing && <LoadingSpinner />}
      {processingManager.state === 'error' && <ErrorMessage error={processingManager.error} />}
    </Modal>
  );
};
```

## Phoenix LiveView Communication

### Sending Events to LiveView

```typescript
// From React component to Phoenix LiveView
const handleGameEnd = () => {
  pushEvent('end-game-live-mode', {
    assets: [
      { type: 'fiba-scoresheet', url: 'https://...' }
    ]
  });
};

const handlePlayerUpdate = (playerId: string, stats: PlayerStats) => {
  pushEvent('update-player-stats', {
    player_id: playerId,
    stats: stats
  });
};
```

### Receiving Data from LiveView

```typescript
// LiveView sends JSON strings that React parses
const game_state: GameState = JSON.parse(game_data).result;
const recent_events: EventLog[] = JSON.parse(recent_events_data).result;
```

## Testing Strategy

### ✅ Test Pure Functions (Business Logic)

```typescript
// endLiveFlows.test.ts
describe('executeMediumEndLive', () => {
  it('calls onProcessingStart when starting generation', async () => {
    const mockCallbacks = {
      onProcessingStart: jest.fn(),
      onError: jest.fn(),
      // ... other callbacks
    };

    await executeMediumEndLive('game-id', 'api-url', mockCallbacks);
    
    expect(mockCallbacks.onProcessingStart).toHaveBeenCalled();
  });
});
```

### ✅ Test Custom React Hooks

Use `@testing-library/react` for hook testing:

```typescript
// useProcessingState.test.ts
import { renderHook, act } from '@testing-library/react';
import { useProcessingState } from '../useProcessingState';

describe('useProcessingState', () => {
  it('initializes with idle state by default', () => {
    const { result } = renderHook(() => useProcessingState());
    
    expect(result.current.processingManager.state).toBe('idle');
    expect(result.current.processingManager.isProcessing).toBe(false);
  });

  it('transitions to generating state when startProcessing is called', () => {
    const { result } = renderHook(() => useProcessingState());
    
    act(() => {
      result.current.startProcessing();
    });
    
    expect(result.current.processingManager.state).toBe('generating');
    expect(result.current.processingManager.isProcessing).toBe(true);
  });

  it('maintains function reference stability between renders', () => {
    const { result, rerender } = renderHook(() => useProcessingState());
    
    const firstRenderStartProcessing = result.current.startProcessing;
    rerender();
    const secondRenderStartProcessing = result.current.startProcessing;
    
    expect(firstRenderStartProcessing).toBe(secondRenderStartProcessing);
  });
});
```

### ❌ Don't Test React Components

React components are kept thin and primarily handle UI rendering. Testing them provides little value since:
- They contain minimal logic
- UI testing is brittle and slow
- Business logic is already tested in utility functions

## Build & Compilation

### Asset Pipeline

React components are compiled through Phoenix's asset pipeline:

1. **Development**: `mix phx.server` watches and rebuilds assets
2. **Production**: `mix assets.deploy` compiles optimized bundles
3. **TypeScript**: Compiled to JavaScript with type checking
4. **Bundling**: esbuild processes and bundles React components

### Development Scripts

The project includes helpful npm scripts for development:

```bash
# Code formatting with Prettier
npm run format        # Format all JS/TS/React files
npm run format-check  # Check if files are properly formatted

# Testing
npm run test          # Run all Jest tests once
npm run test:watch    # Run tests in watch mode (re-runs on file changes)
npm run test:coverage # Run tests with coverage report
```

### Configuration Files

- `assets/tsconfig.json` - TypeScript configuration
- `assets/package.json` - Node.js dependencies
- `config/dev.exs` / `config/prod.exs` - Phoenix asset configuration

## Best Practices Summary

### Component Structure
- ✅ Keep components under 100 lines when possible
- ✅ Extract business logic to separate files
- ✅ Use custom hooks for reusable stateful logic
- ✅ Use TypeScript for type safety
- ✅ Implement proper error boundaries

### Communication
- ✅ Use `pushEvent` for LiveView communication
- ✅ Parse JSON data from LiveView props
- ✅ Handle loading and error states gracefully

### Testing
- ✅ Unit test pure functions extensively
- ✅ Test custom React hooks with @testing-library/react
- ✅ Test edge cases and error conditions
- ✅ Use mocks for external dependencies
- ❌ Avoid testing React component rendering

### Code Organization
- ✅ Group related files in feature folders
- ✅ Separate utilities from components
- ✅ Use consistent naming conventions
- ✅ Document complex business logic

This architecture ensures maintainable, testable code while leveraging the real-time capabilities of Phoenix LiveView with the rich interactivity of React.