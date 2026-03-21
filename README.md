# Pomodoro for macOS

Minimal native Pomodoro timer for macOS built with SwiftUI.

## What is included

- Full source code
- Xcode project
- Packaging script for local DMG builds
- GitHub Release download for the distributable `.dmg`

## Requirements

- macOS 14 or later
- Xcode 16 or later for local builds

## Build locally

```bash
xcodebuild -project /absolute/path/to/Pomodoro.xcodeproj -scheme Pomodoro -configuration Release build
```

Or run:

```bash
/absolute/path/to/scripts/build_and_package.sh
```

## Download

Use the latest GitHub Release to download `Pomodoro.dmg`.

Current release artifact checksum:

```text
SHA-256: 7aedb57c57da7f91befad61021ebdd14bd25411982d79daa74bb93753250d3b5
```

## Security notes

- This repository intentionally excludes local build caches and Xcode user data.
- No API keys or secret configuration are required for building this app.
