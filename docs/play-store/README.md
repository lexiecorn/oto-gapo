# Play Store Assets

This directory contains text files for Google Play Store listings and release notes.

## Files

### Store Listing

- **`PLAY_STORE_FULL_DESCRIPTION.txt`** - Full app description for the Play Store listing (up to 4000 characters)
- **`PLAY_STORE_SHORT_DESCRIPTION.txt`** - Short description for the Play Store listing (up to 80 characters)

### Release Notes

- **`PLAY_STORE_WHATS_NEW.txt`** - Template for "What's New" section in releases (up to 500 characters)
- **`PLAY_STORE_WHATS_NEW_v1.0.0+6.txt`** - What's New for version 1.0.0+6
- **`PLAY_STORE_RELEASE_NOTES_v1.0.0+6.txt`** - Detailed release notes for version 1.0.0+6
- **`RELEASE_NOTES_QUICK.txt`** - Quick reference release notes

## Usage

### Updating Store Listing

1. Edit `PLAY_STORE_FULL_DESCRIPTION.txt` and `PLAY_STORE_SHORT_DESCRIPTION.txt`
2. Go to [Google Play Console](https://play.google.com/console)
3. Select your app
4. Navigate to **Store presence** > **Main store listing**
5. Update the descriptions with the content from the files

### Creating Release Notes

1. Copy `PLAY_STORE_WHATS_NEW.txt` and update with version-specific changes
2. Keep it under 500 characters
3. Focus on user-facing changes
4. Use clear, concise language

### Character Limits

- **Short Description**: Maximum 80 characters
- **Full Description**: Maximum 4000 characters
- **What's New**: Maximum 500 characters per release

## Best Practices

- Write in the user's language
- Highlight key features and benefits
- Use bullet points for clarity
- Keep release notes focused on user-facing changes
- Test descriptions for readability

## Documentation

For more details on Play Store setup and deployment, see:

- [../PLAY_STORE_SETUP.md](../PLAY_STORE_SETUP.md)
- [../UPLOAD_TO_PLAY_STORE_GUIDE.md](../UPLOAD_TO_PLAY_STORE_GUIDE.md)
- [../QUICK_UPLOAD_CHECKLIST.md](../QUICK_UPLOAD_CHECKLIST.md)
- [../RELEASE_CHECKLIST.md](../RELEASE_CHECKLIST.md)
