import 'package:attendance_repository/attendance_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:otogapo/app/modules/meetings/bloc/meeting_cubit.dart';
import 'package:pocketbase/pocketbase.dart';

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

class MockRecordModel extends Mock implements RecordModel {}

class MockResultList extends Mock implements ResultList<RecordModel> {}

void main() {
  group('MeetingCubit', () {
    late AttendanceRepository mockRepository;
    late MeetingCubit cubit;

    setUp(() {
      mockRepository = MockAttendanceRepository();
      cubit = MeetingCubit(attendanceRepository: mockRepository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state.status, MeetingStatus.initial);
      expect(cubit.state.meetings, isEmpty);
      expect(cubit.state.selectedMeeting, isNull);
    });

    group('loadMeetings', () {
      final mockMeeting = MockRecordModel();
      when(() => mockMeeting.id).thenReturn('test_id');
      when(() => mockMeeting.collectionId).thenReturn('meetings');
      when(() => mockMeeting.collectionName).thenReturn('meetings');
      when(() => mockMeeting.data).thenReturn({
        'meetingDate': '2025-01-20',
        'meetingType': 'regular',
        'title': 'Test Meeting',
        'status': 'scheduled',
        'createdBy': 'admin_123',
        'presentCount': 0,
        'absentCount': 0,
        'lateCount': 0,
        'excusedCount': 0,
      });

      blocTest<MeetingCubit, MeetingState>(
        'emits loading then loaded with meetings',
        build: () {
          final mockResult = MockResultList();
          when(() => mockResult.items).thenReturn([mockMeeting]);
          when(() => mockResult.page).thenReturn(1);
          when(() => mockResult.totalPages).thenReturn(1);

          when(
            () => mockRepository.getMeetings(
              page: any(named: 'page'),
              perPage: any(named: 'perPage'),
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
            ),
          ).thenAnswer((_) async => mockResult);

          return cubit;
        },
        act: (cubit) => cubit.loadMeetings(),
        expect: () => [
          predicate<MeetingState>(
            (state) => state.status == MeetingStatus.loading,
          ),
          predicate<MeetingState>(
            (state) =>
                state.status == MeetingStatus.loaded &&
                state.meetings.isNotEmpty,
          ),
        ],
      );

      blocTest<MeetingCubit, MeetingState>(
        'emits error when getMeetings fails',
        build: () {
          when(
            () => mockRepository.getMeetings(
              page: any(named: 'page'),
              perPage: any(named: 'perPage'),
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
            ),
          ).thenThrow(
            const AttendanceFailure(
              code: 'test_error',
              message: 'Test error',
            ),
          );

          return cubit;
        },
        act: (cubit) => cubit.loadMeetings(),
        expect: () => [
          predicate<MeetingState>(
            (state) => state.status == MeetingStatus.loading,
          ),
          predicate<MeetingState>(
            (state) =>
                state.status == MeetingStatus.error &&
                state.errorMessage == 'Test error',
          ),
        ],
      );
    });

    group('createMeeting', () {
      final mockMeeting = MockRecordModel();
      when(() => mockMeeting.id).thenReturn('new_meeting_id');
      when(() => mockMeeting.collectionId).thenReturn('meetings');
      when(() => mockMeeting.collectionName).thenReturn('meetings');
      when(() => mockMeeting.data).thenReturn({
        'meetingDate': '2025-01-20',
        'meetingType': 'regular',
        'title': 'New Meeting',
        'status': 'scheduled',
        'createdBy': 'admin_123',
        'presentCount': 0,
        'absentCount': 0,
        'lateCount': 0,
        'excusedCount': 0,
      });

      blocTest<MeetingCubit, MeetingState>(
        'creates meeting and reloads list',
        build: () {
          when(
            () => mockRepository.createMeeting(
              meetingDate: any(named: 'meetingDate'),
              meetingType: any(named: 'meetingType'),
              title: any(named: 'title'),
              createdBy: any(named: 'createdBy'),
              location: any(named: 'location'),
              startTime: any(named: 'startTime'),
              endTime: any(named: 'endTime'),
              description: any(named: 'description'),
              totalExpectedMembers: any(named: 'totalExpectedMembers'),
            ),
          ).thenAnswer((_) async => mockMeeting);

          final mockResult = MockResultList();
          when(() => mockResult.items).thenReturn([mockMeeting]);
          when(() => mockResult.page).thenReturn(1);
          when(() => mockResult.totalPages).thenReturn(1);

          when(
            () => mockRepository.getMeetings(
              page: any(named: 'page'),
              perPage: any(named: 'perPage'),
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
            ),
          ).thenAnswer((_) async => mockResult);

          return cubit;
        },
        act: (cubit) => cubit.createMeeting(
          meetingDate: DateTime(2025, 1, 20),
          meetingType: 'regular',
          title: 'New Meeting',
          createdBy: 'admin_123',
        ),
        expect: () => [
          predicate<MeetingState>(
            (state) => state.status == MeetingStatus.submitting,
          ),
          predicate<MeetingState>(
            (state) => state.status == MeetingStatus.success,
          ),
          predicate<MeetingState>(
            (state) => state.status == MeetingStatus.loading,
          ),
          predicate<MeetingState>(
            (state) => state.status == MeetingStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(
            () => mockRepository.createMeeting(
              meetingDate: any(named: 'meetingDate'),
              meetingType: 'regular',
              title: 'New Meeting',
              createdBy: 'admin_123',
              location: any(named: 'location'),
              startTime: any(named: 'startTime'),
              endTime: any(named: 'endTime'),
              description: any(named: 'description'),
              totalExpectedMembers: any(named: 'totalExpectedMembers'),
            ),
          ).called(1);
        },
      );
    });

    group('generateQRCode', () {
      final mockMeeting = MockRecordModel();
      when(() => mockMeeting.id).thenReturn('meeting_id');
      when(() => mockMeeting.collectionId).thenReturn('meetings');
      when(() => mockMeeting.collectionName).thenReturn('meetings');
      when(() => mockMeeting.data).thenReturn({
        'meetingDate': '2025-01-20',
        'meetingType': 'regular',
        'title': 'Test Meeting',
        'status': 'ongoing',
        'createdBy': 'admin_123',
        'qrCodeToken': 'ABC123',
        'qrCodeExpiry': '2025-01-20T17:00:00Z',
        'presentCount': 0,
        'absentCount': 0,
        'lateCount': 0,
        'excusedCount': 0,
      });

      blocTest<MeetingCubit, MeetingState>(
        'generates QR code successfully',
        build: () {
          when(() => mockRepository.generateQRCode(any()))
              .thenAnswer((_) async => mockMeeting);

          return cubit;
        },
        act: (cubit) => cubit.generateQRCode('meeting_id'),
        expect: () => [
          predicate<MeetingState>(
            (state) => state.status == MeetingStatus.submitting,
          ),
          predicate<MeetingState>(
            (state) => state.status == MeetingStatus.success,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.generateQRCode('meeting_id')).called(1);
        },
      );
    });
  });
}
