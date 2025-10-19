import 'package:pocketbase/pocketbase.dart';

/// Enum for report reasons
enum ReportReason {
  spam('spam', 'Spam'),
  inappropriate('inappropriate', 'Inappropriate Content'),
  harassment('harassment', 'Harassment'),
  other('other', 'Other');

  const ReportReason(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Get ReportReason from string value
  static ReportReason fromValue(String value) {
    return ReportReason.values.firstWhere(
      (reason) => reason.value == value,
      orElse: () => ReportReason.other,
    );
  }
}

/// Enum for report status
enum ReportStatus {
  pending('pending', 'Pending'),
  reviewed('reviewed', 'Reviewed'),
  resolved('resolved', 'Resolved'),
  dismissed('dismissed', 'Dismissed');

  const ReportStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Get ReportStatus from string value
  static ReportStatus fromValue(String value) {
    return ReportStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReportStatus.pending,
    );
  }
}

/// Represents a report of inappropriate content
class PostReport {
  const PostReport({
    required this.id,
    this.postId,
    this.commentId,
    required this.reportedBy,
    required this.reporterName,
    required this.reportReason,
    this.reportDetails,
    required this.status,
    this.reviewedBy,
    this.reviewerName,
    this.reviewedAt,
    this.adminNotes,
    required this.createdAt,
  });

  final String id;
  final String? postId;
  final String? commentId;
  final String reportedBy;
  final String reporterName;
  final ReportReason reportReason;
  final String? reportDetails;
  final ReportStatus status;
  final String? reviewedBy;
  final String? reviewerName;
  final DateTime? reviewedAt;
  final String? adminNotes;
  final DateTime createdAt;

  /// Whether the report is for a post
  bool get isPostReport => postId != null;

  /// Whether the report is for a comment
  bool get isCommentReport => commentId != null;

  /// Factory constructor to create a PostReport from PocketBase RecordModel
  factory PostReport.fromRecord(RecordModel record) {
    final data = record.data;

    // Extract reporter info from expanded relation
    var reporterName = 'Unknown User';
    try {
      final reporterRecord = record.get<RecordModel?>('expand.reported_by');
      if (reporterRecord != null) {
        final firstName = reporterRecord.data['firstName'] as String? ?? '';
        final lastName = reporterRecord.data['lastName'] as String? ?? '';
        reporterName = '$firstName $lastName'.trim();
      }
    } catch (e) {
      // Expand not available, use default values
    }

    // Extract reviewer info from expanded relation
    String? reviewerName;
    try {
      final reviewerRecord = record.get<RecordModel?>('expand.reviewed_by');
      if (reviewerRecord != null) {
        final firstName = reviewerRecord.data['firstName'] as String? ?? '';
        final lastName = reviewerRecord.data['lastName'] as String? ?? '';
        reviewerName = '$firstName $lastName'.trim();
      }
    } catch (e) {
      // Expand not available, reviewer name remains null
    }

    final reasonValue = data['report_reason'] as String? ?? 'other';
    final statusValue = data['status'] as String? ?? 'pending';

    DateTime? reviewedAt;
    if (data['reviewed_at'] != null && data['reviewed_at'] != '') {
      try {
        reviewedAt = DateTime.parse(data['reviewed_at'] as String);
      } catch (_) {
        reviewedAt = null;
      }
    }

    return PostReport(
      id: record.id,
      postId: data['post_id'] as String?,
      commentId: data['comment_id'] as String?,
      reportedBy: data['reported_by'] as String? ?? '',
      reporterName: reporterName,
      reportReason: ReportReason.fromValue(reasonValue),
      reportDetails: data['report_details'] as String?,
      status: ReportStatus.fromValue(statusValue),
      reviewedBy: data['reviewed_by'] as String?,
      reviewerName: reviewerName,
      reviewedAt: reviewedAt,
      adminNotes: data['admin_notes'] as String?,
      createdAt: DateTime.parse(record.get<String>('created')),
    );
  }

  /// Copy with method for creating modified copies
  PostReport copyWith({
    String? id,
    String? postId,
    String? commentId,
    String? reportedBy,
    String? reporterName,
    ReportReason? reportReason,
    String? reportDetails,
    ReportStatus? status,
    String? reviewedBy,
    String? reviewerName,
    DateTime? reviewedAt,
    String? adminNotes,
    DateTime? createdAt,
  }) {
    return PostReport(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      reportedBy: reportedBy ?? this.reportedBy,
      reporterName: reporterName ?? this.reporterName,
      reportReason: reportReason ?? this.reportReason,
      reportDetails: reportDetails ?? this.reportDetails,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostReport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PostReport(id: $id, reason: ${reportReason.value}, status: ${status.value})';
  }
}
