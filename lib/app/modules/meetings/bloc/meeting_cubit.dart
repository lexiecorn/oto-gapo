import 'package:attendance_repository/attendance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:otogapo/models/meeting.dart';

part 'meeting_state.dart';

class MeetingCubit extends Cubit<MeetingState> {
  MeetingCubit({
    required this.attendanceRepository,
  }) : super(MeetingState.initial());

  final AttendanceRepository attendanceRepository;

  /// Load all meetings
  Future<void> loadMeetings({
    int page = 1,
    String? filter,
  }) async {
    if (page == 1) {
      emit(state.copyWith(status: MeetingStatus.loading));
    }

    try {
      final result = await attendanceRepository.getMeetings(
        page: page,
        perPage: 20,
        filter: filter,
        sort: '-meetingDate',
      );

      final meetings = result.items.map(Meeting.fromRecord).toList();

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
    emit(state.copyWith(selectedMeeting: null));
  }

  /// Reset state
  void reset() {
    emit(MeetingState.initial());
  }
}
