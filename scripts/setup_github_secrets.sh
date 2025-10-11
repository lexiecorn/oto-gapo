#!/bin/bash

# Script to help set up GitHub Secrets
# This script generates the base64 encoded keystore and shows you what values to set

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}     GitHub Secrets Setup Helper${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

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

echo -e "${YELLOW}Reading keystore and key.properties...${NC}"
echo ""

# Base64 encode the keystore
KEYSTORE_BASE64=$(base64 -w 0 android/keystore/otogapo-release.jks 2>/dev/null || base64 android/keystore/otogapo-release.jks)

# Read values from key.properties
STORE_PASSWORD=$(grep 'storePassword=' android/key.properties | cut -d '=' -f 2)
KEY_ALIAS=$(grep 'keyAlias=' android/key.properties | cut -d '=' -f 2)
KEY_PASSWORD=$(grep 'keyPassword=' android/key.properties | cut -d '=' -f 2)

echo -e "${GREEN}✓ Successfully read configuration${NC}"
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}     Set the following GitHub Secrets:${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "${YELLOW}Go to: GitHub Repository → Settings → Secrets and variables → Actions${NC}"
echo ""

echo -e "${GREEN}1. ANDROID_KEYSTORE_BASE64${NC}"
echo -e "${YELLOW}   Click 'New repository secret' and paste:${NC}"
echo "$KEYSTORE_BASE64"
echo ""

echo -e "${GREEN}2. ANDROID_KEYSTORE_PASSWORD${NC}"
echo -e "${YELLOW}   Value:${NC} $STORE_PASSWORD"
echo ""

echo -e "${GREEN}3. ANDROID_KEY_ALIAS${NC}"
echo -e "${YELLOW}   Value:${NC} $KEY_ALIAS"
echo ""

echo -e "${GREEN}4. ANDROID_KEY_PASSWORD${NC}"
echo -e "${YELLOW}   Value:${NC} $KEY_PASSWORD"
echo ""

echo -e "${GREEN}5. GOOGLE_PLAY_SERVICE_ACCOUNT_JSON${NC}"
echo -e "${YELLOW}   (You'll need to create this from Google Play Console)${NC}"
echo -e "${YELLOW}   Steps:${NC}"
echo "   a. Go to Google Play Console"
echo "   b. Select your app"
echo "   c. Setup → API access"
echo "   d. Create a service account or use existing"
echo "   e. Download JSON key"
echo "   f. Paste the entire JSON content as the secret value"
echo ""

echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}Setup complete! 🎉${NC}"
echo -e "${BLUE}================================================${NC}"

