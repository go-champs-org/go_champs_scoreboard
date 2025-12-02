# Event Definitions

This directory contains the event definitions that power the Go Champs Scoreboard event-driven architecture. Each event definition represents a specific action that can occur during a sports game and defines how the game state should be transformed in response to that event.

## Core Concepts

### Event-Driven Architecture

The scoreboard operates on an event-driven architecture where all game state changes are represented as discrete events. This approach provides several benefits:

- **Auditability**: Every change to the game state is recorded as an event
- **Reproducibility**: Game states can be reconstructed by replaying events
- **Consistency**: All state changes follow the same pattern
- **Testability**: Each event can be tested in isolation

### Pure Functions and Immutability

Event definitions follow functional programming principles:

#### `handle/2` Must Always Return a New GameState

The `handle/2` function is the core of each event definition and must:

- **Return a new `GameState`**: Never mutate the input game state
- **Be deterministic**: Same input always produces the same output
- **Be atomic**: Complete transformation in a single operation
- **Be pure**: No side effects (no database calls, no external API calls, no logging)

```elixir
# ✅ Good - Returns new state
def handle(current_game, event) do
  current_game
  |> Games.update_team(team_type, updated_team)
end

# ❌ Bad - Mutates input or has side effects
def handle(current_game, event) do
  Logger.info("Processing event")  # Side effect
  current_game.home_team.score = 10  # Mutation
  current_game  # Returns modified input
end
```

#### Atomic Operations

Each event should represent a single, atomic change to the game state:

- **Single Responsibility**: One event = one type of change
- **Complete Transformation**: All related updates happen in one event
- **No Partial States**: Never leave the game in an inconsistent state

### Testability

The pure, functional nature of event definitions makes them highly testable:

- **Predictable Inputs/Outputs**: Easy to create test fixtures
- **No External Dependencies**: No mocking required
- **Fast Execution**: No I/O operations slow down tests
- **Isolated Testing**: Each event can be tested independently

## Event Definition Structure

Every event definition must implement the `DefinitionBehavior` and provide five functions:

### Required Functions

```elixir
@behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior

@impl true
@spec key() :: String.t()
def key, do: @key

@impl true  
@spec validate(GameState.t(), any()) :: {:ok} | {:error, any()}
def validate(_game_state, _payload), do: {:ok}

@impl true
@spec create(String.t(), integer(), integer(), any()) :: Event.t()
def create(game_id, clock_state_time_at, clock_state_period_at, payload),
  do: Event.new(@key, game_id, clock_state_time_at, clock_state_period_at, payload)

@impl true
@spec handle(GameState.t(), Event.t()) :: GameState.t()
def handle(current_game, event) do
  # Pure transformation logic here
  current_game
end

@impl true
@spec stream_config() :: StreamConfig.t()  
def stream_config, do: StreamConfig.new()
```

### Function Responsibilities

- **`key/0`**: Returns unique string identifier for the event type
- **`validate/2`**: Validates if the event can be applied to the current game state
- **`create/4`**: Factory function to create a new event with given parameters
- **`handle/2`**: Pure function that transforms game state based on the event
- **`stream_config/0`**: Configuration for event streaming (usually default)

## Creating a New Event Definition

### Step 1: Define the Module

```elixir
defmodule GoChampsScoreboard.Events.Definitions.MyNewEventDefinition do
  @behaviour GoChampsScoreboard.Events.Definitions.DefinitionBehavior
  
  # Import required modules
  alias GoChampsScoreboard.Events.Models.Event
  alias GoChampsScoreboard.Games.Models.GameState
  # ... other aliases
  
  @key "my-new-event"
end
```

### Step 2: Implement Required Functions

Focus on the `handle/2` function - this is where the game state transformation logic lives:

```elixir
@impl true
@spec handle(GameState.t(), Event.t()) :: GameState.t()
def handle(current_game, %Event{payload: payload}) do
  # Extract data from payload
  %{"some_field" => value} = payload
  
  # Transform the game state
  current_game
  |> update_something(value)
  |> calculate_derived_stats()
end
```

### Step 3: Register the Event

Add your new event to the registry in `registry.ex`:

```elixir
alias GoChampsScoreboard.Events.Definitions.MyNewEventDefinition

@registry %{
  # ... existing events
  MyNewEventDefinition.key() => MyNewEventDefinition
}
```

### Step 4: Write Tests

Create comprehensive tests in `test/go_champs_scoreboard/events/definitions/`:

```elixir
defmodule GoChampsScoreboard.Events.Definitions.MyNewEventDefinitionTest do
  use ExUnit.Case
  alias GoChampsScoreboard.Events.Definitions.MyNewEventDefinition
  
  describe "handle/2" do
    test "transforms game state correctly" do
      initial_state = build_game_state()
      event = MyNewEventDefinition.create("game-id", 10, 1, %{"field" => "value"})
      
      result = MyNewEventDefinition.handle(initial_state, event)
      
      assert result.some_field == expected_value
      assert result != initial_state  # Verify immutability
    end
  end
end
```

## Common Patterns

### Updating Team Stats

```elixir
def handle(current_game, %Event{payload: %{"team-type" => team_type}}) do
  updated_team =
    current_game
    |> Teams.find_team(team_type)
    |> Teams.update_stats(...)
    |> Teams.calculate_totals()
    |> Teams.update_calculated_stats_values(calculated_stats)
    |> Teams.calculate_period_stats(period)
    
  current_game
  |> Games.update_team(team_type, updated_team)
end
```

### Updating Player Stats

```elixir
def handle(current_game, event) do
  updated_player =
    current_game
    |> Teams.find_player(team_type, player_id)
    |> Players.update_stats(...)
    |> Players.update_calculated_stats_values(calculated_stats)
    
  updated_team =
    current_game
    |> Teams.find_team(team_type)
    |> Teams.update_player_in_team(updated_player)
    |> Teams.calculate_team_total_player_stats()
    |> Teams.update_calculated_stats_values(calculated_team_stats)
    |> Teams.calculate_period_stats(period)
    
  current_game
  |> Games.update_team(team_type, updated_team)
end
```

## Best Practices

### Do's

- ✅ Keep `handle/2` functions pure and side-effect free
- ✅ Always return a new `GameState` instance
- ✅ Use pipelines for clear transformation steps
- ✅ Extract reusable logic into helper modules
- ✅ Write comprehensive tests for all scenarios
- ✅ Use pattern matching for clear payload extraction
- ✅ Calculate derived stats after updates

### Don'ts

- ❌ Never mutate the input game state
- ❌ Don't add side effects in `handle/2` (logging, database calls, etc.)
- ❌ Don't make `handle/2` dependent on external state
- ❌ Don't skip validation in production events
- ❌ Don't forget to update calculated stats
- ❌ Don't leave the game state in an inconsistent state

## Testing Guidelines

### Test Structure

Each event definition should have tests covering:

1. **Happy Path**: Normal operation scenarios
2. **Edge Cases**: Boundary conditions and unusual inputs  
3. **State Validation**: Verify the returned state is correct
4. **Immutability**: Ensure input state is never modified
5. **Calculated Stats**: Verify derived values are updated

### Test Data

Use consistent test fixtures that represent realistic game states:

```elixir
@initial_state %GameState{
  home_team: %{
    players: [...],
    total_player_stats: %{},
    total_coach_stats: %{},
    stats_values: %{...},
    period_stats: %{}
  },
  away_team: %{...},
  sport_id: "sport_type"
}
```

## Event Types by Category

### Game Control
- `StartGameDefinition` - Initialize game
- `EndGameDefinition` - Finalize game  
- `EndPeriodDefinition` - End current period
- `UpdateClockStateDefinition` - Change clock state

### Player Management
- `AddPlayerToTeamDefinition` - Add player to team
- `RemovePlayerInTeamDefinition` - Remove player
- `UpdatePlayerStatDefinition` - Update player statistics
- `SubstitutePlayerDefinition` - Player substitutions

### Team Management
- `UpdateTeamStatDefinition` - Update team statistics
- `AddCoachToTeamDefinition` - Add coach to team
- `UpdateCoachStatDefinition` - Update coach statistics

### Game Administration
- `AddOfficialToGameDefinition` - Add game official
- `ProtestGameDefinition` - Record game protest
- `UpdateGameInfoDefinition` - Update game metadata

This event-driven architecture provides a robust, testable, and maintainable foundation for managing sports game state changes while ensuring data consistency and auditability.