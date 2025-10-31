import 'package:attendance_repository/attendance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:otogapo/models/cached_data.dart';
import 'package:otogapo/models/meeting.dart';
import 'package:otogapo/models/meeting.dart' as meeting_models;
import 'package:otogapo/services/sync_service.dart';

part 'meeting_state.dart';

class MeetingCubit extends Cubit<MeetingState> {
  MeetingCubit({
    required this.attendanceRepository,
    required this.syncService,
  }) : super(MeetingState.initial());

  final AttendanceRepository attendanceRepository;
  final SyncService syncService;

  /// Load all meetings
  Future<void> loadMeetings({
    int page = 1,
    String? filter,
  }) async {
    // For first page without filters, try loading from cache first
    if (page == 1 && filter == null) {
      final cachedMeetings = await syncService.getCachedMeetingsIfValid();
      if (cachedMeetings != null && cachedMeetings.isNotEmpty) {
        // Emit cached data immediately for instant UI
        final meetings = cachedMeetings.map((cached) {
          // Find the matching MeetingModelStatus by value
          meeting_models.MeetingStatus meetingModelStatus =
              meeting_models.MeetingStatus.values.firstWhere(
            (meeting_models.MeetingStatus s) => s.value == cached.status,
            orElse: () => meeting_models.MeetingStatus.scheduled,
          );

          return meeting_models.Meeting(
            id: cached.id,
            meetingDate: cached.meetingDate,
            meetingType: meeting_models.MeetingType.regular, // Default type
            title: cached.title,
            location: cached.location,
            status: meetingModelStatus,
            createdBy: 'unknown',
            presentCount: cached.presentCount,
            absentCount: cached.absentCount,
            lateCount: 0,
            excusedCount: 0,
            description: cached.description,
            created: cached.cachedAt,
            updated: cached.cachedAt,
          );
        }).toList();

        emit(
          state.copyWith(
            status: MeetingStatus.loaded,
            meetings: meetings,
            hasMore: false,
            currentPage: 1,
          ),
        );
      }
    }

    if (page == 1) {
      emit(state.copyWith(status: MeetingStatus.loading));
    }

    try {
      final result = await attendanceRepository.getMeetings(
        page: page,
        filter: filter,
      );

      final meetings = result.items.map(Meeting.fromRecord).toList();

      // Cache the results if it's first page without filters
      if (page == 1 && filter == null) {
        final cachedMeetings = result.items.map((record) {
          return CachedMeeting(
            id: record.id,
            title: record.data['title'] as String,
            meetingDate: DateTime.parse(record.data['meetingDate'] as String),
            location: record.data['location'] as String? ?? '',
            status: record.data['status'] as String,
            description: record.data['description'] as String?,
            presentCount: record.data['presentCount'] as int? ?? 0,
            absentCount: record.data['absentCount'] as int? ?? 0,
            cachedAt: DateTime.now(),
          );
        }).toList();

        await syncService.cacheMeetings(cachedMeetings);
      }

      if (page == 1) {
        emit(
          state.copyWith(
            status: MeetingStatus.loaded,
            meetings: meetings,
            hasMore: result.page < result.totalPages,
            currentPage: page,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MeetingStatus.loaded,
            meetings: [...state.meetings, ...meetings],
            hasMore: result.page < result.totalPages,
            currentPage: page,
          ),
        );
      }
    } on AttendanceFailure catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Load upcoming meetings
  Future<void> loadUpcomingMeetings() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final filter =
        'meetingDate >= "$today" && (status = "scheduled" || status = "ongoing")';
    await loadMeetings(filter: filter);
  }

  /// Load past meetings
  Future<void> loadPastMeetings() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final filter = 'meetingDate < "$today" || status = "completed"';
    await loadMeetings(filter: filter);
  }

  /// Load a single meeting
  Future<void> loadMeeting(String meetingId) async {
    emit(state.copyWith(status: MeetingStatus.loading));

    try {
      final record = await attendanceRepository.getMeeting(meetingId);
      final meeting = Meeting.fromRecord(record);

      emit(
        state.copyWith(
          status: MeetingStatus.loaded,
          selectedMeeting: meeting,
        ),
      );
    } on AttendanceFailure catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Create a new meeting
  Future<void> createMeeting({
    required DateTime meetingDate,
    required String meetingType,
    required String title,
    required String createdBy,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    int? totalExpectedMembers,
  }) async {
    emit(state.copyWith(status: MeetingStatus.submitting));

    try {
      final record = await attendanceRepository.createMeeting(
        meetingDate: meetingDate,
        meetingType: meetingType,
        title: title,
        createdBy: createdBy,
        location: location,
        startTime: startTime,
        endTime: endTime,
        description: description,
        totalExpectedMembers: totalExpectedMembers,
      );

      final meeting = Meeting.fromRecord(record);

      emit(
        state.copyWith(
          status: MeetingStatus.success,
          meetings: [meeting, ...state.meetings],
        ),
      );

      // Reload to get fresh data
      await loadMeetings();
    } on AttendanceFailure catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Update a meeting
  Future<void> updateMeeting(
    String meetingId,
    Map<String, dynamic> data,
  ) async {
    emit(state.copyWith(status: MeetingStatus.submitting));

    try {
      final record = await attendanceRepository.updateMeeting(meetingId, data);
      final meeting = Meeting.fromRecord(record);

      // Update in list
      final updatedMeetings = state.meetings.map((m) {
        return m.id == meetingId ? meeting : m;
      }).toList();

      emit(
        state.copyWith(
          status: MeetingStatus.success,
          meetings: updatedMeetings,
          selectedMeeting: state.selectedMeeting?.id == meetingId
              ? meeting
              : state.selectedMeeting,
        ),
      );
    } on AttendanceFailure catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Generate QR code for a meeting
  Future<void> generateQRCode(String meetingId) async {
    emit(state.copyWith(status: MeetingStatus.submitting));

    try {
      final record = await attendanceRepository.generateQRCode(meetingId);
      final meeting = Meeting.fromRecord(record);

      // Update in list
      final updatedMeetings = state.meetings.map((m) {
        return m.id == meetingId ? meeting : m;
      }).toList();

      emit(
        state.copyWith(
          status: MeetingStatus.success,
          meetings: updatedMeetings,
          selectedMeeting: state.selectedMeeting?.id == meetingId
              ? meeting
              : state.selectedMeeting,
        ),
      );
    } on AttendanceFailure catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Validate QR code
  Future<Meeting?> validateQRCode(String token) async {
    try {
      final record = await attendanceRepository.validateQRCode(token);
      if (record == null) return null;
      return Meeting.fromRecord(record);
    } catch (e) {
      return null;
    }
  }

  /// Delete a meeting
  Future<void> deleteMeeting(String meetingId) async {
    emit(state.copyWith(status: MeetingStatus.submitting));

    try {
      await attendanceRepository.deleteMeeting(meetingId);

      final updatedMeetings =
          state.meetings.where((m) => m.id != meetingId).toList();

      emit(
        state.copyWith(
          status: MeetingStatus.success,
          meetings: updatedMeetings,
        ),
      );
    } on AttendanceFailure catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MeetingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Clear selected meeting
  void clearSelectedMeeting() {
    emit(state.copyWith());
  }

  /// Reset state
  void reset() {
    emit(MeetingState.initial());
  }
}
