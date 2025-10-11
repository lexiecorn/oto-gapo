#!/bin/bash

# Script to build production release
# Usage: ./scripts/build_production.sh [apk|appbundle|both]

set -e

BUILD_TYPE=${1:-both}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}     Otogapo Production Build Script${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if we're in the project root
if [ ! -f "pubspec.yaml" ]; then
  echo -e "${RED}Error: pubspec.yaml not found. Please run this script from the project root.${NC}"
  exit 1
fi

# Check if keystore exists
if [ ! -f "android/keystore/otogapo-release.jks" ]; then
  echo -e "${RED}Error: Release keystore not found at android/keystore/otogapo-release.jks${NC}"
  exit 1
fi

# Check if key.properties exists
if [ ! -f "android/key.properties" ]; then
  echo -e "${RED}Error: key.properties not found at android/key.properties${NC}"
  exit 1
fi

# Get current version
VERSION=$(grep '^version:' pubspec.yaml | cut -d ' ' -f 2)
echo -e "${YELLOW}Building version: $VERSION${NC}"
echo ""

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
flutter clean
echo -e "${GREEN}✓ Clean complete${NC}"
echo ""

# Get dependencies
echo -e "${YELLOW}Getting dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Generate code
echo -e "${YELLOW}Generating code...${NC}"
dart run build_runner build --delete-conflicting-outputs
echo -e "${GREEN}✓ Code generation complete${NC}"
echo ""

# Run tests
echo -e "${YELLOW}Running tests...${NC}"
if flutter test; then
  echo -e "${GREEN}✓ All tests passed${NC}"
else
  echo -e "${RED}✗ Tests failed. Aborting build.${NC}"
  exit 1
fi
echo ""

# Build based on type
case $BUILD_TYPE in
  apk)
    echo -e "${YELLOW}Building APK...${NC}"
    flutter build apk --release --target lib/main_production.dart --flavor production
    echo -e "${GREEN}✓ APK build complete${NC}"
    echo -e "${BLUE}APK location: build/app/outputs/flutter-apk/app-production-release.apk${NC}"
    ;;
    
  appbundle)
    echo -e "${YELLOW}Building App Bundle...${NC}"
    flutter build appbundle --release --target lib/main_production.dart --flavor production
    echo -e "${GREEN}✓ App Bundle build complete${NC}"
    echo -e "${BLUE}AAB location: build/app/outputs/bundle/productionRelease/app-production-release.aab${NC}"
    ;;
    
  both)
    echo -e "${YELLOW}Building App Bundle...${NC}"
    flutter build appbundle --release --target lib/main_production.dart --flavor production
    echo -e "${GREEN}✓ App Bundle build complete${NC}"
    echo ""
    
    echo -e "${YELLOW}Building APK...${NC}"
    flutter build apk --release --target lib/main_production.dart --flavor production
    echo -e "${GREEN}✓ APK build complete${NC}"
    echo ""
    
    echo -e "${BLUE}Build artifacts:${NC}"
    echo -e "  AAB: build/app/outputs/bundle/productionRelease/app-production-release.aab"
    echo -e "  APK: build/app/outputs/flutter-apk/app-production-release.apk"
    ;;
    
  *)
    echo -e "${RED}Invalid build type: $BUILD_TYPE${NC}"
    echo "Usage: $0 [apk|appbundle|both]"
    exit 1
    ;;
esac

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}     Build completed successfully! 🎉${NC}"
echo -e "${GREEN}================================================${NC}"

