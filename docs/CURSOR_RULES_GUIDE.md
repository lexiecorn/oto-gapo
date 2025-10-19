# Cursor Rules Guide

This document explains the Cursor AI rules configured for the OtoGapo project.

## Overview

Cursor rules help maintain consistency and guide development by providing context-aware information to the AI assistant. Rules are located in `.cursor/rules/` and use the `.mdc` format.

## Available Rules

### Always Applied Rules

These rules are automatically applied to every AI interaction:

#### 1. Project Structure (`01-project-structure.mdc`)

- **Purpose**: Quick navigation map of the app structure
- **Contains**: Entry points, routing, state management, theming, DI, Firebase setup
- **Use when**: Exploring the codebase, understanding architecture

#### 2. Git Operation Policy (`08-git-approval.mdc`)

- **Purpose**: Require explicit approval for git operations
- **Contains**: Git operation restrictions, approval requirements
- **Use when**: Performing commits, pushes, or other git operations

#### 3. Documentation Update Policy (`09-documentation-updates.mdc`)

- **Purpose**: Ensure documentation stays up-to-date
- **Contains**: When to update docs, documentation locations, workflow
- **Use when**: Making any code changes that affect public APIs or features

### Requestable Rules

These rules can be requested when needed using the `@Rules` command:

#### 4. Routing & Auto Route (`02-routing-auto-route.mdc`)

- **Purpose**: Auto route configuration and generation
- **Use when**: Adding new routes, modifying navigation
- **Key topics**: Route definitions, guards, navigation

#### 5. Flavors & Firebase (`03-flavors-and-firebase.mdc`)

- **Purpose**: Flavor setup and Firebase initialization
- **Use when**: Configuring environments, Firebase setup
- **Key topics**: Development/staging/production flavors

#### 6. State Management (`04-state-management.mdc`)

- **Purpose**: BLoC, Cubit, and Provider patterns
- **Use when**: Implementing state management, creating cubits
- **Key topics**: BLoC pattern, dependency injection

#### 7. Assets & ScreenUtil (`05-assets-and-screenutil.mdc`)

- **Purpose**: Asset loading and responsive design conventions
- **Use when**: Adding assets, implementing responsive UI
- **Key topics**: ScreenUtil usage, asset organization

#### 8. Dart Style (`06-dart-style.mdc`)

- **Purpose**: Dart style, naming, and lint rules
- **Use when**: Writing Dart code, fixing lints
- **Key topics**: Code style, naming conventions

#### 9. Workspace Conventions (`07-workspace-conventions.mdc`)

- **Purpose**: Common workspace commands and generation steps
- **Use when**: Running builds, generating code
- **Key topics**: Code generation, build commands

#### 10. Testing (`10-testing.mdc`)

- **Purpose**: Testing rules for widgets, Cubits, integration tests
- **Use when**: Writing tests, setting up test infrastructure
- **Key topics**: Unit tests, widget tests, integration tests

#### 11. Documentation Reference (`11-documentation-reference.mdc`)

- **Purpose**: Quick reference to all project documentation
- **Use when**: Looking for specific documentation, implementing features
- **Key topics**: Documentation organization, feature-specific docs

## How to Use Rules

### In Cursor Chat

1. **Request a specific rule**: Type `@Rules routing` to load routing conventions
2. **Multiple rules**: Type `@Rules state-management testing` for multiple rules
3. **Auto-applied**: Rules marked `alwaysApply: true` are always active

### When to Use Which Rule

| Task                  | Recommended Rules                                                 |
| --------------------- | ----------------------------------------------------------------- |
| Adding new feature    | `02-routing`, `04-state-management`, `11-documentation-reference` |
| Implementing UI       | `05-assets-and-screenutil`, `06-dart-style`                       |
| Setting up deployment | `03-flavors-and-firebase`, `11-documentation-reference`           |
| Writing tests         | `10-testing`                                                      |
| Debugging             | `11-documentation-reference`                                      |
| Fixing lints          | `06-dart-style`                                                   |
| Adding documentation  | `09-documentation-updates`                                        |

## Rule Structure

Each rule file follows this format:

```markdown
---
alwaysApply: true|false
description: Brief description
---

## Rule Title

Content explaining conventions, patterns, or guidelines...
```

## Documentation Integration

The documentation reference rule (`11-documentation-reference.mdc`) provides quick links to:

- **Architecture docs**: `docs/ARCHITECTURE.md`, `docs/API_DOCUMENTATION.md`
- **Feature docs**: Attendance, Payment, Authentication systems
- **Deployment**: Docker, Web, Play Store guides
- **Backend**: PocketBase schemas and setup
- **Packages**: Local package documentation

## Creating New Rules

When adding new rules:

1. Create `.mdc` file in `.cursor/rules/`
2. Use numbered prefix for ordering (e.g., `12-new-rule.mdc`)
3. Include `alwaysApply` and `description` in frontmatter
4. Document in this guide
5. Update `11-documentation-reference.mdc` if needed

### Rule Best Practices

- **Specific**: Focus on one topic per rule
- **Concise**: Keep rules brief and scannable
- **Examples**: Include code examples when helpful
- **Cross-reference**: Link to detailed documentation
- **Maintain**: Update rules when code changes

## Integration with Documentation

The rules system complements the documentation structure:

```
Rules (Quick reference)
  ↓
Documentation (Detailed guides)
  ↓
Code (Implementation)
```

**Example workflow:**

1. Use `11-documentation-reference.mdc` to find relevant docs
2. Use feature-specific rule (e.g., `04-state-management.mdc`) for conventions
3. Reference detailed docs (`docs/ARCHITECTURE.md`) for implementation details
4. Follow `09-documentation-updates.mdc` to update docs after changes

## Maintenance

### Updating Rules

When code patterns change:

1. Update the relevant `.mdc` file
2. Test with Cursor AI to ensure clarity
3. Update this guide if rule purpose changes
4. Document in `CHANGELOG.md` if significant

### Review Schedule

- **Monthly**: Review always-applied rules for accuracy
- **Per Feature**: Update feature-specific rules when implementing new features
- **Per Release**: Verify all rules match current codebase

## See Also

- [Documentation Reference](./.cursor/rules/11-documentation-reference.mdc) - All project docs
- [Project Organization](./PROJECT_ORGANIZATION.md) - File structure
- [Developer Guide](./DEVELOPER_GUIDE.md) - Development workflows
- [Documentation Status](./DOCUMENTATION_STATUS.md) - Completeness tracking

## Quick Reference

### Always Active

- Project structure map
- Git approval requirements
- Documentation update policy

### Request as Needed

- Routing conventions
- Flavor/Firebase setup
- State management patterns
- Asset handling
- Dart style guide
- Workspace commands
- Testing guidelines
- **Documentation reference** ⭐ (Use this often!)

---

**Tip**: Start with `@Rules documentation-reference` when working on any feature to find relevant documentation and conventions!
