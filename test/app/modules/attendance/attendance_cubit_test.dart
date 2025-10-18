import 'package:attendance_repository/attendance_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:otogapo/app/modules/attendance/bloc/attendance_cubit.dart';
import 'package:pocketbase/pocketbase.dart';

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

class MockRecordModel extends Mock implements RecordModel {}

class MockResultList extends Mock implements ResultList<RecordModel> {}

void main() {
  group('AttendanceCubit', () {
    late AttendanceRepository mockRepository;
    late AttendanceCubit cubit;

    setUp(() {
      mockRepository = MockAttendanceRepository();
      cubit = AttendanceCubit(attendanceRepository: mockRepository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state.status, AttendanceStateStatus.initial);
      expect(cubit.state.attendances, isEmpty);
      expect(cubit.state.summary, isNull);
    });

    group('loadMeetingAttendance', () {
      final mockAttendance = RecordModel(
        id: 'attendance_id',
        collectionId: 'attendance',
        collectionName: 'attendance',
        created: '2025-01-01T00:00:00Z',
        updated: '2025-01-01T00:00:00Z',
        data: {
          'userId': 'user_123',
          'memberNumber': 'OTO-001',
          'memberName': 'Test User',
          'meetingId': 'meeting_123',
          'meetingDate': '2025-01-20',
          'status': 'present',
        },
      );

      blocTest<AttendanceCubit, AttendanceState>(
        'emits loading then loaded with attendance records',
        build: () {
          final mockResult = MockResultList();
          when(() => mockResult.items).thenReturn([mockAttendance]);
          when(() => mockResult.page).thenReturn(1);
          when(() => mockResult.totalPages).thenReturn(1);

          when(
            () => mockRepository.getAttendanceForMeeting(
              any(),
              page: any(named: 'page'),
              perPage: any(named: 'perPage'),
            ),
          ).thenAnswer((_) async => mockResult);

          return cubit;
        },
        act: (cubit) => cubit.loadMeetingAttendance('meeting_123'),
        expect: () => [
          predicate<AttendanceState>(
            (state) => state.status == AttendanceStateStatus.loading,
          ),
          predicate<AttendanceState>(
            (state) => state.status == AttendanceStateStatus.loaded && state.attendances.isNotEmpty,
          ),
        ],
      );
    });

    group('markAttendance', () {
      final mockRecord = RecordModel(
        id: 'new_attendance_id',
        collectionId: 'attendance',
        collectionName: 'attendance',
        created: '2025-01-01T00:00:00Z',
        updated: '2025-01-01T00:00:00Z',
        data: {
          'userId': 'user_123',
          'memberNumber': 'OTO-001',
          'memberName': 'Test User',
          'meetingId': 'meeting_123',
          'meetingDate': '2025-01-20',
          'status': 'present',
          'checkInMethod': 'qr_scan',
        },
      );

      blocTest<AttendanceCubit, AttendanceState>(
        'marks attendance successfully',
        build: () {
          when(
            () => mockRepository.markAttendance(
              userId: any(named: 'userId'),
              memberNumber: any(named: 'memberNumber'),
              memberName: any(named: 'memberName'),
              meetingId: any(named: 'meetingId'),
              meetingDate: any(named: 'meetingDate'),
              status: any(named: 'status'),
              profileImage: any(named: 'profileImage'),
              checkInTime: any(named: 'checkInTime'),
              checkInMethod: any(named: 'checkInMethod'),
              markedBy: any(named: 'markedBy'),
              notes: any(named: 'notes'),
            ),
          ).thenAnswer((_) async => mockRecord);

          return cubit;
        },
        act: (cubit) => cubit.markAttendance(
          userId: 'user_123',
          memberNumber: 'OTO-001',
          memberName: 'Test User',
          meetingId: 'meeting_123',
          meetingDate: DateTime(2025, 1, 20),
          status: 'present',
          checkInMethod: 'qr_scan',
        ),
        expect: () => [
          predicate<AttendanceState>(
            (state) => state.status == AttendanceStateStatus.submitting,
          ),
          predicate<AttendanceState>(
            (state) => state.status == AttendanceStateStatus.success && state.attendances.isNotEmpty,
          ),
        ],
      );

      blocTest<AttendanceCubit, AttendanceState>(
        'emits error when marking attendance fails',
        build: () {
          when(
            () => mockRepository.markAttendance(
              userId: any(named: 'userId'),
              memberNumber: any(named: 'memberNumber'),
              memberName: any(named: 'memberName'),
              meetingId: any(named: 'meetingId'),
              meetingDate: any(named: 'meetingDate'),
              status: any(named: 'status'),
              profileImage: any(named: 'profileImage'),
              checkInTime: any(named: 'checkInTime'),
              checkInMethod: any(named: 'checkInMethod'),
              markedBy: any(named: 'markedBy'),
              notes: any(named: 'notes'),
            ),
          ).thenThrow(
            const DuplicateAttendanceFailure(),
          );

          return cubit;
        },
        act: (cubit) => cubit.markAttendance(
          userId: 'user_123',
          memberNumber: 'OTO-001',
          memberName: 'Test User',
          meetingId: 'meeting_123',
          meetingDate: DateTime(2025, 1, 20),
          status: 'present',
        ),
        expect: () => [
          predicate<AttendanceState>(
            (state) => state.status == AttendanceStateStatus.submitting,
          ),
          predicate<AttendanceState>(
            (state) => state.status == AttendanceStateStatus.error && state.errorMessage != null,
          ),
        ],
      );
    });

    group('loadAttendanceSummary', () {
      final mockSummary = RecordModel(
        id: 'summary_id',
        collectionId: 'attendance_summary',
        collectionName: 'attendance_summary',
        created: '2025-01-01T00:00:00Z',
        updated: '2025-01-01T00:00:00Z',
        data: {
          'userId': 'user_123',
          'totalMeetings': 10,
          'totalPresent': 8,
          'totalAbsent': 1,
          'totalLate': 1,
          'totalExcused': 0,
          'attendanceRate': 90.0,
        },
      );

      blocTest<AttendanceCubit, AttendanceState>(
        'loads summary successfully',
        build: () {
          when(() => mockRepository.getAttendanceSummary(any())).thenAnswer((_) async => mockSummary);

          return cubit;
        },
        act: (cubit) => cubit.loadAttendanceSummary('user_123'),
        expect: () => [
          predicate<AttendanceState>(
            (state) => state.status == AttendanceStateStatus.loading,
          ),
          predicate<AttendanceState>(
            (state) => state.status == AttendanceStateStatus.loaded && state.summary != null,
          ),
        ],
      );
    });
  });
}

