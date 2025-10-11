#!/bin/bash

# Script to bump version in pubspec.yaml
# Usage: ./scripts/bump_version.sh [major|minor|patch]

set -e

BUMP_TYPE=${1:-patch}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | cut -d ' ' -f 2)
VERSION_NAME=$(echo $CURRENT_VERSION | cut -d '+' -f 1)
BUILD_NUMBER=$(echo $CURRENT_VERSION | cut -d '+' -f 2)

# Split version into parts
IFS='.' read -r -a VERSION_PARTS <<< "$VERSION_NAME"
MAJOR="${VERSION_PARTS[0]}"
MINOR="${VERSION_PARTS[1]}"
PATCH="${VERSION_PARTS[2]}"

echo -e "${YELLOW}Current version: $VERSION_NAME+$BUILD_NUMBER${NC}"

# Increment version based on bump type
case $BUMP_TYPE in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo -e "${RED}Invalid bump type: $BUMP_TYPE${NC}"
    echo "Usage: $0 [major|minor|patch]"
    exit 1
    ;;
esac

# Increment build number
BUILD_NUMBER=$((BUILD_NUMBER + 1))

# Create new version string
NEW_VERSION="$MAJOR.$MINOR.$PATCH+$BUILD_NUMBER"

echo -e "${GREEN}New version: $NEW_VERSION${NC}"

# Update pubspec.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sed -i '' "s/^version:.*/version: $NEW_VERSION/" pubspec.yaml
else
  # Linux
  sed -i "s/^version:.*/version: $NEW_VERSION/" pubspec.yaml
fi

echo -e "${GREEN}✓ Version bumped successfully!${NC}"
echo -e "Version: ${GREEN}$VERSION_NAME${NC} → ${GREEN}$MAJOR.$MINOR.$PATCH${NC}"
echo -e "Build: ${GREEN}$((BUILD_NUMBER - 1))${NC} → ${GREEN}$BUILD_NUMBER${NC}"

# Verify the change
UPDATED_VERSION=$(grep '^version:' pubspec.yaml | cut -d ' ' -f 2)
if [ "$UPDATED_VERSION" = "$NEW_VERSION" ]; then
  echo -e "${GREEN}✓ Verification successful${NC}"
else
  echo -e "${RED}✗ Verification failed${NC}"
  exit 1
fi

