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

Conventional commits are a standardized way to write commit messages. They look like this:  
```
<type>(<scope>): <description>
```

Notice how everything is lowercase, the type and scope are separated by parentheses, and the description is separated from the type/scope by a colon and space.

- `feat`
- `fix`
- `perf`
- `refactor`
- `docs`
- `build`
- `ci`
- `test`
- `chore`

You can also signify a breaking change by adding an `!` after the type like this:  
`refactor!(services): refactor honeycomb api provider`

A scope is where the commit edits things. CI enforces scoped commits for pull requests. Use one of these scopes:  
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

Examples of good commits:

- `feat(beariscope): add pit map refresh`
- `fix(services): retry secure storage read`
- `chore(ci): add commitlint to pull requests`