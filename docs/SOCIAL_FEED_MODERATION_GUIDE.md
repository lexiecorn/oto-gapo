# Social Feed Moderation Guide

**Version**: 1.0  
**Last Updated**: 2025-10-19  
**Target Audience**: Super Admins and Admins

---

## Overview

This guide provides comprehensive instructions for moderating the OtoGapo social feed. As an admin, you are responsible for maintaining a safe, respectful, and engaging community environment.

---

## Table of Contents

1. [Accessing the Moderation Dashboard](#accessing-the-moderation-dashboard)
2. [Reports Management](#reports-management)
3. [Content Moderation](#content-moderation)
4. [User Bans](#user-bans)
5. [Best Practices](#best-practices)
6. [Common Scenarios](#common-scenarios)
7. [FAQs](#faqs)

---

## Accessing the Moderation Dashboard

### Prerequisites

- Admin or Super Admin account (membership_type = 1 or 2)
- App version 1.0.0+10 or later

### Steps

1. Open the OtoGapo app
2. Navigate to the **Admin Panel** from the home menu
3. Tap on **"Social Feed Moderation"** card
4. You'll see the moderation dashboard with 3 tabs:
   - **Reports** - User-submitted content reports
   - **Hidden Content** - Content hidden by admins
   - **Bans** - Active and expired user bans

---

## Reports Management

### Understanding Reports

Users can report posts or comments for the following reasons:

- **Spam** - Unwanted promotional content or repetitive posts
- **Inappropriate** - Content that violates community guidelines
- **Harassment** - Bullying, threats, or targeted attacks
- **Other** - Any other concern with optional details

### Report Statuses

- **Pending** - Awaiting admin review
- **Reviewed** - Admin has taken action
- **Dismissed** - Report determined to be unfounded

### Reviewing Reports

1. **Access Reports Tab**:

   - Navigate to the "Reports" tab
   - Reports are sorted by creation date (newest first)
   - Pending reports appear at the top

2. **Review Report Details**:

   - **Reporter**: Who submitted the report
   - **Reported Content**: Post or comment in question
   - **Reason**: Why it was reported
   - **Details**: Additional context provided by reporter
   - **Timestamp**: When the report was submitted

3. **Take Action**:

   - **View Content**: Tap to view the full post/comment
   - **Review Context**: Check user's history and past behavior
   - **Choose Action**:
     - Hide content (soft removal)
     - Delete content (permanent removal)
     - Ban user (temporary or permanent)
     - Dismiss report (if unfounded)

4. **Add Admin Notes**:

   - Document your decision
   - Provide reasoning for transparency
   - Notes are visible to other admins

5. **Mark as Reviewed**:
   - Changes status from "Pending" to "Reviewed"
   - Tracks when and by whom the report was handled

### Tips for Reviewing Reports

✅ **DO**:

- Review all available context before acting
- Check the reported user's post history
- Be consistent in enforcement
- Document your decisions with clear notes
- Consider the severity and intent

❌ **DON'T**:

- Act on reports without investigation
- Let personal biases influence decisions
- Dismiss valid concerns
- Over-moderate minor infractions

---

## Content Moderation

### Content Actions

#### 1. Hide Content

**When to use**:

- First-time minor violations
- Content that violates guidelines but isn't severe
- Situations requiring temporary removal while investigating

**How to hide**:

1. From a report or the "Hidden Content" tab
2. Tap "Hide Post" or "Hide Comment"
3. Add admin note explaining the reason
4. Content is hidden from public view but recoverable

**Effect**:

- Content is no longer visible to users
- Original poster can't see it in their feed
- Admins can still view and unhide if needed
- Flags `is_hidden_by_admin = true`

#### 2. Delete Content

**When to use**:

- Severe violations (harassment, explicit content)
- Spam that shouldn't be preserved
- Repeat violations after warnings

**How to delete**:

1. From the post/comment detail page
2. Tap "Delete" in the menu
3. Confirm deletion
4. Add admin note for audit trail

**Effect**:

- Soft delete (can be restored from database if needed)
- Flags `is_active = false`
- Not visible to anyone except database admins

#### 3. Unhide Content

**When to use**:

- Report was determined to be unfounded
- Content was hidden in error
- User successfully appealed the decision

**How to unhide**:

1. Go to "Hidden Content" tab
2. Find the content
3. Tap "Unhide"
4. Add note explaining why

### Content Guidelines

Content should be removed if it contains:

- **Explicit sexual content** or nudity
- **Hate speech** or discrimination
- **Graphic violence** or gore
- **Harassment** or bullying
- **Illegal activities** or promotion thereof
- **Spam** or excessive self-promotion
- **Impersonation** or fake accounts
- **Personal information** (doxxing)

---

## User Bans

### Ban Types

1. **Post Ban**

   - User cannot create new posts
   - Can still comment and react
   - Use for users who spam posts

2. **Comment Ban**

   - User cannot add or edit comments
   - Can still create posts and react
   - Use for users who harass via comments

3. **All Ban**
   - Complete ban from social feed
   - Cannot post, comment, or react
   - Use for severe or repeat violations

### Ban Durations

#### Temporary Bans

- **3 days** - First offense, minor violation
- **7 days** - Second offense or moderate violation
- **30 days** - Third offense or serious violation
- **Custom** - Any duration you specify

**Temporary bans automatically expire** after the set duration.

#### Permanent Bans

- No expiration date
- For severe violations or repeated offenders
- Can only be lifted manually by an admin

### Implementing Bans

1. **From a Report**:

   - Review the report
   - Tap "Ban User"
   - Select ban type (post/comment/all)
   - Choose duration (temporary or permanent)
   - Add admin note with reason

2. **From User Profile**:

   - Navigate to user's posts page
   - Tap menu → "Ban User"
   - Follow same steps as above

3. **Ban Configuration**:
   ```
   Ban Type: [Post | Comment | All]
   Duration: [3 days | 7 days | 30 days | Custom | Permanent]
   Reason: [Required text field]
   Admin Notes: [Optional details for other admins]
   ```

### Managing Bans

#### View Active Bans

1. Go to "Bans" tab
2. Filter by "Active" to see current bans
3. View ban details:
   - Banned user
   - Ban type
   - Start and expiration dates
   - Banning admin
   - Reason

#### Unban a User

1. Find the ban in "Bans" tab
2. Tap "Unban User"
3. Confirm action
4. Add note explaining why ban was lifted

#### View Ban History

- All bans (active and expired) are preserved
- Filter by user to see their ban history
- Helps track repeat offenders

### Ban Escalation Guidelines

**First Violation**: Warning + Hide content  
**Second Violation**: 3-day ban  
**Third Violation**: 7-day ban  
**Fourth Violation**: 30-day ban  
**Fifth Violation**: Permanent ban

**Severe Violations**: Skip directly to permanent ban

- Explicit content
- Threats of violence
- Hate speech
- Doxxing

---

## Best Practices

### Response Time

- Review pending reports within **24 hours**
- Respond to user appeals within **48 hours**
- Take immediate action on severe violations

### Consistency

- Apply rules uniformly across all members
- Document all moderation decisions
- Coordinate with other admins on borderline cases

### Communication

- Add clear admin notes to all actions
- Explain decisions when unban requests are made
- Update community guidelines as needed

### Transparency

- Keep records of all moderation actions
- Share moderation stats with leadership monthly
- Be open about why content was removed

### Fairness

- Consider context and intent
- Allow users to appeal bans
- Give warnings before bans when possible
- Distinguish between mistakes and malice

### Privacy

- Never share reporter identity with reported user
- Keep admin notes professional and factual
- Respect user privacy when reviewing content

---

## Common Scenarios

### Scenario 1: Spam Post

**Situation**: User posts promotional content for external product

**Action**:

1. Hide the post
2. Add note: "Commercial spam - violates community guidelines"
3. Send warning to user (if first offense)
4. If repeated: 3-day post ban

### Scenario 2: Inappropriate Comment

**Situation**: User leaves offensive comment on another member's post

**Action**:

1. Hide the comment immediately
2. Review user's comment history
3. If first offense: Warning + hide
4. If repeated: 7-day comment ban
5. Add note documenting pattern

### Scenario 3: Harassment Report

**Situation**: User A reports User B for targeted harassment across multiple posts

**Action**:

1. Review all reported comments
2. Check User B's comment history
3. Hide all harassing comments
4. Implement 7-30 day "all" ban depending on severity
5. Add detailed notes for other admins
6. Monitor User B after ban expires

### Scenario 4: False Report

**Situation**: Report submitted but content doesn't violate guidelines

**Action**:

1. Review content thoroughly
2. Dismiss report with reason
3. Add note: "Content reviewed, no violation found"
4. If reporter has pattern of false reports, consider warning

### Scenario 5: Borderline Content

**Situation**: Content is questionable but not clearly violating guidelines

**Action**:

1. Consult with other admins
2. Consider community context
3. If uncertain, hide temporarily
4. Discuss with team to clarify guidelines
5. Update moderation policies if needed

### Scenario 6: Appeal Request

**Situation**: Banned user requests unban via other channels

**Action**:

1. Review original ban reason and evidence
2. Check if user acknowledges violation
3. Consider time served vs offense severity
4. If appeal granted:
   - Unban user
   - Add note explaining decision
   - Warn user this is final chance
5. If denied:
   - Explain reason clearly
   - State what's needed for future appeal

---

## FAQs

### How long should I keep content hidden before deleting?

Generally 7-30 days. This allows for appeals and review. Severe violations can be deleted immediately.

### Can users see who reported them?

No. Reporter identity is always kept confidential.

### What if another admin disagrees with my decision?

Discuss in the admin group. You can always unhide content or lift bans if team reaches different consensus. Document the discussion in admin notes.

### Should I notify users when I hide their content?

The app doesn't have built-in notifications for this. Consider adding this as a future feature. For now, users will notice their content is hidden.

### How do I handle disputes between members?

Hide inflammatory comments from both sides. If it escalates to harassment, ban the aggressor. Mediate if both parties are at fault.

### What if I accidentally hide the wrong post?

Unhide it immediately and add a note explaining the error. It happens, and transparency is important.

### Can I permanently delete content from the database?

Only database administrators can do this. Normal delete is a soft delete that can be restored if needed.

### How do I track repeat offenders?

Use the "Bans" tab to view user's ban history. Check their posts/comments before taking action to see patterns.

### What should I do about posts with personal information?

Delete immediately. This is doxxing and a severe violation. Permanent ban if intentional.

### How do I moderate group disagreements?

Stay neutral. Remove content that violates guidelines regardless of which "side" posted it. Focus on behavior, not opinions.

---

## Emergency Contacts

**Technical Issues**:

- Contact: Development Team
- Email: [your-team-email]

**Legal Concerns**:

- Contact: [Legal Contact]
- Response Time: Within 2 hours for severe violations

**Community Management**:

- Lead Moderator: [Name]
- Admin Group: [Platform]

---

## Revision History

- **v1.0** (2025-10-19): Initial moderation guide
  - Complete moderation workflows
  - Ban management procedures
  - Best practices and common scenarios

---

## Appendix: Moderation Checklist

### Daily Tasks

- [ ] Review all pending reports
- [ ] Check for new content flagged by users
- [ ] Monitor recently active users with past violations

### Weekly Tasks

- [ ] Review hidden content (unhide or delete)
- [ ] Check expiring bans
- [ ] Update other admins on patterns/trends

### Monthly Tasks

- [ ] Generate moderation stats report
- [ ] Review and update community guidelines
- [ ] Audit past decisions for consistency
- [ ] Discuss challenging cases with admin team

---

**Remember**: Your role is to keep the community safe and welcoming while respecting member privacy and freedom of expression. When in doubt, consult with fellow admins and err on the side of transparency and fairness.
