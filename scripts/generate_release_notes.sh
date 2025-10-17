#!/bin/bash
# Generate Play Store release notes from CHANGELOG.md
# This script extracts the latest version section and formats it for Play Store

set -e

VERSION=${CM_TAG#v}  # Remove 'v' prefix from tag (e.g., v1.2.0 -> 1.2.0)
CHANGELOG="CHANGELOG.md"
OUTPUT="PLAY_STORE_WHATS_NEW.txt"
MAX_CHARS=500

echo "📝 Generating release notes for version $VERSION..."

# Check if CHANGELOG exists
if [ ! -f "$CHANGELOG" ]; then
  echo "❌ Error: $CHANGELOG not found"
  exit 1
fi

# Extract content between [X.Y.Z] and next [X.Y.Z] or end of file
awk -v version="$VERSION" '
  BEGIN { 
    capture=0
    found=0
    has_content=0
  }
  
  # Stop at next version section
  /^## \[/ {
    if (capture == 1) { exit }
    if ($0 ~ "\\[" version "\\]") { 
      capture=1
      found=1
      next 
    }
  }
  
  # Skip empty lines at start
  capture == 1 && /^$/ && has_content == 0 { next }
  
  # Skip section headers (### Added, ### Fixed, etc.)
  capture == 1 && /^### / { 
    section = $2
    if (section == "Added") { print "\n✨ New Features:" }
    else if (section == "Fixed") { print "\n🐛 Bug Fixes:" }
    else if (section == "Changed") { print "\n🔄 Changes:" }
    else if (section == "Security") { print "\n🔒 Security:" }
    has_content=1
    next 
  }
  
  # Convert markdown list items to bullet points
  capture == 1 && /^- / { 
    has_content=1
    # Remove leading "- " and add bullet
    print "• " substr($0, 3)
    next 
  }
  
  # Print other non-empty lines
  capture == 1 && NF > 0 && !/^#/ { 
    has_content=1
    print 
  }
  
  END { 
    if (found == 0) { 
      print "❌ Version " version " not found in CHANGELOG.md" > "/dev/stderr"
      exit 1
    }
    if (has_content == 0) {
      print "⚠️  Warning: No content found for version " version > "/dev/stderr"
    }
  }
' "$CHANGELOG" > "$OUTPUT.tmp"

# Check if extraction succeeded
if [ $? -ne 0 ] || [ ! -s "$OUTPUT.tmp" ]; then
  echo "⚠️  Could not extract version $VERSION from CHANGELOG"
  echo "   Falling back to generic release notes..."
  cat > "$OUTPUT" << EOF
🎉 What's New in v${VERSION}!

✨ New features and improvements
🐛 Bug fixes and stability improvements

Thank you for using Otogapo!
EOF
else
  # Add header
  {
    echo "🎉 What's New in v${VERSION}!"
    echo ""
    cat "$OUTPUT.tmp"
    echo ""
    echo "📝 Thank you for using Otogapo!"
  } > "$OUTPUT"
fi

# Clean up temp file
rm -f "$OUTPUT.tmp"

# Check character count
CHAR_COUNT=$(wc -c < "$OUTPUT" | tr -d ' ')

if [ "$CHAR_COUNT" -gt "$MAX_CHARS" ]; then
  echo "⚠️  Warning: Release notes are $CHAR_COUNT characters (recommended max: $MAX_CHARS)"
  echo "   Consider shortening for better display on Play Store"
  echo ""
  echo "💡 Tips to shorten:"
  echo "   - Focus on 3-5 most important changes"
  echo "   - Remove less critical items"
  echo "   - Use shorter descriptions"
else
  echo "✅ Release notes are $CHAR_COUNT characters (within $MAX_CHARS limit)"
fi

echo ""
echo "📄 Generated release notes:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$OUTPUT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Release notes saved to: $OUTPUT"

