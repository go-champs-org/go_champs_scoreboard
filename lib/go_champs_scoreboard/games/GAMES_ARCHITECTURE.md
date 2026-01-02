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