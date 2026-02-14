# MindClash

Mobile party/trivia game — Flutter, Clean Architecture, Riverpod. Phase 1: local single-device pass-and-play.

> For project overview and setup, see [README.md](README.md).

## Architecture Rules

**Dependencies point inward only:**
- Presentation → Domain (allowed)
- Data → Domain (allowed)
- Domain → Presentation/Data (FORBIDDEN)
- Presentation → Data (FORBIDDEN — go through domain)

**Layer responsibilities:**

| Layer | Can Import | Cannot Import | Contains |
|-------|-----------|---------------|----------|
| Presentation | domain, core/theme, Flutter | data layer | Widgets, Providers — no business logic |
| Domain | only other domain classes | Flutter, packages, data, presentation | Entities, UseCases, Repository interfaces — pure Dart |
| Data | domain layer | presentation, Flutter UI | Repository impls, DataSources, Models/DTOs |

## Directory Structure

Feature-first. Each feature owns presentation/domain/data layers.

```
lib/
├── app/                        # MaterialApp, router, theme, app-wide providers
├── core/                       # constants, errors, extensions, theme, utils
├── features/
│   └── <feature>/
│       ├── presentation/       # screens/, widgets/, providers/
│       ├── domain/             # entities/, repositories/, usecases/
│       └── data/               # repositories/, datasources/, models/
└── main.dart

test/                           # Mirrors lib/ structure with _test.dart suffix
assets/questions/<locale>/      # Local JSON question files per locale (Phase 1)
```

## Naming Conventions

**Files:** `snake_case.dart` with type suffix — `_screen`, `_widget`, `_provider`, `_repository`, `_datasource`, `_model`, `_usecase`
**Classes:** `PascalCase` with type suffix — `GameScreen`, `GameNotifier`, `GameRepository`. Entities have no suffix (`Player`, `Question`).
**Generated:** `*.g.dart` (riverpod, json_serializable), `*.freezed.dart` (freezed)
**Tests:** mirror source path — `lib/.../foo.dart` → `test/.../foo_test.dart`

## Riverpod Rules

- Always use `@riverpod` code generation — never hand-write providers
- One provider per file
- `ref.watch` in widgets, `ref.read` only in callbacks
- Use `select()` to minimize rebuilds
- Use `ref.onDispose()` for cleanup
- Test with `ProviderContainer` + overrides (no widget tree needed)

## Game Engine

Pure Dart state machine in the domain layer. `newState = engine.process(currentState, action)` — no side effects, no mutations, deterministic.

- **GameState:** freezed union — `initial | playing | paused | roundEnd | finished`
- **GameAction:** freezed union — `startGame | answerQuestion | skipQuestion | nextRound | endGame`

## Theme Rules

- No raw hex colors — use `AppColors.*`
- No raw padding values — use `AppSpacing.*`
- No inline TextStyles — use `AppTypography.*` or `Theme.of(context).textTheme`

## Performance

- `const` constructors wherever possible
- `select()` over watching entire state
- Extract small widgets — no mega `build()` methods
- `Consumer` to scope rebuilds to smallest subtree
- No `setState` — Riverpod for all state

## Testing Priority

1. **Domain** (highest) — GameEngine, UseCases. Pure Dart, test every state transition.
2. **Data** — repository impls, JSON parsing, error handling.
3. **Providers** — state transitions via `ProviderContainer`.
4. **Widgets** (lowest) — interaction tests only, don't over-test layout.

Use mocktail for mocks. Arrange/Act/Assert pattern.

## Git Rules

- **Always ask before staging, committing, or pushing**
- Conventional commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`
- Atomic commits — one logical change each
- Solo dev: commit to `main` directly. Branch only for risky experiments.

## Questions Schema (Phase 1)

Local JSON in `assets/questions/<locale>/<category>.json` (e.g. `en/science.json`, `ar/science.json`):
- `id`: unique, category-prefixed (`sci_001`) — same IDs across locales
- `text`: plain text question
- `options`: exactly 4 strings
- `correctIndex`: 0-based
- `difficulty`: free-form string (e.g. `"easy"`, `"hard"`, `"nightmare"`)
- `score` *(optional)*: explicit point value. When omitted, defaults by label: `easy`=200, `medium`=400, `hard`=600, anything else=400

**Locale threading:** `locale` is a required parameter on `QuestionDataSource.getQuestions()` and `QuestionRepository.getQuestions()`. Adding a language = adding a folder with JSON files, zero model/code-gen changes.
