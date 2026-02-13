# MindClash

A local pass-and-play mobile trivia game where players compete head-to-head answering questions across categories. Fast-paced knowledge duels — players take turns, earn points, and the game tracks performance.

## Tech Stack

- **Framework:** Flutter (Android + iOS)
- **State Management:** Riverpod 3.x with code generation
- **Architecture:** Clean Architecture (feature-first)
- **Immutability:** Freezed
- **Serialization:** json_serializable
- **Linting:** very_good_analysis
- **Testing:** mocktail

See [docs/decisions.md](docs/decisions.md) for rationale behind each choice.

## Commands

```bash
# Run the app
flutter run

# Run all tests
flutter test

# Code generation
dart run build_runner build --delete-conflicting-outputs

# Code generation (watch mode)
dart run build_runner watch --delete-conflicting-outputs

# Lint
flutter analyze

# Format
dart format .

# Clean rebuild
flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs
```

## Architecture

```
Presentation  →  Domain  ←  Data
(Widgets,        (Entities,     (Repos impl,
 Providers)       UseCases,      DataSources,
                  Repo ifaces)   Models/DTOs)
```

Dependencies point inward — domain has zero external dependencies.

See [CLAUDE.md](CLAUDE.md) for layer rules and conventions.
