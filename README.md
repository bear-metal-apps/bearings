# Bearings

Bearings is the Bear Metal monorepo for the 2046 app stack. It brings the shared Dart and Flutter packages, both client apps, and the backend into one workspace so dependencies, code generation, validation, and release automation can be run from a single root.

## Workspace layout

- `apps/beariscope`: strategy and viewing app
- `apps/pawfinder`: scouting app
- `packages/core`: shared Dart models and utilities
- `packages/services`: shared Flutter services and providers
- `packages/ui`: shared Flutter UI components
- `backend/honeycomb`: Dart Frog backend

## Getting started

1. Install Flutter stable and ensure `dart`, `flutter`, and `melos` are on your `PATH`.
2. From the repo root, run `dart pub get`.
3. Use Melos scripts from the root for day-to-day tasks.

## Common commands

- `melos run bootstrap`: resolve the full workspace
- `melos run format`: apply formatting
- `melos run format:check`: check formatting without writing changes
- `melos run analyze`: analyze all packages
- `melos run generate`: run `build_runner` where needed
- `melos run test`: run Dart and Flutter tests
- `melos run ci`: run the full validation sequence used by CI

## Release workflow

Bearings now uses a single workspace version for both apps, all shared packages, and the Honeycomb backend. The release workflow is driven from the repo root and updates every workspace `pubspec.yaml`, the shared codename file at `packages/services/assets/release/codename.txt`, and the root `CHANGELOG.md`.

Release automation lives in `.github/workflows/release.yml`. It creates one GitHub release per version, tags it as `vX.Y.Z`, publishes a unified changelog, and attaches these build artifacts:

- Beariscope: Android, Linux, Web, and Windows
- Pawfinder: Android only

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

## Working on apps

Run app-specific commands from the app directory when you need platform builds:

- `cd apps/beariscope && flutter run`
- `cd apps/pawfinder && flutter run`

Use the root workspace for dependency resolution, analysis, tests, and code generation.
