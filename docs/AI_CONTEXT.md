## AI Context: OtoGapo Project

This file gives AI assistants the minimum context needed to be effective without re-reading the whole repo.

### App Overview
- Flutter app with flavors: `lib/main_development.dart`, `lib/main_staging.dart`, `lib/main_production.dart`
- App bootstraps in `lib/bootstrap.dart` (DI: `get_it` for `AppRouter`, `Dio`)
- Routing via `auto_route` in `lib/app/routes/app_router.dart` (+ generated `app_router.gr.dart`)
- State management: BLoC + Cubit in `lib/app/modules/**`
- Theming via `ThemeProvider` using `packages/otogapo_core`
- Backend: Firebase + PocketBase

### Key Conventions
- Run code generation: `dart run build_runner build --delete-conflicting-outputs`
- Use `@RoutePage` for pages and define routes in `app_router.dart`
- Keep business logic inside blocs/cubits; IO in repositories
- Follow `very_good_analysis` lint rules (see `.cursor/rules/06-dart-style.mdc`)
- Use `ScreenUtil` for responsive sizes

### Where Things Live
- Entry points: `lib/main_*.dart`
- App shell: `lib/app/view/app.dart`
- Routing: `lib/app/routes/app_router.dart`
- Feature blocs/cubits: `lib/app/modules/<feature>/bloc/`
- Pages: `lib/app/pages/`
- Reusable widgets: `lib/app/widgets/`
- Repos/services: `lib/services/`, `packages/*`

### Flavors & Config
- Access flavor variables via `FlavorConfig.instance.variables['key']`
- Example: PocketBase URL per flavor in `lib/main_*.dart`

### Testing
- `flutter test` with coverage; see `test/` and `docs/DEVELOPER_GUIDE.md`

### Documentation & Rules
- Docs index: `docs/PROJECT_ORGANIZATION.md` and `docs/README.md`
- Cursor rules: `.cursor/rules/` (request with `@Rules <topic>`)
  - Useful: `04-state-management.mdc`, `02-routing-auto-route.mdc`, `10-testing.mdc`

### AI Collaboration Tips
- Provide: feature goal, affected areas, acceptance criteria, user flows
- Ask AI to: propose diff-sized edits tied to files, update docs when APIs change
- Keep templates in `templates/` aligned with lints and patterns

### High-Signal Links
- Architecture: `docs/ARCHITECTURE.md`
- API: `docs/API_DOCUMENTATION.md`
- Deployment: `docs/DEPLOYMENT.md`
- Rules overview: `docs/CURSOR_RULES_GUIDE.md`


