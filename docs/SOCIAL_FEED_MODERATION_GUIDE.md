# Social Feed Moderation Guide

## Overview

This guide is for administrators responsible for moderating the social feed content. The moderation system provides tools to maintain a safe and welcoming community.

## Accessing Moderation Dashboard

1. **Login** as an admin user (membership_type 1 or 2)
2. Navigate to **Admin Panel** from Settings
3. Tap **Social Feed Moderation** card
4. Access 3 moderation tabs: Reports, Hidden Content, Bans

## Moderation Dashboard Tabs

### Tab 1: Reports

Displays all content reports submitted by users.

**Report Information**:

- Report reason (spam, inappropriate, harassment, other)
- Reporter name and timestamp
- Additional details (if provided)
- Current status (pending, reviewed, resolved, dismissed)
- Content preview

**Report Actions**:

1. **Hide** - Hide content from users (reversible)
2. **Delete** - Permanently remove content
3. **Dismiss** - No action needed, mark as reviewed
4. **Ban User** - Ban the content creator

**Workflow**:

```
User reports → Admin reviews → Takes action → Updates status
```

**Best Practices**:

- Review reports promptly (within 24 hours)
- Document reasoning in admin notes
- Consider warning before banning
- Be consistent with enforcement

### Tab 2: Hidden Content

Shows all posts and comments hidden by admins.

**Features**:

- View hidden content details
- See who hid it and when
- Restore visibility if hidden in error
- Permanent delete option

**Use Cases**:

- Review borderline content
- Restore falsely reported content
- Decide between hide vs delete
- Audit moderation history

### Tab 3: Banned Users

Displays all user bans (active and expired).

**Ban Information**:

- Banned user name
- Banner admin name
- Ban reason
- Ban type (post, comment, all)
- Duration (permanent or temporary with expiry date)
- Status (active or inactive)

**Ban Management**:

- View all bans
- Filter by active status
- Unban users
- Review ban history

## Report Reasons

### Spam

- Repetitive or promotional content
- Bot-like behavior
- Irrelevant advertisements
- Multiple identical posts

**Action**: Usually hide or delete, ban for repeat offenders

### Inappropriate Content

- Offensive material
- Explicit content
- Violations of community guidelines
- Inappropriate for audience

**Action**: Hide or delete immediately, consider ban

### Harassment

- Bullying or threats
- Personal attacks
- Targeted abuse
- Hate speech

**Action**: Delete content, ban user (temporary or permanent)

### Other

- Custom reasons
- Edge cases
- Multiple violations
- Other concerns

**Action**: Review case-by-case

## Ban Types

### Post Ban

- User cannot create new posts
- Can still comment
- Can still react
- Existing posts remain visible

**Use Case**: User repeatedly posts inappropriate images

### Comment Ban

- User cannot add comments
- Can still create posts
- Can still react
- Existing comments remain visible

**Use Case**: User harasses others in comments

### All (Full Ban)

- User cannot post, comment, or react
- Essentially frozen account
- Can still view content
- Most severe action

**Use Case**: Severe or repeated violations

## Ban Durations

### Temporary Bans

**Duration Options**:

- 1-7 days: Minor violations
- 7-30 days: Moderate violations
- 30-90 days: Serious violations

**Auto-Expiry**:

- System automatically deactivates expired bans
- User regains access after expiry
- No manual intervention needed

**Best Practice**: Start with shorter bans, escalate for repeat offenders

### Permanent Bans

**When to Use**:

- Repeated violations after multiple bans
- Severe harassment or threats
- Illegal content
- Coordinated abuse

**Process**:

1. Document violation clearly
2. Review user's history
3. Consider warning first
4. Apply permanent ban with detailed reason
5. Notify user (if possible)

## Moderation Workflow

### Step 1: Receive Report

- User submits report via "Report" button
- Report appears in Reports tab with "pending" status
- You receive notification (future feature)

### Step 2: Review Content

- View the reported content
- Read report reason and details
- Check reporter's history (false reports?)
- Review content creator's history

### Step 3: Decide Action

**Decision Matrix**:

| Violation Severity       | First Offense     | Repeat Offense      |
| ------------------------ | ----------------- | ------------------- |
| Minor (spam)             | Dismiss or Hide   | Hide + Warning      |
| Moderate (inappropriate) | Hide or Delete    | Delete + 7-day ban  |
| Serious (harassment)     | Delete + Temp Ban | Delete + Longer ban |
| Severe (threats)         | Delete + Perm Ban | Delete + Perm Ban   |

### Step 4: Take Action

1. **If Dismissing**:

   - Tap "Dismiss"
   - Add admin notes explaining why
   - Report status → "dismissed"

2. **If Hiding**:

   - Tap "Hide"
   - Content hidden from users but recoverable
   - Report status → "resolved"
   - Admin note: "Content hidden"

3. **If Deleting**:

   - Tap "Delete"
   - Confirm deletion
   - Content permanently removed
   - Report status → "resolved"
   - Admin note: "Content deleted"

4. **If Banning**:
   - Tap "Ban User"
   - Select ban type (post, comment, all)
   - Choose duration or permanent
   - Provide clear reason
   - Confirm ban
   - Report status → "resolved"

### Step 5: Document

- Add comprehensive admin notes
- Document reasoning
- Note any context or history
- Track for future reference

## Community Guidelines (Example)

Create clear guidelines for users:

**Acceptable Content**:

- Personal photos and experiences
- Community events and activities
- Positive interactions and support
- Constructive discussions

**Prohibited Content**:

- Hate speech or discrimination
- Nudity or sexual content
- Violence or graphic imagery
- Personal information (doxxing)
- Spam or scams
- Harassment or bullying

**Consequences**:

- First violation: Warning or hide
- Second violation: Temporary ban (7-30 days)
- Third violation: Extended ban (30-90 days)
- Severe violations: Immediate permanent ban

## Appeals Process (Future Feature)

For now, banned users can contact admins directly:

1. User contacts admin via email/phone
2. Admin reviews ban and context
3. Admin decides to uphold or lift ban
4. Manual unban if appropriate

Future: In-app appeal system

## Moderation Best Practices

### Be Consistent

- Apply rules equally to all users
- Follow the decision matrix
- Document exceptions clearly

### Be Transparent

- Explain actions when possible
- Keep detailed admin notes
- Share community guidelines

### Be Fair

- Consider context and intent
- Allow for mistakes
- Escalate gradually (warning → ban)

### Be Responsive

- Review reports within 24 hours
- Address severe violations immediately
- Communicate with users when needed

### Be Collaborative

- Discuss unclear cases with other admins
- Share moderation insights
- Update guidelines based on learnings

## Reporting to Other Admins

If you need to escalate or discuss a case:

1. **Document**: Capture screenshots and details
2. **Discuss**: Contact fellow admins
3. **Decide**: Reach consensus on action
4. **Execute**: Apply decision consistently
5. **Follow-up**: Monitor user behavior after action

## Legal Considerations

### Content Removal

- You have the right to remove any content
- No guarantee of content preservation
- Users agree to terms of service

### User Bans

- Association reserves right to restrict access
- Bans are at discretion of admins
- No refunds or compensation

### Privacy

- Handle user data responsibly
- Don't share personal information
- Follow data protection regulations

### Illegal Content

If you encounter illegal content:

1. **Delete immediately**
2. **Ban user permanently**
3. **Report to authorities** if required
4. **Document incident** thoroughly
5. **Notify other admins**

## Metrics & Analytics (Future)

Track moderation effectiveness:

- Number of reports received
- Response time to reports
- Action taken distribution
- False report rate
- User ban appeal success rate
- Content violation trends

## Support

For moderation support:

- Contact lead admin
- Review community guidelines
- Refer to this guide
- Document and escalate unclear cases

## Updates

This guide will be updated as:

- New features are added
- Community guidelines evolve
- Best practices are refined
- Lessons are learned

---

**Last Updated**: 2025-01-19
**Version**: 1.0
**Next Review**: Monthly
