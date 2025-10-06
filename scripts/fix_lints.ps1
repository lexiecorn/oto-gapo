Param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "==> Ensuring dependencies"
flutter pub get

Write-Host "==> Applying dart fixes"
dart fix --apply

Write-Host "==> Formatting code"
dart format .

Write-Host "==> Running code generation (if configured)"
if (Test-Path "pubspec.lock") {
  $hasBuildRunner = Select-String -Path "pubspec.lock" -Pattern "build_runner" -Quiet
  if ($hasBuildRunner) {
    try {
      dart run build_runner build --delete-conflicting-outputs | Out-Null
    } catch {
      # Non-fatal for CI convenience
    }
  }
}

Write-Host "==> Running analyzer"
flutter analyze

Write-Host "==> Done"

