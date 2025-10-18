# Attendance System - Database Schema

## 📊 Overview

This document defines the Firestore database schema for the attendance management system.

## 🗂️ Collection Structure

### Option 1: Recommended Approach (Meeting-Centric)

```
meetings/{meetingId}
  - meetingDate: Timestamp
  - meetingType: String (regular, special, emergency)
  - title: String
  - location: String
  - startTime: Timestamp
  - endTime: Timestamp
  - status: String (scheduled, ongoing, completed, cancelled)
  - createdBy: String (admin uid)
  - createdAt: Timestamp
  - updatedAt: Timestamp
  - qrCodeEnabled: Boolean
  - qrCodeExpiry: Timestamp (for security - expires after meeting)

  attendance_records/{recordId}
    - userId: String (user uid)
    - memberNumber: String
    - memberName: String (cached for quick display)
    - status: String (present, absent, late, excused, leave)
    - checkInTime: Timestamp
    - checkInMethod: String (manual, qr_scan, auto)
    - markedBy: String (admin uid who marked it)
    - notes: String (optional, for excused/leave reasons)
    - createdAt: Timestamp
    - updatedAt: Timestamp
```

**Pros:**

- Natural grouping by meeting/event
- Easy to get all attendees for a specific meeting
- Good for meeting reports and summaries
- QR code scanning ties directly to meeting

**Cons:**

- Querying a single user's attendance history requires collection group query

---

### Option 2: User-Centric Approach

```
users/{userId}
  attendance_records/{recordId}
    - meetingId: String (reference to meeting)
    - meetingDate: Timestamp
    - meetingTitle: String (cached)
    - status: String (present, absent, late, excused, leave)
    - checkInTime: Timestamp
    - checkInMethod: String (manual, qr_scan, auto)
    - markedBy: String (admin uid)
    - notes: String
    - createdAt: Timestamp
    - updatedAt: Timestamp

meetings/{meetingId}
  - meetingDate: Timestamp
  - meetingType: String
  - title: String
  - location: String
  - startTime: Timestamp
  - endTime: Timestamp
  - status: String
  - createdBy: String
  - createdAt: Timestamp
  - updatedAt: Timestamp
  - totalMembers: Number
  - presentCount: Number
  - absentCount: Number
  - lateCount: Number
```

**Pros:**

- Fast queries for individual user attendance history
- Similar pattern to your existing `monthly_dues` subcollection
- Easy permission rules per user

**Cons:**

- Harder to get all attendees for a meeting (need to query all users)
- Need to maintain counts in meetings collection

---

### Option 3: Hybrid Approach (RECOMMENDED) ⭐

```
meetings/{meetingId}
  - meetingDate: Timestamp
  - meetingType: String (regular, special, emergency)
  - title: String
  - location: String
  - startTime: Timestamp
  - endTime: Timestamp
  - status: String (scheduled, ongoing, completed, cancelled)
  - createdBy: String
  - createdAt: Timestamp
  - updatedAt: Timestamp
  - qrCodeToken: String (unique token for QR scanning)
  - qrCodeExpiry: Timestamp
  - totalExpectedMembers: Number
  - presentCount: Number
  - absentCount: Number
  - lateCount: Number
  - excusedCount: Number

attendance/{userId_meetingId} (composite document ID)
  - userId: String
  - memberNumber: String
  - memberName: String
  - profileImage: String
  - meetingId: String
  - meetingDate: Timestamp
  - meetingTitle: String
  - status: String (present, absent, late, excused, leave)
  - checkInTime: Timestamp
  - checkInMethod: String (manual, qr_scan, auto)
  - markedBy: String
  - notes: String
  - createdAt: Timestamp
  - updatedAt: Timestamp

users/{userId}
  attendance_summary
    - totalMeetings: Number
    - totalPresent: Number
    - totalAbsent: Number
    - totalLate: Number
    - totalExcused: Number
    - attendanceRate: Number (percentage)
    - lastUpdated: Timestamp
```

**Pros:**

- ✅ Fast queries for both meeting attendance and user history
- ✅ Single attendance document prevents duplicates
- ✅ Can query by userId, meetingId, or date efficiently
- ✅ Summary stats for quick dashboard display
- ✅ Works well with QR scanning

**Cons:**

- Slight complexity in maintaining summary stats

---

## 🎯 Recommended: Option 3 (Hybrid)

### Firestore Queries

```dart
// Get all attendance for a specific meeting
db.collection('attendance')
  .where('meetingId', isEqualTo: meetingId)
  .orderBy('memberName')
  .get();

// Get user's attendance history
db.collection('attendance')
  .where('userId', isEqualTo: userId)
  .orderBy('meetingDate', descending: true)
  .get();

// Get attendance for a date range
db.collection('attendance')
  .where('userId', isEqualTo: userId)
  .where('meetingDate', isGreaterThanOrEqualTo: startDate)
  .where('meetingDate', isLessThanOrEqualTo: endDate)
  .get();

// Get all meetings for a month
db.collection('meetings')
  .where('meetingDate', isGreaterThanOrEqualTo: monthStart)
  .where('meetingDate', isLessThanOrEqualTo: monthEnd)
  .orderBy('meetingDate', descending: true)
  .get();

// QR Code validation
db.collection('meetings')
  .where('qrCodeToken', isEqualTo: token)
  .where('qrCodeExpiry', isGreaterThan: now)
  .where('status', isEqualTo: 'ongoing')
  .limit(1)
  .get();
```

### Document ID Format

```dart
// attendance/{userId}_{meetingId}
// Example: attendance/abc123_meet456
String attendanceId = '${userId}_${meetingId}';
```

---

## 📝 Status Values

### Attendance Status

- `present` - Attended on time
- `late` - Attended but late
- `absent` - Did not attend (no excuse)
- `excused` - Absent with valid excuse
- `leave` - Pre-approved leave

### Meeting Status

- `scheduled` - Meeting planned
- `ongoing` - Meeting in progress (QR active)
- `completed` - Meeting finished
- `cancelled` - Meeting cancelled

### Check-in Methods

- `manual` - Admin marked manually
- `qr_scan` - User scanned QR code
- `auto` - System auto-marked (e.g., all absent after meeting)

---

## 🔒 Security Considerations

1. **QR Token Security**

   - Generate unique token per meeting
   - Set expiry time (meeting end + buffer)
   - Validate token hasn't been used by same user

2. **Attendance Records**

   - Only admins can mark attendance
   - Users can only view their own records
   - Prevent duplicate check-ins

3. **Meeting Records**
   - Only super admins can create/edit meetings
   - All members can view scheduled meetings

---

## 📊 Example Data

### Meeting Document

```json
{
  "meetingId": "meet_20250118_001",
  "meetingDate": "2025-01-18T14:00:00Z",
  "meetingType": "regular",
  "title": "Monthly General Assembly",
  "location": "Main Hall",
  "startTime": "2025-01-18T14:00:00Z",
  "endTime": "2025-01-18T16:00:00Z",
  "status": "ongoing",
  "createdBy": "admin_uid_123",
  "qrCodeToken": "qr_xYz789AbC",
  "qrCodeExpiry": "2025-01-18T17:00:00Z",
  "totalExpectedMembers": 50,
  "presentCount": 42,
  "absentCount": 6,
  "lateCount": 2
}
```

### Attendance Document

```json
{
  "userId": "user_uid_456",
  "memberNumber": "OTO-2024-042",
  "memberName": "Juan Dela Cruz",
  "profileImage": "https://...",
  "meetingId": "meet_20250118_001",
  "meetingDate": "2025-01-18T14:00:00Z",
  "meetingTitle": "Monthly General Assembly",
  "status": "present",
  "checkInTime": "2025-01-18T14:05:32Z",
  "checkInMethod": "qr_scan",
  "markedBy": "user_uid_456",
  "notes": "",
  "createdAt": "2025-01-18T14:05:32Z",
  "updatedAt": "2025-01-18T14:05:32Z"
}
```

### User Attendance Summary

```json
{
  "totalMeetings": 24,
  "totalPresent": 20,
  "totalAbsent": 2,
  "totalLate": 2,
  "totalExcused": 0,
  "attendanceRate": 91.67,
  "lastUpdated": "2025-01-18T16:00:00Z"
}
```

---

## 🔄 Workflow Examples

### 1. Create Meeting & Initialize Attendance

```dart
1. Admin creates meeting document
2. Generate unique QR token
3. System auto-creates attendance records for all active members
   - Status: "absent" (default)
   - Can be updated when members check in
```

### 2. QR Code Check-in

```dart
1. User scans QR code
2. Validate token & meeting status
3. Check if user already checked in
4. Update attendance/{userId_meetingId}:
   - status: "present" or "late"
   - checkInTime: now
   - checkInMethod: "qr_scan"
5. Update meeting presentCount/lateCount
```

### 3. Manual Marking by Admin

```dart
1. Admin views meeting attendance list
2. Marks member status
3. Update attendance/{userId_meetingId}
4. Update meeting counts
```

### 4. Generate Reports

```dart
// Monthly Report
1. Query all meetings in month
2. For each meeting, get attendance records
3. Calculate totals, percentages
4. Export to CSV

// Member Report
1. Query attendance where userId = X
2. Group by month/year
3. Calculate attendance rate
```

---

## 📈 Performance Optimization

### Indexes Required (firestore.indexes.json)

```json
{
  "indexes": [
    {
      "collectionGroup": "attendance",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "meetingId", "order": "ASCENDING" },
        { "fieldPath": "memberName", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "attendance",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "meetingDate", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "meetings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "meetingDate", "order": "DESCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" }
      ]
    }
  ]
}
```

### Caching Strategy

- Cache user names/profile images in attendance records
- Cache meeting titles in attendance records
- Maintain summary counts to avoid aggregation queries

---

## 🎯 Next Steps

1. Review this schema with your team
2. Create Firestore indexes
3. Update security rules
4. Create Dart models matching this schema
5. Implement repository layer
6. Build UI components

---

**Questions to Consider:**

- Do you need different attendance types for different meeting types?
- Should excused absences require proof/documentation upload?
- Do you want to track partial attendance (e.g., left early)?
- Should there be a grace period for "late" vs "present"?
