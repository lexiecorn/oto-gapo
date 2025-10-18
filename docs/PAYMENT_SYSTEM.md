# Payment System Documentation

## Overview

The Otogapo club application uses a modern payment tracking system based on `payment_transactions` in PocketBase. This system tracks monthly membership dues with explicit status fields, payment methods, and admin audit trails.

## Architecture

### Database Schema

**Collection:** `payment_transactions`

| Field            | Type     | Description                                               |
| ---------------- | -------- | --------------------------------------------------------- |
| `id`             | text     | Auto-generated unique identifier                          |
| `user`           | relation | Reference to users collection                             |
| `month`          | text     | Payment month in "YYYY-MM" format                         |
| `amount`         | number   | Payment amount (default: ₱100)                            |
| `status`         | select   | Payment status: `pending`, `paid`, or `waived`            |
| `payment_date`   | date     | Date when payment was made (if paid)                      |
| `payment_method` | select   | Method used: `cash`, `bank_transfer`, `gcash`, or `other` |
| `recorded_by`    | relation | Admin who recorded the payment                            |
| `notes`          | text     | Optional notes about the payment                          |
| `created`        | autodate | Record creation timestamp                                 |
| `updated`        | autodate | Record update timestamp                                   |

**Indexes:**

- Unique index on `(user, month)` prevents duplicate entries
- Index on `status` for faster filtering
- Index on `payment_date` for sorting

### Models

#### PaymentTransaction

Main model representing a payment record.

```dart
class PaymentTransaction {
  final String id;
  final String userId;
  final String month;              // "YYYY-MM"
  final double amount;
  final PaymentStatus status;      // pending, paid, waived
  final DateTime? paymentDate;
  final PaymentMethod? paymentMethod;
  final String? recordedBy;
  final String? notes;
  final DateTime created;
  final DateTime updated;

  // Computed properties
  bool get isPaid;
  bool get isPending;
  bool get isWaived;
  bool get isOverdue;
  DateTime get monthDate;
  String get paymentMethodDisplay;
}
```

#### PaymentStatistics

Aggregated payment data for a user.

```dart
class PaymentStatistics {
  final int totalMonths;          // Total months user should have paid
  final int paidCount;             // Number of paid months
  final int pendingCount;          // Number of pending months
  final int waivedCount;           // Number of waived months
  final int overdueCount;          // Number of overdue months
  final double totalPaidAmount;   // Total amount paid
  final double totalExpectedAmount; // Total amount expected
  final DateTime? lastPaymentDate;
  final String? lastPaymentMethod;

  // Computed
  double get paymentPercentage;
  bool get isUpToDate;
}
```

## Service Layer

### PocketBaseService Methods

All payment operations are handled through `PocketBaseService`:

```dart
// Get all transactions for a user
Future<List<PaymentTransaction>> getPaymentTransactions(String userId)

// Get specific month transaction
Future<PaymentTransaction?> getPaymentTransaction(String userId, String month)

// Create or update a transaction
Future<PaymentTransaction> updatePaymentTransaction({
  required String userId,
  required String month,
  required PaymentStatus status,
  DateTime? paymentDate,
  PaymentMethod? paymentMethod,
  String? notes,
  String? recordedBy,
})

// Delete a transaction
Future<void> deletePaymentTransaction(String transactionId)

// Get payment statistics
Future<PaymentStatistics> getPaymentStatistics(String userId)

// Get expected months from join date
List<String> getExpectedMonths(DateTime joinedDate)

// Initialize records for a user
Future<void> initializePaymentRecords(String userId, DateTime joinedDate)

// Get admin name for audit trail
Future<String> getRecordedByName(String? recordedById)
```

## User Interface

### For Members (PaymentStatusCardNew)

Users can view their payment history in the Settings page:

**Summary Card shows:**

- Total months and paid percentage
- Pending and overdue counts
- Total amount paid vs expected
- Last payment date and method

**Payment History shows:**

- Month-by-month list with expandable details
- Status badges (Paid/Pending/Overdue/Waived)
- Payment dates, methods, and amounts
- Admin notes
- Who recorded the payment
- Last update timestamp

**Features:**

- Filter by status (All/Paid/Pending/Overdue)
- Pull to refresh
- Color-coded status indicators
- Expandable tiles for details

### For Admins (PaymentManagementPageNew)

Admins can manage all payments from the Admin Panel:

**Controls:**

- Month selector
- User search (by name or member number)
- Status filter (All/Paid/Pending/Overdue)

**Summary:**

- Total members
- Paid/Pending/Overdue counts for selected month

**User List:**

- Shows all members with payment status for selected month
- Tap user to open payment dialog

**Payment Dialog:**

- Select payment method
- Add notes
- Actions:
  - Mark as Paid
  - Mark as Unpaid
  - Waive payment
  - Cancel

## Usage Examples

### Recording a Payment (Admin)

1. Open Admin Panel → Payment Management
2. Select the month (e.g., "October 2025")
3. Tap on a user's card
4. In the dialog:
   - Select payment method (Cash, Bank Transfer, GCash, Other)
   - Add notes if needed (optional)
   - Tap "Mark Paid"
5. Payment is recorded with your admin ID and timestamp

### Viewing Payment History (User)

1. Open Settings page
2. Scroll to "Payment Summary" section
3. View summary statistics
4. Tap on filter chips to filter by status
5. Tap on any month tile to expand and see:
   - Payment date
   - Payment method
   - Admin notes
   - Who recorded it
   - Last update time

### Bulk Operations (Admin)

1. From Payment Management page
2. Use search to find specific users
3. Use filters to show only pending/overdue
4. Process payments one by one

## API Rules (PocketBase)

```javascript
// List Rule - Users can view their own, admins can view all
@request.auth.id != "" && (user = @request.auth.id || @request.auth.isAdmin = true)

// View Rule - Same as List
@request.auth.id != "" && (user = @request.auth.id || @request.auth.isAdmin = true)

// Create Rule - Only admins
@request.auth.id != "" && @request.auth.isAdmin = true

// Update Rule - Only admins
@request.auth.id != "" && @request.auth.isAdmin = true

// Delete Rule - Only admins
@request.auth.id != "" && @request.auth.isAdmin = true
```

## Payment Flow

### 1. User Joins Club

- Admin creates user account with `joinedDate`
- System can optionally initialize payment records for all expected months

### 2. Monthly Payment Recording

- Member pays dues (cash, bank transfer, GCash, etc.)
- Admin opens Payment Management
- Selects the month
- Finds the member
- Records payment with method and optional notes
- System creates/updates `payment_transactions` record with:
  - Status: `paid`
  - Payment date: current date
  - Payment method: selected method
  - Recorded by: admin's user ID
  - Timestamp: automatic

### 3. Member Views History

- Opens Settings page
- Sees summary of all payments
- Can filter and view details
- Sees who recorded each payment (transparency)

### 4. Overdue Detection

- System automatically calculates overdue status
- Payment is overdue if:
  - Status is `pending`
  - Month is before current month
- Shows in red in UI

## Migration from Old System

The old `monthly_dues` collection used `payment_date` presence to infer status. This caused issues:

- Creating/deleting records for status changes created duplicates
- No explicit status field
- No audit trail
- No payment methods

The new system is starting fresh with clean data structure.

## Best Practices

### For Admins

1. **Record payments promptly** - Enter payments same day or next day
2. **Use correct payment method** - Helps with financial tracking
3. **Add notes for special cases** - Document exceptions, partial payments, etc.
4. **Verify before marking paid** - Confirm payment received
5. **Use waived status appropriately** - Only for legitimate waivers

### For Developers

1. **Always use PocketBaseService** - Don't access collection directly
2. **Handle null transactions** - User might not have record yet
3. **Respect API rules** - Don't bypass security
4. **Use typed enums** - `PaymentStatus`, `PaymentMethod`
5. **Include recordedBy** - Maintain audit trail

## Troubleshooting

### User's payments not showing

- Check user's `joinedDate` is set
- Verify user ID matches between auth and PocketBase
- Check API rules allow user to view their records

### Can't record payment

- Verify admin user has `isAdmin = true`
- Check PocketBase connection
- Verify month format is "YYYY-MM"

### Duplicate records

- Should not happen due to unique index on `(user, month)`
- If occurs, check PocketBase schema has unique index

### Payment statistics wrong

- Verify `joinedDate` is accurate
- Check all transactions are properly created
- Verify status field values are correct

## Future Enhancements

Potential features for future versions:

- Payment receipts (PDF generation)
- Payment reminders (push notifications)
- Multiple payment tiers (different membership levels)
- Partial payments tracking
- Payment history export (CSV/Excel)
- QR code payments integration
- Automatic payment tracking from bank integration
- SMS notifications for overdue payments
- Payment dashboard with analytics

## Support

For issues or questions:

1. Check this documentation first
2. Review PocketBase collection schema
3. Check admin API rules
4. Verify user permissions
5. Contact system administrator

## Code References

- Models: `lib/models/payment_transaction.dart`, `lib/models/payment_statistics.dart`
- Service: `lib/services/pocketbase_service.dart`
- Admin UI: `lib/app/pages/payment_management_page_new.dart`
- User UI: `lib/app/widgets/payment_status_card_new.dart`
- Old (deprecated): `lib/models/monthly_dues.dart`, `lib/app/pages/payment_management_page.dart`
