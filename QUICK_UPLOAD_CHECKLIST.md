# Quick Upload Checklist

## ✅ Build Information

- **Version**: 1.0.0+5
- **AAB File**: `build\app\outputs\bundle\productionRelease\app-production-release.aab`
- **File Size**: 56.0 MB
- **Build Date**: October 17, 2025

---

## 📋 Quick Steps

### 1. Locate Your AAB File

```
F:\madmonkey2\oto-gapo\build\app\outputs\bundle\productionRelease\app-production-release.aab
```

### 2. Go to Play Console

- URL: https://play.google.com/console
- Select: Otogapo app

### 3. Choose Track

- **Internal Testing** (Recommended) → Testing → Internal testing
- **Production** → Production

### 4. Create Release

- Click "Create new release"
- Upload: `app-production-release.aab`
- Wait for processing

### 5. Add Release Notes

**Copy this for "What's New":**

```
🎉 Welcome to Otogapo v1.0.0!

✨ Features:
• Secure authentication with Google Sign-In
• Member profile & vehicle management
• Monthly dues tracking with payment history
• Association announcements
• Admin dashboard & gallery management

📝 First production release. Feedback welcome!
```

### 6. Review & Submit

- Review all details
- Click "Start rollout"
- Confirm

---

## 🚨 Quick Troubleshooting

**Version already exists?**
→ Bump version in pubspec.yaml and rebuild

**Store listing incomplete?**
→ Complete all fields in Store presence → Main store listing

**Privacy policy missing?**
→ Add URL in Store presence → Privacy policy

**Content rating needed?**
→ Complete questionnaire in App content → Content rating

---

## 📞 Need Help?

See: `UPLOAD_TO_PLAY_STORE_GUIDE.md` for detailed instructions
