#!/usr/bin/env bash
set -euo pipefail

# Auto-fix common Dart issues and enforce formatting/lints
echo "==> Ensuring dependencies"
flutter pub get

echo "==> Applying dart fixes"
dart fix --apply

echo "==> Formatting code"
dart format .

echo "==> Running code generation (if configured)"
if grep -q "build_runner" pubspec.lock 2>/dev/null; then
  dart run build_runner build --delete-conflicting-outputs || true
fi

echo "==> Running analyzer"
flutter analyze

echo "==> Done"

