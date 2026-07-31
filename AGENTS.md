# Agent Instructions

All commands must run **inside the devcontainer**. Never run commands on the local host.

## Running Commands in the Container

If already inside the devcontainer (e.g., VS Code Dev Containers):

```bash
<command>
```

If running from outside, prefix with:

```bash
docker compose -f .devcontainer/docker-compose.yml exec app <command>
```

---

## Start the App

```bash
mix phx.server
```

App runs on port 4000.

## Setup (first time or after clean)

```bash
mix setup
```

This runs `deps.get`, creates and migrates the database, and builds assets.

## Elixir Tests

```bash
mix test
```

Automatically creates and migrates the test database before running.

## JavaScript Tests

```bash
npm test
```

For watch mode:

```bash
npm run test:watch
```

For coverage:

```bash
npm run test:coverage
```

## Linting

**Elixir:**

```bash
mix format --check-formatted
```

**JavaScript/TypeScript (Prettier):**

```bash
npm run format-check
```

To auto-fix formatting:

```bash
npm run format
```

## Database

Reset:

```bash
mix ecto.reset
```

Migrate only:

```bash
mix ecto.migrate
```
