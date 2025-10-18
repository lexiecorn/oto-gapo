import 'package:attendance_repository/attendance_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:test/test.dart';

class MockPocketBase extends Mock implements PocketBase {}

class MockCollectionService extends Mock implements RecordService {}

class MockRecordModel extends Mock implements RecordModel {}

class MockResultList extends Mock implements ResultList<RecordModel> {}

void main() {
  group('AttendanceRepository', () {
    late PocketBase mockPocketBase;
    late RecordService mockMeetingsCollection;
    late RecordService mockAttendanceCollection;
    late AttendanceRepository repository;

    setUp(() {
      mockPocketBase = MockPocketBase();
      mockMeetingsCollection = MockCollectionService();
      mockAttendanceCollection = MockCollectionService();
      repository = AttendanceRepository(pocketBase: mockPocketBase);

      when(() => mockPocketBase.collection('meetings')).thenReturn(mockMeetingsCollection);
      when(() => mockPocketBase.collection('attendance')).thenReturn(mockAttendanceCollection);
    });

    group('getMeetings', () {
      test('returns meetings list successfully', () async {
        final mockResult = MockResultList();
        when(() => mockResult.items).thenReturn([]);
        when(() => mockResult.page).thenReturn(1);
        when(() => mockResult.totalPages).thenReturn(1);

        when(
          () => mockMeetingsCollection.getList(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
            filter: any(named: 'filter'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => mockResult);

        final result = await repository.getMeetings();

        expect(result, isA<ResultList<RecordModel>>());
        verify(
          () => mockMeetingsCollection.getList(
            page: 1,
            perPage: 20,
            filter: null,
            sort: '-meetingDate',
          ),
        ).called(1);
      });

      test('throws AttendanceFailure on error', () async {
        when(
          () => mockMeetingsCollection.getList(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
            filter: any(named: 'filter'),
            sort: any(named: 'sort'),
          ),
        ).thenThrow(Exception('Network error'));

        expect(
          () => repository.getMeetings(),
          throwsA(isA<AttendanceFailure>()),
        );
      });
    });

    group('createMeeting', () {
      test('creates meeting successfully', () async {
        final mockRecord = MockRecordModel();
        when(() => mockRecord.id).thenReturn('test_meeting_id');

        when(
          () => mockMeetingsCollection.create(body: any(named: 'body')),
        ).thenAnswer((_) async => mockRecord);

        final result = await repository.createMeeting(
          meetingDate: DateTime(2025, 1, 20),
          meetingType: 'regular',
          title: 'Test Meeting',
          createdBy: 'admin_123',
        );

        expect(result.id, 'test_meeting_id');
        verify(
          () => mockMeetingsCollection.create(
            body: any(named: 'body'),
          ),
        ).called(1);
      });
    });

    group('markAttendance', () {
      test('creates new attendance record', () async {
        final mockRecord = MockRecordModel();
        when(() => mockRecord.id).thenReturn('attendance_id');
        when(() => mockRecord.data).thenReturn({
          'userId': 'user_123',
          'meetingId': 'meeting_123',
          'status': 'present',
        });

        // Mock getAttendanceRecord to return null (no existing record)
        final emptyResult = MockResultList();
        when(() => emptyResult.items).thenReturn([]);

        when(
          () => mockAttendanceCollection.getList(
            filter: any(named: 'filter'),
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => emptyResult);

        when(
          () => mockAttendanceCollection.create(body: any(named: 'body')),
        ).thenAnswer((_) async => mockRecord);

        // Mock update methods for counts
        when(
          () => mockMeetingsCollection.update(
            any(),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => mockRecord);

        when(
          () => mockPocketBase.collection('attendance_summary'),
        ).thenReturn(mockAttendanceCollection);

        final result = await repository.markAttendance(
          userId: 'user_123',
          memberNumber: 'OTO-001',
          memberName: 'Test User',
          meetingId: 'meeting_123',
          meetingDate: DateTime(2025, 1, 20),
          status: 'present',
          checkInMethod: 'qr_scan',
        );

        expect(result.id, 'attendance_id');
      });
    });

    group('generateQRCode', () {
      test('generates QR code and updates meeting', () async {
        final mockRecord = MockRecordModel();
        when(() => mockRecord.id).thenReturn('meeting_id');

        when(
          () => mockMeetingsCollection.update(
            any(),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => mockRecord);

        final result = await repository.generateQRCode('meeting_id');

        expect(result.id, 'meeting_id');
        verify(
          () => mockMeetingsCollection.update(
            'meeting_id',
            body: any(
              named: 'body',
              that: predicate<Map<String, dynamic>>((data) {
                return data.containsKey('qrCodeToken') &&
                    data.containsKey('qrCodeExpiry') &&
                    data['status'] == 'ongoing';
              }),
            ),
          ),
        ).called(1);
      });
    });

    group('validateQRCode', () {
      test('returns meeting when QR code is valid', () async {
        final mockRecord = MockRecordModel();
        final mockResult = MockResultList();
        when(() => mockResult.items).thenReturn([mockRecord]);

        when(
          () => mockMeetingsCollection.getList(
            filter: any(named: 'filter'),
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => mockResult);

        final result = await repository.validateQRCode('valid_token');

        expect(result, mockRecord);
      });

      test('returns null when QR code is invalid', () async {
        final mockResult = MockResultList();
        when(() => mockResult.items).thenReturn([]);

        when(
          () => mockMeetingsCollection.getList(
            filter: any(named: 'filter'),
            perPage: any(named: 'perPage'),
          ),
        ).thenAnswer((_) async => mockResult);

        final result = await repository.validateQRCode('invalid_token');

        expect(result, isNull);
      });
    });
  });
}

