# Google Play Store Setup Guide

This guide walks you through setting up Otogapo on the Google Play Store for the first time.

## Prerequisites

- [ ] Google Play Developer account ($25 one-time fee)
- [ ] Valid payment method
- [ ] Developer account in good standing
- [ ] Signed AAB file ready for upload

## Table of Contents

1. [Initial Play Store Console Setup](#initial-play-store-console-setup)
2. [App Creation](#app-creation)
3. [Store Listing](#store-listing)
4. [Content Rating](#content-rating)
5. [App Content](#app-content)
6. [Pricing and Distribution](#pricing-and-distribution)
7. [Release Management](#release-management)
8. [Google Play Console API Setup](#google-play-console-api-setup)
9. [Testing Tracks](#testing-tracks)

---

## Initial Play Store Console Setup

### 1. Access Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Sign in with your Google Play Developer account
3. Accept any updated terms and policies

### 2. Complete Developer Profile

1. Navigate to **Settings** → **Developer account** → **Account details**
2. Fill in:
   - Developer name: `DigitApp Studio`
   - Email address
   - Phone number
   - Website URL
3. Add business information if applicable

---

## App Creation

### 1. Create New App

1. Click **Create app** button
2. Fill in the required information:
   - **App name**: `Otogapo`
   - **Default language**: `English (United States)`
   - **App or game**: `App`
   - **Free or paid**: `Free`
3. Accept declarations:
   - [ ] Developer Program Policies
   - [ ] US export laws
4. Click **Create app**

### 2. App Access

1. Go to **App content** → **App access**
2. Select: `All functionality is available without special access`
   (Or describe restricted access if applicable)
3. Click **Save**

---

## Store Listing

### 1. Main Store Listing

Navigate to **Store presence** → **Main store listing**

#### App Details

- **App name**: `Otogapo - Vehicle Association`
- **Short description** (80 characters):

  ```
  Manage your vehicle association membership, payments, and community updates.
  ```

- **Full description** (up to 4,000 characters):

  ```
  Otogapo is a comprehensive vehicle association management application designed to streamline membership management, payment tracking, and community communication for vehicle association members and administrators.

  KEY FEATURES:

  🔐 Secure Authentication
  • Firebase-powered authentication
  • Google Sign-In support
  • Secure session management

  👥 Member Management
  • Complete member profile management
  • Vehicle registration and details
  • Driver's license information tracking
  • Emergency contact information

  💰 Payment Tracking
  • Monthly dues management
  • Payment status monitoring
  • Payment history and statistics
  • Advance payment support

  📢 Announcements
  • Association-wide announcements
  • Real-time updates
  • Important notices and events

  👨‍💼 Admin Dashboard
  • User management
  • Payment oversight
  • Member statistics and reports
  • Administrative functions

  BENEFITS:

  ✓ Simplified membership management
  ✓ Easy payment tracking and monitoring
  ✓ Stay updated with association news
  ✓ Secure and reliable platform
  ✓ Modern and intuitive interface
  ✓ Responsive design for all devices

  WHO IS IT FOR?

  Otogapo is perfect for:
  • Vehicle association members
  • Association administrators
  • Super admins managing multiple associations
  • Anyone involved in vehicle association management

  SECURITY & PRIVACY:

  Your data security is our priority. Otogapo uses industry-standard encryption and secure authentication to protect your information. We follow strict data protection guidelines and never share your personal information without consent.

  SUPPORT:

  Need help? Contact our support team for assistance with any questions or issues.

  Download Otogapo today and experience hassle-free vehicle association management!
  ```

#### Graphic Assets

**App Icon** (Already configured in project)

- 512x512 PNG (32-bit)
- Icon should match the one in `android/app/src/main/res/mipmap-xxxhdpi/`

**Feature Graphic** (Required)

- Size: 1024 x 500 pixels
- Format: PNG or JPG
- No transparency
- Create using design tool (Figma, Canva, etc.)
- Should showcase app name and key feature

**Phone Screenshots** (Required - minimum 2, maximum 8)

- Dimensions: 16:9 aspect ratio recommended
- Minimum dimension: 320px
- Maximum dimension: 3840px
- Recommended: 1080 x 1920 or 1440 x 2560
- Take screenshots from:
  1. Login/Splash screen
  2. Main dashboard
  3. Profile page
  4. Payment tracking
  5. Admin dashboard
  6. Announcements

**Tablet Screenshots** (Optional but recommended)

- 7-inch and 10-inch tablet screenshots

**Tips for Screenshots:**

- Use clean backgrounds
- Show actual app functionality
- Avoid excessive text overlay
- Showcase key features
- Use consistent device frames (optional)

#### Contact Details

- **Email**: `support@otogapo.com` (or your support email)
- **Phone**: (Optional but recommended)
- **Website**: Your official website URL
- **Privacy Policy URL**: **Required** - See [Privacy Policy Setup](#privacy-policy)

#### Category

- **App Category**: `Productivity` or `Business`
- **Tags**: (If prompted)
  - Vehicle management
  - Association
  - Membership
  - Payment tracking

---

## Content Rating

### 1. Start Content Rating Questionnaire

1. Go to **App content** → **Content rating**
2. Enter your email address
3. Select app category: `Utility, Productivity, Communication, or other tools`

### 2. Answer Questionnaire

Answer honestly about your app content:

- **Violence**: No
- **Sexuality**: No
- **Language**: No
- **Controlled Substances**: No
- **Gambling**: No
- **User Interaction**: Yes (users can communicate)
  - [ ] Users can communicate with each other
  - [ ] Users can share personal information
- **Personal Information**: Yes
  - [ ] Collects personal information
  - [ ] Has a privacy policy

### 3. Submit for Rating

- Review your answers
- Submit questionnaire
- Receive ratings (usually Everyone or Everyone 10+)

---

## App Content

### 1. Privacy Policy

**Required for all apps on Play Store**

Create a privacy policy that covers:

- What data you collect
- How you use the data
- How you protect the data
- User rights
- Contact information

Host the privacy policy:

- On your website
- Using services like [Privacy Policy Generator](https://www.privacypolicygenerator.info/)
- GitHub Pages

Add the URL in:

- Store listing → Privacy Policy
- In-app settings

### 2. Data Safety

Navigate to **App content** → **Data safety**

Declare data collection and security practices:

**Data Collection:**

- [ ] Collect user account information (email, name)
- [ ] Collect location (if applicable)
- [ ] Collect payment information
- [ ] Collect device ID

**Data Usage:**

- App functionality
- Account management
- Authentication

**Data Sharing:**

- State if data is shared with third parties
- Firebase services
- PocketBase backend

**Security Practices:**

- [ ] Data is encrypted in transit (HTTPS)
- [ ] Data is encrypted at rest
- [ ] Users can request data deletion
- [ ] Follows Families Policy (if targeting children)

### 3. Ads Declaration

- Go to **App content** → **Ads**
- Select: `No, my app does not contain ads` (unless you have ads)

### 4. Target Audience

1. Go to **App content** → **Target audience and content**
2. Select target age groups:
   - [ ] 18+ (Primary target for vehicle owners)
3. Declare if app appeals to children: `No`

---

## Pricing and Distribution

### 1. Countries

1. Go to **Release** → **Production** → **Countries/regions**
2. Select countries where you want to distribute:
   - [ ] All countries (recommended initially)
   - Or select specific countries
3. For Philippines-focused app, at minimum select:
   - [ ] Philippines
   - Consider adding other countries later

### 2. Pricing

- **Pricing**: Free (already selected)
- **In-app products**: Configure if you have paid features

---

## Release Management

### 1. Internal Testing Track (First Release)

1. Go to **Release** → **Testing** → **Internal testing**
2. Click **Create new release**
3. Upload your signed AAB file
4. Release name: `1.0.0 (1)` - Internal Testing
5. Release notes:

   ```
   Initial release for internal testing.

   Features:
   • User authentication
   • Member profile management
   • Payment tracking
   • Admin dashboard
   • Announcements
   ```

6. Add internal testers:
   - Create a test email list
   - Add up to 100 internal testers (no review needed)
7. Review and roll out release

### 2. Testing Tracks Overview

- **Internal testing**: Up to 100 testers, no review, instant
- **Closed testing**: Unlimited testers, no review, instant
- **Open testing**: Public, no review, anyone can join
- **Production**: Public, requires Google review (usually 24-48 hours)

### 3. Staged Rollout Strategy

For production releases:

1. Start with internal testing
2. Move to closed testing (alpha/beta)
3. Get feedback and fix issues
4. Production release with staged rollout:
   - Start at 5% of users
   - Monitor crash rates and reviews
   - Increase to 20%, 50%, then 100%

---

## Google Play Console API Setup

Required for automated deployments with Fastlane.

### 1. Enable Google Play Developer API

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing: `Otogapo`
3. Enable **Google Play Developer API**:
   - Navigate to **APIs & Services** → **Library**
   - Search for "Google Play Developer API"
   - Click **Enable**

### 2. Create Service Account

1. In Google Cloud Console, go to **IAM & Admin** → **Service Accounts**
2. Click **Create Service Account**
3. Service account details:
   - Name: `otogapo-fastlane-deploy`
   - Description: `Service account for automated Play Store deployments`
4. Click **Create and Continue**
5. Skip granting access (we'll do this in Play Console)
6. Click **Done**

### 3. Create JSON Key

1. Click on the created service account
2. Go to **Keys** tab
3. Click **Add Key** → **Create new key**
4. Select **JSON** format
5. Click **Create**
6. Save the JSON file securely (you'll need this for GitHub Secrets)

### 4. Grant Play Console Access

1. Go back to [Google Play Console](https://play.google.com/console)
2. Navigate to **Settings** → **Developer account** → **API access**
3. Link your Google Cloud project if not already linked
4. Find your service account in the list
5. Click **Grant access**
6. Set permissions:
   - [ ] View app information
   - [ ] Manage releases 
   - [ ] Manage store presence
7. Click **Invite user**
8. Accept the invitation (check email)

### 5. Add to GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
5. Value: Paste the entire content of the JSON key file
6. Click **Add secret**

---

## Testing Tracks

### Internal Testing

**Purpose**: Quick testing with small team  
**Testers**: Up to 100 users  
**Review**: Not required  
**Availability**: Instant

**Setup:**

1. Create email list in Play Console
2. Add tester emails
3. Testers receive invitation link
4. No Google review needed

### Closed Testing (Alpha/Beta)

**Purpose**: Larger testing group  
**Testers**: Unlimited  
**Review**: Not required  
**Availability**: Instant

**Setup:**

1. Create release in Closed testing track
2. Create or manage testing lists
3. Share opt-in link with testers
4. Or integrate with Google Groups

### Open Testing

**Purpose**: Public beta  
**Testers**: Anyone with link  
**Review**: Not required  
**Availability**: Instant

**Setup:**

1. Create release in Open testing track
2. Anyone with link can join
3. Visible in Play Store with "Early Access" label

### Production

**Purpose**: Public release  
**Testers**: All users in selected countries  
**Review**: Required by Google  
**Availability**: 24-48 hours for review

**Setup:**

1. Complete all Play Console requirements
2. Create production release
3. Submit for review
4. Monitor review status
5. Use staged rollout for safety

---

## Post-Setup Checklist

After completing the setup:

- [ ] App created in Play Console
- [ ] Store listing completed with all assets
- [ ] Content rating obtained
- [ ] Privacy policy published and linked
- [ ] Data safety section completed
- [ ] Countries and pricing configured
- [ ] Internal testing release uploaded
- [ ] Internal testers added and invited
- [ ] Google Play Console API enabled
- [ ] Service account created and configured
- [ ] GitHub Secrets configured
- [ ] Fastlane tested with internal track
- [ ] Team familiar with release process

---

## Troubleshooting

### Common Issues

**1. Upload Failed: Duplicate Version**

- Increment version code in `pubspec.yaml`
- Build number must be higher than previous upload

**2. API Error: Unauthorized**

- Verify service account has correct permissions
- Re-check GitHub secret for JSON key
- Ensure API is enabled in Google Cloud Console

**3. Review Rejection**

- Read rejection reason carefully
- Fix issues mentioned
- Re-submit after fixes

**4. Screenshots Not Accepted**

- Check image dimensions
- Ensure no transparency
- Remove excessive text overlay

**5. Missing Privacy Policy**

- Create and host privacy policy
- Add URL to store listing
- Ensure URL is publicly accessible

---

## Additional Resources

- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Play Console API Documentation](https://developers.google.com/android-publisher)
- [Fastlane Supply Documentation](https://docs.fastlane.tools/actions/supply/)
- [Play Store Review Guidelines](https://play.google.com/about/developer-content-policy/)

---

## Contact Information

For Otogapo-specific setup questions:

- Email: [Your team email]
- Internal Docs: `/docs` folder in repository

For Play Store policies and support:

- [Play Console Support](https://support.google.com/googleplay/android-developer/answer/7218994)

---

**Last Updated**: 2025-10-11  
**Version**: 1.0
