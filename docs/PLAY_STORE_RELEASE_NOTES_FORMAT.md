# Google Play Store Release Notes Format Guide

This guide explains the correct format for release notes in Google Play Console.

---

## ❌ INCORRECT Format (This is NOT used)

```xml
<en-GB>
Enter or paste your release notes for en-GB here
</en-GB>
```

**This XML format is NOT used by Google Play or Fastlane!**

---

## ✅ CORRECT Formats

### Method 1: Manual Upload via Web Console

When uploading through [Google Play Console](https://play.google.com/console) web interface:

1. Go to your app → Release → Select track (Internal/Alpha/Beta/Production)
2. Click "Create new release"
3. Upload your AAB file
4. In "Release notes" section, select language from dropdown
5. Paste **plain text** (no XML tags):

```
🎉 Initial Release of Otogapo!

Manage your vehicle association with ease:
• Secure login with Google Sign-In
• Complete member profile management
• Monthly dues tracking & payment history
• Real-time association announcements
• Admin dashboard for user management
• Vehicle & driver's license tracking
• Emergency contact information
• Modern, intuitive interface

Join Otogapo today and streamline your association management!
```

**That's it!** Just plain text, no special formatting.

---

### Method 2: Fastlane Automated Upload

For automated uploads with Fastlane, release notes are stored as **plain text files** in this structure:

```
android/fastlane/metadata/android/
├── en-US/                          # English (United States)
│   ├── changelogs/
│   │   ├── 1.txt                   # Release notes for version code 1
│   │   ├── 2.txt                   # Release notes for version code 2
│   │   └── 3.txt                   # Release notes for version code 3
│   ├── full_description.txt        # Store listing description
│   ├── short_description.txt       # Short description (80 chars)
│   ├── title.txt                   # App title
│   └── video.txt                   # (optional) YouTube video URL
├── fil-PH/                         # Filipino (Philippines)
│   ├── changelogs/
│   │   └── 1.txt
│   ├── title.txt
│   └── short_description.txt
└── [other-language-codes]/         # Add more languages as needed
```

#### Key Points:

1. **No XML tags** - just plain text files
2. **File naming**: `{version_code}.txt` (e.g., `1.txt`, `2.txt`, `3.txt`)
3. **Language codes**: Use ISO 639-1 codes (e.g., `en-US`, `fil-PH`, `es-ES`)
4. **Version code**: Must match the `versionCode` in your app

---

## Language Codes Reference

Common language codes for Play Store:

| Language             | Code     | Example Path               |
| -------------------- | -------- | -------------------------- |
| English (US)         | `en-US`  | `metadata/android/en-US/`  |
| English (UK)         | `en-GB`  | `metadata/android/en-GB/`  |
| Filipino             | `fil-PH` | `metadata/android/fil-PH/` |
| Spanish              | `es-ES`  | `metadata/android/es-ES/`  |
| Japanese             | `ja-JP`  | `metadata/android/ja-JP/`  |
| Korean               | `ko-KR`  | `metadata/android/ko-KR/`  |
| Chinese (Simplified) | `zh-CN`  | `metadata/android/zh-CN/`  |

Full list: [Google Play Language Codes](https://support.google.com/googleplay/android-developer/answer/9844778)

---

## Current Release Notes for v1.0.0 (Build 1)

### English (en-US)

Location: `android/fastlane/metadata/android/en-US/changelogs/1.txt`

```
🎉 Initial Release of Otogapo!

Manage your vehicle association with ease:
• Secure login with Google Sign-In
• Complete member profile management
• Monthly dues tracking & payment history
• Real-time association announcements
• Admin dashboard for user management
• Vehicle & driver's license tracking
• Emergency contact information
• Modern, intuitive interface

Join Otogapo today and streamline your association management!
```

### Filipino (fil-PH)

Location: `android/fastlane/metadata/android/fil-PH/changelogs/1.txt`

```
🎉 Unang Labas ng Otogapo!

Pamahalaan ang inyong samahan ng sasakyan nang madali:
• Secure na pag-login gamit ang Google
• Kumpletong pamamahala ng profile ng miyembro
• Subaybay sa buwanang bayad at kasaysayan
• Real-time na mga abiso ng samahan
• Admin dashboard para sa pamamahala ng users
• Pagtala ng sasakyan at lisensya sa pagmamaneho
• Impormasyon sa emergency contact
• Modernong at madaling gamitin na interface

Sumali sa Otogapo ngayon at gawing simple ang pamamahala ng inyong samahan!
```

---

## Character Limits

Google Play Console has the following limits:

| Field             | Character Limit  |
| ----------------- | ---------------- |
| Release Notes     | 500 characters   |
| Short Description | 80 characters    |
| Full Description  | 4,000 characters |
| App Title         | 50 characters    |

**Note**: The 500 character limit for release notes applies PER LANGUAGE.

---

## How to Add More Languages

### Via Web Console:

1. In release notes section, click "Add language"
2. Select language from dropdown
3. Paste translated release notes
4. Repeat for each language

### Via Fastlane:

1. Create new language folder:

   ```powershell
   New-Item -ItemType Directory -Force -Path "android\fastlane\metadata\android\[LANGUAGE-CODE]\changelogs"
   ```

2. Create changelog file:

   ```powershell
   New-Item -ItemType File -Path "android\fastlane\metadata\android\[LANGUAGE-CODE]\changelogs\1.txt"
   ```

3. Add your translated content to the file

4. Fastlane will automatically upload all language versions

---

## Uploading with Fastlane

Once your metadata files are ready:

```bash
cd android
bundle exec fastlane internal   # For internal testing
bundle exec fastlane alpha      # For alpha track
bundle exec fastlane beta       # For beta track
bundle exec fastlane production # For production
```

Fastlane will automatically:

- Upload the AAB file
- Upload release notes from `changelogs/{version_code}.txt`
- Upload store listing metadata if not skipped

---

## Best Practices

1. **Keep it concise**: Stay under 500 characters
2. **Highlight key features**: Focus on what's new or important
3. **Use emojis sparingly**: They work well but don't overuse
4. **Be clear**: Avoid jargon and technical terms
5. **Localize properly**: Don't just machine-translate, use native speakers
6. **Update for each release**: Explain what changed
7. **Test the format**: Preview in Play Console before publishing

---

## Examples for Future Releases

### Bug Fix Release (v1.0.1)

```
Bug fixes and improvements:
• Fixed login issue on some devices
• Improved payment history loading speed
• Minor UI improvements
• Performance optimizations

Thank you for your feedback!
```

### Feature Release (v1.1.0)

```
What's new in v1.1.0:
• New: Export payment reports to PDF
• New: Dark mode support
• Enhanced: Faster app startup
• Fixed: Profile photo upload issues

Update now to enjoy these new features!
```

### Major Release (v2.0.0)

```
🎊 Major Update - v2.0.0!

New features:
• Complete UI redesign
• Offline mode support
• In-app messaging system
• Advanced analytics dashboard
• Push notifications
• Multiple language support

Experience the new Otogapo today!
```

---

## Troubleshooting

**Q: My release notes are too long**

- A: Keep under 500 characters. Focus on top 3-5 features.

**Q: Emojis don't display correctly**

- A: Use standard Unicode emojis. Test in Play Console preview.

**Q: Fastlane doesn't upload my changelog**

- A: Ensure filename matches version code exactly (e.g., `1.txt` for versionCode 1)

**Q: Can I use HTML or Markdown?**

- A: No, only plain text. Bullets (•) and line breaks are supported.

**Q: Do I need all languages?**

- A: No, English (en-US) is sufficient to start. Add more as needed.

---

## Resources

- [Play Console Release Notes](https://support.google.com/googleplay/android-developer/answer/7159011)
- [Fastlane Supply](https://docs.fastlane.tools/actions/supply/)
- [Language Code List](https://support.google.com/googleplay/android-developer/answer/9844778)

---

**Last Updated**: 2025-10-11  
**Otogapo Version**: 1.0.0
