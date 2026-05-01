# GoChampsScoreboard Games Module Architecture

This document explains the architecture and design patterns used in the `GoChampsScoreboard.Games` module, specifically focusing on the state management system, Redis integration, and the relationship between models and their manipulation modules.

## Overview

The Games module implements a state management system where game data is stored in Redis as JSON and manipulated through specialized modules. The architecture follows a clear separation between **Models** (data structures) and **Plural Classes** (business logic modules).

## Key Architectural Patterns

### 1. Redis State Persistence with Poison Encoding

All models in the `models/` directory are designed to be stored in Redis as JSON strings using the Poison library for serialization/deserialization.

#### Model Requirements for Redis Storage

Every model must be **Poison encodable and decodable** to work with Redis:

```elixir
defmodule GoChampsScoreboard.Games.Models.LiveState do
  @derive [Poison.Encoder]  # Automatic encoding
  
  defstruct [:state, :started_at, :ended_at]
  
  # Custom decoder for complex data types (DateTime handling)
  defimpl Poison.Decoder, for: GoChampsScoreboard.Games.Models.LiveState do
    def decode(%{state: state, started_at: started_at, ended_at: ended_at}, _options) do
      # Custom logic for DateTime conversion
    end
  end
end
```

#### Why Custom Decoders?

Models with complex data types (like `DateTime`, `Decimal`, etc.) need custom `Poison.Decoder` implementations because:
- Redis stores everything as strings
- JSON doesn't have native DateTime support
- Custom types need special handling during deserialization

### 2. GameState as the Root Aggregate

`GameState` is the central aggregate that contains all game information:

```elixir
defmodule GoChampsScoreboard.Games.Models.GameState do
  defstruct [
    :id,
    :away_team,           # TeamState
    :home_team,           # TeamState  
    :clock_state,         # GameClockState
    :live_state,          # LiveState
    :view_settings_state, # ViewSettingsState
    :officials,           # [OfficialState]
    :protest,             # ProtestState
    :info                 # InfoState
  ]
  
  # Specialized from_json with nested structure mapping
  def from_json(curr_game_json) do
    Poison.decode!(curr_game_json,
      as: %__MODULE__{
        away_team: %TeamState{
          coaches: [%CoachState{}],
          players: [%PlayerState{}]
        },
        home_team: %TeamState{
          coaches: [%CoachState{}],
          players: [%PlayerState{}]
        },
        # ... other nested structures
      }
    )
  end
end
```

### 3. Plural Classes - Business Logic Modules

Each major entity has a corresponding "plural" module that knows how to manipulate that piece of the `GameState`:

#### Pattern: Singular Model + Plural Logic Module

| Model (Data) | Plural Class (Logic) | Purpose |
|--------------|---------------------|---------|
| `PlayerState` | `Players` | Player manipulation logic |
| `CoachState` | `Coaches` | Coach manipulation logic |
| `TeamState` | `Teams` | Team-level operations |
| `GameState` | `Games` | Game lifecycle management |
| `OfficialState` | `Officials` | Officials management |

#### Example: Players Module

```elixir
defmodule GoChampsScoreboard.Games.Players do
  alias GoChampsScoreboard.Games.Models.PlayerState

  # Bootstrap new player instances
  @spec bootstrap(String.t(), number()) :: PlayerState.t()
  def bootstrap(name, number) do
    Ecto.UUID.generate()
    |> PlayerState.new(name, number)
  end

  # Business logic for stats updates
  @spec update_manual_stats_values(PlayerState.t(), Stat.t(), String.t()) :: PlayerState.t()
  def update_manual_stats_values(player_state, player_stat, operation) do
    # Validation and calculation logic
  end

  # State transitions
  @spec update_state(PlayerState.t(), PlayerState.state()) :: PlayerState.t()
  def update_state(player_state, player_state_update) do
    %{player_state | state: player_state_update}
  end
end
```

#### Example: Teams Module (GameState Manipulation)

```elixir
defmodule GoChampsScoreboard.Games.Teams do
  # Operates on the entire GameState to modify team-related data
  @spec add_player(GameState.t(), String.t(), PlayerState.t()) :: GameState.t()
  def add_player(game_state, team_type, player) do
    case team_type do
      "home" ->
        game_state
        |> Map.update!(:home_team, fn team -> add_player_to_team(team, player) end)
      
      "away" ->
        game_state
        |> Map.update!(:away_team, fn team -> add_player_to_team(team, player) end)
    end
  end
end
```

### 4. Caching Strategy

#### GameStateCache Module

```elixir
defmodule GoChampsScoreboard.Games.GameStateCache do
  @two_days_in_seconds 172_800

  @spec get(String.t()) :: {:ok, GameState.t()} | {:ok, nil} | {:error, any()}
  def get(game_id) do
    case Redix.command(:games_cache, ["GET", cache_key(game_id)]) do
      {:ok, nil} -> {:ok, nil}
      {:ok, game_json} -> {:ok, GameState.from_json(game_json)}  # Poison decode
      {:error, error} -> {:error, error}
    end
  end

  @spec update(GameState.t()) :: GameState.t()
  def update(game_state) do
    Redix.command(:games_cache, [
      "SET", 
      cache_key(game_state.id), 
      game_state,              # Poison encode (via String.Chars impl)
      "EX", 
      @two_days_in_seconds
    ])
    
    game_state
  end
end
```

#### String.Chars Implementation

Models implement `String.Chars` to enable automatic Poison encoding when storing in Redis:

```elixir
defimpl String.Chars, for: GoChampsScoreboard.Games.Models.GameState do
  def to_string(game) do
    Poison.encode!(game)  # Automatic JSON serialization
  end
end
```

## Module Organization and Responsibilities

### Models Directory (`models/`)

Contains pure data structures that:
- Define the shape of game state data
- Are Poison encodable/decodable for Redis storage
- Have no business logic (data only)
- Handle complex type conversions in custom decoders

**Examples:**
- `game_state.ex` - Root aggregate
- `team_state.ex` - Team information and aggregated stats
- `player_state.ex` - Individual player data and stats
- `live_state.ex` - Game timing and lifecycle state

### Root Level Modules

Contain business logic that:
- Know how to manipulate specific parts of GameState
- Handle validation and business rules
- Provide bootstrapping functions
- Implement complex operations across multiple entities

**Examples:**
- `games.ex` - Game lifecycle, bootstrapping, cache management
- `teams.ex` - Team-level operations, cross-team logic
- `players.ex` - Player statistics, state transitions
- `coaches.ex` - Coach management and stats

### Supporting Infrastructure

- `game_state_cache.ex` - Redis integration for GameState persistence
- `bootstrapper.ex` - Initial game state creation and external API integration
- `resource_manager.ex` - Resource lifecycle management
- `messages/` - PubSub and event messaging
- `event_logs.ex` - Event sourcing and game history

## Event Sourcing and Snapshot Architecture

The `event_logs.ex` module implements an event sourcing pattern with snapshots for game state history and time travel capabilities.

### Event Log Structure

Each event log entry contains:
- **Event data**: Key, payload, timestamp, game clock time/period
- **Snapshot**: Complete GameState at that point in time
- **Ordering**: Events are ordered chronologically by game clock (not insertion time)

```elixir
%EventLog{
  id: "uuid",
  game_id: "game-uuid",
  key: "update-player-stat",
  payload: %{"operation" => "increment", "stat-id" => "field_goals_made"},
  game_clock_time: 570,  # Chronological ordering
  game_clock_period: 1,
  timestamp: ~U[2024-01-01 12:00:00Z],  # Insertion time
  snapshot: %GameSnapshot{state: %GameState{...}}  # Full game state
}
```

### Two-Tier Snapshot Management Strategy

The system uses a two-tier architecture optimized for different use cases:

#### Tier 1: Fast Real-Time Path (`persist/4`)

```elixir
# Hot path for live scoring - optimized for speed
EventLogs.persist(event, game_state)
```

**Characteristics:**
- **O(1) performance** - No snapshot updates
- Used during live games for real-time scoring
- Creates snapshots based on prior event only
- May create **temporary stale snapshots** with out-of-order operations
- Trade-off: Speed over complete consistency

**Why Out-of-Order Persists Happen:**
- Multiple scorekeepers working simultaneously
- Network delays causing events to arrive out of sequence
- Corrections being made during live play
- Example: Event at 8:30 (510s) persisted after event at 8:00 (480s)

#### Tier 2: Correctness Path (`add/3`, `delete/3`, `update_payload/4`)

```elixir
# Mutation operations - optimized for correctness
EventLogs.add(event_log)
EventLogs.delete(event_id)
EventLogs.update_payload(event_id, new_payload)
```

**Characteristics:**
- **O(n) performance** - Rebuilds ALL snapshots
- Used for corrections and administrative changes
- Guarantees complete consistency
- Calls `rebuild_all_snapshots/1` internally
- Trade-off: Completeness over speed (~1-3 seconds for 300 events)

### The `rebuild_all_snapshots/1` Function

Critical function that ensures snapshot consistency after mutations:

```elixir
@spec rebuild_all_snapshots(Ecto.UUID.t()) :: :ok | {:error, any()}
def rebuild_all_snapshots(game_id) do
  # 1. Get first event (immutable base)
  first_event = get_first_created_by_game_id(game_id)
  
  # 2. Load all events in chronological order
  all_events = get_all_by_game_id(game_id, with_snapshot: true)
  
  # 3. Rebuild each snapshot from scratch
  Repo.transaction(fn ->
    all_events
    |> Enum.drop(1)  # Skip first (never changes)
    |> Enum.reduce(first_event.snapshot.state, fn event, prior_state ->
      # Apply event to prior state
      updated_state = apply_to_game_state(event, prior_state)
      
      # Update snapshot in database
      event.snapshot
      |> GameSnapshot.changeset(%{state: json_encode(updated_state)})
      |> Repo.update!()
      
      updated_state  # Becomes prior_state for next event
    end)
  end)
end
```

**When It Runs:**
- After `add()` - ensures new event and all existing snapshots are consistent
- After `delete()` - recalculates all snapshots after event removal
- After `update_payload()` - propagates changes through all subsequent events
- **Never during `persist()`** - keeps live scoring fast

### Handling Out-of-Order Events

**Scenario that demonstrates the problem:**

```
Timeline:  600s    590s    570s    510s    480s    450s
           start   e1      e2      e4      e3      e5
           
Operations in insertion order:
1. persist start (600s)
2. persist e1 (590s) - uses start snapshot ✓
3. persist e2 (570s) - uses e1 snapshot ✓
4. add e3 (480s) - uses e2 snapshot, rebuilds all ✓
5. persist e4 (510s) - uses e2 snapshot (goes between e2 and e3)
   → e3's snapshot now STALE (missing e4's contribution) ✗
6. delete e5 (450s) - rebuilds all ✓

Result: Final snapshot at e3 is correct after rebuild
```

**Solution:**
- `persist()` accepts temporary staleness for speed
- Any mutation (`add/delete/update_payload`) rebuilds everything
- Final state is always consistent after corrections

### Event Application with Special Behaviors

Some events have special handling during snapshot rebuilds:

```elixir
def apply_to_game_state(event_log, game_state) do
  case event.meta.logs_reduce_behavior do
    :copy_all_stats_from_game_state ->
      # For AddPlayerToTeam, AddCoachToTeam
      # Preserves structure from snapshot (including generated IDs)
      # Copies stats from prior state
      Sports.copy_all_stats_from_game_state(
        game_state.sport_id,
        game_state,
        event_log.snapshot.state  # Preserves original IDs
      )
    
    :handle ->
      # Standard event handling
      Handler.handle(game_state, event)
  end
end
```

**Why This Matters:**
- Events like `AddPlayerToTeam` generate random UUIDs
- During rebuild, we need to preserve the original IDs
- Can't replay the event (would generate different IDs)
- Solution: Use snapshot's structure, copy stats from prior state

### Performance Characteristics

| Operation | Complexity | Typical Time | Use Case |
|-----------|-----------|--------------|----------|
| `persist/4` | O(1) | <10ms | Live scoring |
| `add/3` | O(n) | 1-3s for 300 events | Add missed event |
| `delete/3` | O(n) | 1-3s for 300 events | Remove incorrect event |
| `update_payload/4` | O(n) | 1-3s for 300 events | Fix event data |

### Design Trade-offs

**Accepted Trade-offs:**

1. **Temporary Inconsistency**: Between persist operations, some snapshots may be stale
   - **Why acceptable**: Live scoring must be fast; corrections rebuild everything
   
2. **O(n) Rebuilds**: Mutations are more expensive than incremental updates
   - **Why acceptable**: Corrections are rare vs. persist operations; guarantees correctness

3. **Memory Usage**: Each event stores complete GameState snapshot
   - **Why acceptable**: Enables instant time travel; storage is cheap vs. recomputation

**Benefits Gained:**

1. **Fast Live Scoring**: persist() stays O(1) regardless of game length
2. **Complete Consistency**: Any correction guarantees all snapshots are correct
3. **Simple Mental Model**: Either fast (persist) or correct (mutations), not both
4. **Time Travel**: Jump to any point in game history instantly

## Data Flow Example

```
1. HTTP Request → LiveView Controller
2. Controller calls Games.find_or_bootstrap(game_id)
3. Games module checks GameStateCache.get(game_id)
4. If cache hit: GameState.from_json(redis_data) → Poison.decode!
5. Business logic modules (Teams, Players, etc.) manipulate GameState
6. GameStateCache.update(modified_game_state) → Poison.encode! → Redis SET
7. PubSub broadcasts changes to connected clients
```

## Key Benefits of This Architecture

1. **Clear Separation**: Models are pure data, logic modules contain behavior
2. **Redis Compatibility**: All models are serializable/deserializable via Poison
3. **Type Safety**: Strong typing with Elixir specs throughout
4. **Testability**: Business logic is separated from data structures
5. **Scalability**: Redis provides fast access to game state across nodes
6. **Event Sourcing Ready**: Structure supports event-driven architecture

## Best Practices

### When Adding New Models

1. **Always** implement Poison encoding/decoding:
   ```elixir
   @derive [Poison.Encoder]
   
   defimpl Poison.Decoder, for: YourModule do
     def decode(value, options), do: # custom logic
   end
   ```

2. **Create corresponding plural module** for business logic

3. **Add to GameState** if it's part of the root aggregate

4. **Update GameState.from_json** with proper nesting structure

### When Adding Business Logic

1. **Use plural modules** (Players, Teams, etc.) for entity-specific logic
2. **Operate on GameState** for cross-cutting concerns
3. **Validate inputs** before state mutations
4. **Return new state** (immutable updates)

This architecture ensures that the game state management is robust, type-safe, and efficiently cacheable while maintaining clear boundaries between data and business logic.