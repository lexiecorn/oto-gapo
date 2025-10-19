part of 'moderation_cubit.dart';

/// Status of moderation
enum ModerationStatus {
  initial,
  loading,
  loaded,
  error,
}

/// State for moderation
class ModerationState extends Equatable {
  const ModerationState({
    this.status = ModerationStatus.initial,
    this.reports = const [],
    this.bans = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.errorMessage,
    this.selectedReportStatus,
  });

  final ModerationStatus status;
  final List<PostReport> reports;
  final List<UserBan> bans;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;
  final ReportStatus? selectedReportStatus;

  ModerationState copyWith({
    ModerationStatus? status,
    List<PostReport>? reports,
    List<UserBan>? bans,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
    ReportStatus? selectedReportStatus,
  }) {
    return ModerationState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      bans: bans ?? this.bans,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedReportStatus: selectedReportStatus ?? this.selectedReportStatus,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reports,
        bans,
        currentPage,
        hasMore,
        errorMessage,
        selectedReportStatus,
      ];
}
