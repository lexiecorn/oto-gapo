# PocketBase Attendance Setup - Manual Creation Guide

## 📋 Overview

Follow these steps to manually create attendance tables in PocketBase Dashboard.

---

## 🚀 Collection 1: `meetings`

### Create Collection

1. Click **New Collection** button
2. Collection name: `meetings`
3. Collection type: **Base collection**
4. Click **Create**

### Add Fields (Click "+ New field" for each)

| #   | Field Name           | Type           | Required | Options                                                              |
| --- | -------------------- | -------------- | -------- | -------------------------------------------------------------------- |
| 1   | meetingDate          | **Date**       | ✅ Yes   | -                                                                    |
| 2   | meetingType          | **Select**     | ✅ Yes   | Values: `regular`, `gmm`, `special`, `emergency` (one per line)      |
| 3   | title                | **Plain text** | ✅ Yes   | Min: 1, Max: 200                                                     |
| 4   | location             | **Plain text** | ❌ No    | Max: 200                                                             |
| 5   | startTime            | **Date**       | ❌ No    | -                                                                    |
| 6   | endTime              | **Date**       | ❌ No    | -                                                                    |
| 7   | status               | **Select**     | ✅ Yes   | Values: `scheduled`, `ongoing`, `completed`, `cancelled`             |
| 8   | createdBy            | **Relation**   | ✅ Yes   | Collection: `users`, Single, Display fields: `firstName`, `lastName` |
| 9   | qrCodeToken          | **Plain text** | ❌ No    | Max: 100                                                             |
| 10  | qrCodeExpiry         | **Date**       | ❌ No    | -                                                                    |
| 11  | totalExpectedMembers | **Number**     | ❌ No    | Min: 0                                                               |
| 12  | presentCount         | **Number**     | ❌ No    | Min: 0                                                               |
| 13  | absentCount          | **Number**     | ❌ No    | Min: 0                                                               |
| 14  | lateCount            | **Number**     | ❌ No    | Min: 0                                                               |
| 15  | excusedCount         | **Number**     | ❌ No    | Min: 0                                                               |
| 16  | description          | **Plain text** | ❌ No    | Max: 1000                                                            |

### API Rules (in Collection settings > API Rules tab)

```
List rule:
@request.auth.id != ""

View rule:
@request.auth.id != ""

Create rule:
@request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2

Update rule:
@request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2

Delete rule:
@request.auth.membership_type = 1
```

---

## 🚀 Collection 2: `attendance`

### Create Collection

1. Click **New Collection** button
2. Collection name: `attendance`
3. Collection type: **Base collection**
4. Click **Create**

### Add Fields (Click "+ New field" for each)

| #   | Field Name    | Type           | Required | Options                                                                              |
| --- | ------------- | -------------- | -------- | ------------------------------------------------------------------------------------ |
| 1   | userId        | **Relation**   | ✅ Yes   | Collection: `users`, Single, Display fields: `firstName`, `lastName`, `memberNumber` |
| 2   | memberNumber  | **Plain text** | ✅ Yes   | Max: 50                                                                              |
| 3   | memberName    | **Plain text** | ✅ Yes   | Max: 200                                                                             |
| 4   | profileImage  | **URL**        | ❌ No    | -                                                                                    |
| 5   | meetingId     | **Relation**   | ✅ Yes   | Collection: `meetings`, Single, Display fields: `title`, `meetingDate`               |
| 6   | meetingDate   | **Date**       | ✅ Yes   | -                                                                                    |
| 7   | meetingTitle  | **Plain text** | ✅ Yes   | Max: 200                                                                             |
| 8   | status        | **Select**     | ✅ Yes   | Values: `present`, `late`, `absent`, `excused`, `leave`                              |
| 9   | checkInTime   | **Date**       | ❌ No    | -                                                                                    |
| 10  | checkInMethod | **Select**     | ❌ No    | Values: `manual`, `qr_scan`, `auto`                                                  |
| 11  | markedBy      | **Relation**   | ❌ No    | Collection: `users`, Single, Display fields: `firstName`, `lastName`                 |
| 12  | notes         | **Plain text** | ❌ No    | Max: 500                                                                             |

### API Rules (in Collection settings > API Rules tab)

```
List rule:
@request.auth.id != "" && (@request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2 || userId = @request.auth.id)

View rule:
@request.auth.id != "" && (@request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2 || userId = @request.auth.id)

Create rule:
@request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2 || (userId = @request.auth.id && checkInMethod = "qr_scan")

Update rule:
@request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2

Delete rule:
@request.auth.membership_type = 1
```

### Add Unique Index (IMPORTANT!)

1. Go to collection settings
2. Click **Indexes** tab
3. Add index:
   ```
   CREATE UNIQUE INDEX idx_attendance_unique ON attendance (userId, meetingId)
   ```
4. This prevents duplicate attendance records!

---

## 🚀 Collection 3: `attendance_summary`

### Create Collection

1. Click **New Collection** button
2. Collection name: `attendance_summary`
3. Collection type: **Base collection**
4. Click **Create**

### Add Fields (Click "+ New field" for each)

| #   | Field Name     | Type         | Required | Options                                                                              |
| --- | -------------- | ------------ | -------- | ------------------------------------------------------------------------------------ |
| 1   | userId         | **Relation** | ✅ Yes   | Collection: `users`, Single, Display fields: `firstName`, `lastName`, `memberNumber` |
| 2   | totalMeetings  | **Number**   | ❌ No    | Min: 0, Default: 0                                                                   |
| 3   | totalPresent   | **Number**   | ❌ No    | Min: 0, Default: 0                                                                   |
| 4   | totalAbsent    | **Number**   | ❌ No    | Min: 0, Default: 0                                                                   |
| 5   | totalLate      | **Number**   | ❌ No    | Min: 0, Default: 0                                                                   |
| 6   | totalExcused   | **Number**   | ❌ No    | Min: 0, Default: 0                                                                   |
| 7   | attendanceRate | **Number**   | ❌ No    | Min: 0, Max: 100, Default: 0                                                         |

### API Rules (in Collection settings > API Rules tab)

```
List rule:
@request.auth.id != "" && (@request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2 || userId = @request.auth.id)

View rule:
@request.auth.id != "" && (@request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2 || userId = @request.auth.id)

Create rule:
@request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2

Update rule:
@request.auth.isAdmin = true || @request.auth.membership_type = 1 || @request.auth.membership_type = 2

Delete rule:
@request.auth.membership_type = 1
```

### Add Unique Index

1. Go to collection settings
2. Click **Indexes** tab
3. Add index:
   ```
   CREATE UNIQUE INDEX idx_attendance_summary_user ON attendance_summary (userId)
   ```

---

## ✅ Verification

After creating all 3 collections, verify:

- [ ] `meetings` collection has 16 fields
- [ ] `attendance` collection has 12 fields + unique index
- [ ] `attendance_summary` collection has 7 fields + unique index
- [ ] All API rules are set correctly
- [ ] All relation fields point to correct collections

---

## 🧪 Quick Test

### Test 1: Create a Meeting

1. Go to `meetings` collection
2. Click **New record**
3. Fill in:
   - meetingDate: Pick a date
   - meetingType: `regular`
   - title: `Test Meeting`
   - startTime: Pick date & time
   - status: `scheduled`
   - createdBy: Select your user
   - presentCount: 0
   - absentCount: 0
4. Save

### Test 2: Create Attendance Record

1. Go to `attendance` collection
2. Click **New record**
3. Fill in:
   - userId: Select a user
   - memberNumber: User's member number
   - memberName: User's full name
   - meetingId: Select the test meeting
   - meetingDate: Same as meeting date
   - meetingTitle: `Test Meeting`
   - status: `present`
   - checkInMethod: `manual`
4. Save

### Test 3: Create Summary

1. Go to `attendance_summary` collection
2. Click **New record**
3. Fill in:
   - userId: Select same user
   - totalMeetings: 1
   - totalPresent: 1
   - attendanceRate: 100
4. Save

---

## 📝 Field Type Quick Reference

When adding fields in PocketBase:

- **Plain text** = Short text (for names, titles)
- **Date** = Date/time picker
- **Number** = Integer or decimal numbers
- **Select** = Dropdown with predefined values (type one value per line)
- **Relation** = Link to another collection
- **URL** = Text that validates as URL

---

## 🎯 Common Issues

### Issue: Can't find relation collection

- Make sure you created `meetings` collection BEFORE `attendance`
- Make sure your `users` collection exists

### Issue: Can't create duplicate attendance

- This is CORRECT! The unique index prevents duplicate check-ins
- Each user can only have ONE attendance record per meeting

### Issue: API rules not working

- Double-check you copy-pasted the rules exactly
- Make sure there are no extra spaces or line breaks

---

## 🎉 Done!

You now have:

- ✅ **meetings** - Store meeting information
- ✅ **attendance** - Track who attended each meeting
- ✅ **attendance_summary** - Quick stats for each user

Next steps:

1. Create Dart models to match these collections
2. Build repository layer to interact with PocketBase API
3. Create UI screens for attendance management
4. Implement QR code scanning

---

## 📖 Reference: Schema Design

For detailed explanation of why this schema works, see:

- `docs/ATTENDANCE_SCHEMA.md` - Detailed schema design document
