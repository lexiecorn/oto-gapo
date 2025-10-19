import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:otogapo/models/post_report.dart';
import 'package:otogapo/models/user_ban.dart';
import 'package:otogapo/services/pocketbase_service.dart';

part 'moderation_state.dart';

/// Cubit for managing moderation features (admin only)
class ModerationCubit extends Cubit<ModerationState> {
  ModerationCubit({
    required this.pocketBaseService,
    required this.currentUserId,
  }) : super(const ModerationState());

  final PocketBaseService pocketBaseService;
  final String currentUserId;

  /// Load reports
  Future<void> loadReports({
    ReportStatus? status,
    int page = 1,
  }) async {
    try {
      if (page == 1) {
        emit(
          state.copyWith(
            status: ModerationStatus.loading,
            selectedReportStatus: status,
          ),
        );
      }

      final result = await pocketBaseService.getReports(
        status: status?.value,
        page: page,
        perPage: 20,
      );

      final reports = result.items.map((record) => PostReport.fromRecord(record)).toList();

      if (page == 1) {
        emit(
          state.copyWith(
            status: ModerationStatus.loaded,
            reports: reports,
            currentPage: page,
            hasMore: result.page < result.totalPages,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ModerationStatus.loaded,
            reports: [...state.reports, ...reports],
            currentPage: page,
            hasMore: result.page < result.totalPages,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ModerationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Review a report
  Future<void> reviewReport(
    String reportId,
    ReportStatus status,
    String notes,
  ) async {
    try {
      final record = await pocketBaseService.updateReportStatus(
        reportId: reportId,
        status: status.value,
        reviewedBy: currentUserId,
        adminNotes: notes,
      );

      final updatedReport = PostReport.fromRecord(record);

      // Update in list
      final reportIndex = state.reports.indexWhere((r) => r.id == reportId);
      if (reportIndex != -1) {
        final updatedReports = List<PostReport>.from(state.reports);
        updatedReports[reportIndex] = updatedReport;

        emit(state.copyWith(reports: updatedReports));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ModerationStatus.error,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  /// Hide or unhide a post
  Future<void> togglePostVisibility(String postId, bool hide) async {
    try {
      await pocketBaseService.hidePost(postId, hide);
    } catch (e) {
      emit(
        state.copyWith(
          status: ModerationStatus.error,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  /// Hide or unhide a comment
  Future<void> toggleCommentVisibility(String commentId, bool hide) async {
    try {
      await pocketBaseService.hideComment(commentId, hide);
    } catch (e) {
      emit(
        state.copyWith(
          status: ModerationStatus.error,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  /// Ban a user
  Future<void> banUser(
    String userId,
    String reason,
    BanType type,
    Duration? duration,
  ) async {
    try {
      final isPermanent = duration == null;
      final expiresAt = isPermanent ? null : DateTime.now().add(duration);

      final record = await pocketBaseService.banUser(
        userId: userId,
        bannedBy: currentUserId,
        banReason: reason,
        banType: type.value,
        isPermanent: isPermanent,
        banExpiresAt: expiresAt,
      );

      final newBan = UserBan.fromRecord(record);

      // Add to bans list
      emit(
        state.copyWith(
          bans: [newBan, ...state.bans],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ModerationStatus.error,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  /// Unban a user
  Future<void> unbanUser(String userId) async {
    try {
      await pocketBaseService.unbanUser(userId);

      // Update bans list
      final updatedBans = state.bans.map((ban) {
        if (ban.userId == userId && ban.isActive) {
          return ban.copyWith(isActive: false);
        }
        return ban;
      }).toList();

      emit(state.copyWith(bans: updatedBans));
    } catch (e) {
      emit(
        state.copyWith(
          status: ModerationStatus.error,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  /// Load all bans
  Future<void> loadBans({
    bool? isActive,
    int page = 1,
  }) async {
    try {
      if (page == 1) {
        emit(state.copyWith(status: ModerationStatus.loading));
      }

      final result = await pocketBaseService.getAllBans(
        isActive: isActive,
        page: page,
        perPage: 20,
      );

      final bans = result.items.map((record) => UserBan.fromRecord(record)).toList();

      if (page == 1) {
        emit(
          state.copyWith(
            status: ModerationStatus.loaded,
            bans: bans,
            currentPage: page,
            hasMore: result.page < result.totalPages,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ModerationStatus.loaded,
            bans: [...state.bans, ...bans],
            currentPage: page,
            hasMore: result.page < result.totalPages,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ModerationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Load user ban history
  Future<void> loadUserBans(String userId) async {
    try {
      emit(state.copyWith(status: ModerationStatus.loading));

      final bans = await pocketBaseService.getUserBans(userId);
      final userBans = bans.map((record) => UserBan.fromRecord(record)).toList();

      emit(
        state.copyWith(
          status: ModerationStatus.loaded,
          bans: userBans,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ModerationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Refresh reports
  Future<void> refreshReports() async {
    await loadReports(status: state.selectedReportStatus, page: 1);
  }

  /// Refresh bans
  Future<void> refreshBans() async {
    await loadBans(page: 1);
  }
}
