# Bearings

Bearings is Bear Metal's monorepo for our apps. We use a monorepo with everything in dart to share code and make it easier for less experienced members to contribute. 

## Repo layout

- `apps/beariscope`: strategy app
- `apps/pawfinder`: scouting app
- `packages/core`: shared pure dart models and utilities
- `packages/services`: shared flutter services and providers
- `packages/ui`: shared flutter UI components
- `backend/honeycomb`: Dart Frog backend (wip)

## Getting started

1. Install the latest version of flutter (run `flutter upgrade` if you need to update) and Melos and make sure `dart`, `flutter`, and `melos` are in your `PATH`.
2. From the repo root, run `melos bootstrap`.
3. Use Melos scripts from the root for day-to-day tasks.

## Melos commands

- `melos run format`: apply formatting
- `melos run format:check`: check formatting without writing changes
- `melos run analyze`: analyze all packages
- `melos run generate`: run `build_runner` where needed
- `melos run test`: run Dart and Flutter tests
- `melos run ci`: run the full validation sequence used by CI

## Conventional commits

CI enforces scoped conventional commits for pull requests. Use one of these scopes:

- `beariscope`
- `pawfinder`
- `core`
- `services`
- `ui`
- `honeycomb`
- `repo`
- `workspace`
- `ci`
- `release`
- `deps`
- `docs`

Examples:

- `feat(beariscope): add pit map refresh`
- `fix(services): retry secure storage read`
- `chore(ci): add commitlint to pull requests`