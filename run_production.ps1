# Run Production Flavor
Write-Host "Cleaning build..."
flutter clean

Write-Host "`nGetting dependencies..."
flutter pub get

Write-Host "`nRunning production flavor..."
flutter run --flavor production --target lib/main_production.dart -d 22101316UG

