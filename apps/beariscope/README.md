# Beariscope

Beariscope is Bear Metal's FRC strategy app.

## Features

- **Team Lookup** - view any team's scouting data across averages, hardware capabilities, match-by-match breakdowns, and written notes
- **Match previews** - swipe through all 6 robots in an upcoming match
- **Up Next** - a full event schedule with current and past matches
- **Pits scouting** - fill out pit forms directly in the app, with both a list view and an interactive pit map pulled from Nexus
- **Cloud sync** - all scouting data lives in the cloud
- **Role-based access** - different permissions for scouts, strategists, and drive team
- **Mobile, desktop, and web!** - works on iOS, Android, your laptop, and as a web app in a pinch

## Working on Beariscope

From the monorepo root:

1. Run `dart pub get`
2. Run `melos run generate` if codegen needs refreshing
3. Start the app with `cd apps/beariscope && flutter run` or by using Melos's IntelliJ run configs
