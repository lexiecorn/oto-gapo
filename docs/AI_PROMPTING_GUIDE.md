## AI Prompting Guide (OtoGapo)

Write prompts that are specific, scoped, and reference files. Prefer actionable diffs over abstract advice.

### Core Prompt Structure

1. Goal: What you want (feature/bugfix/refactor)
2. Context: Files, routes, blocs, data models involved
3. Constraints: Lints, patterns, performance, UX
4. Acceptance Criteria: What success looks like
5. Actions: Ask for specific edits and tests

### Examples

#### Add a new page and route

```
Goal: Add Settings page with theme toggle
Context: Theme via `ThemeProvider`; routes in `lib/app/routes/app_router.dart`
Constraints: Use `@RoutePage`; update docs if public API changes
Acceptance: New `SettingsPage`, route added, navigation from profile menu
Action: Provide edits for page, route, and tests
```

#### Implement Cubit + Repository method

```
Goal: Load recent announcements
Context: Announcements in PocketBase; repo layer in `services/`
Constraints: Keep IO in repository; pure Cubit; follow VGA lints
Acceptance: Cubit loads list with loading/error states; widget test
Action: Provide edits for repo, cubit, and page wiring
```

### Do/Don't

- Do: cite files and functions; ask for diffs; request tests
- Do: include performance/security concerns where relevant
- Don't: request sweeping refactors without scope and impact
- Don't: omit routing/state updates when adding screens

### Handy References

- Routing: `.cursor/rules/02-routing-auto-route.mdc`
- State mgmt: `.cursor/rules/04-state-management.mdc`
- Dart style: `.cursor/rules/06-dart-style.mdc`
- Workspace cmds: `.cursor/rules/07-workspace-conventions.mdc`
