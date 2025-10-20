import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:otogapo/app/modules/connectivity/bloc/connectivity_cubit.dart';
import 'package:otogapo/app/modules/connectivity/bloc/connectivity_state.dart';
import 'package:otogapo/services/connectivity_service.dart';
import 'package:otogapo/services/sync_service.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockSyncService extends Mock implements SyncService {}

void main() {
  group('ConnectivityCubit', () {
    late ConnectivityService mockConnectivityService;
    late SyncService mockSyncService;
    late ConnectivityCubit cubit;

    setUp(() {
      mockConnectivityService = MockConnectivityService();
      mockSyncService = MockSyncService();

      // Setup default return values
      when(() => mockConnectivityService.currentStatus).thenReturn(ConnectivityStatus.online);
      when(() => mockConnectivityService.connectivityStream).thenAnswer(
        (_) => Stream.value(ConnectivityStatus.online),
      );
      when(() => mockSyncService.currentStatus).thenReturn(SyncStatus.idle);
      when(() => mockSyncService.syncStatusStream).thenAnswer(
        (_) => Stream.value(SyncStatus.idle),
      );
      when(() => mockSyncService.pendingActionsCount).thenReturn(0);

      cubit = ConnectivityCubit(
        connectivityService: mockConnectivityService,
        syncService: mockSyncService,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has online status', () {
      expect(cubit.state.connectivityStatus, ConnectivityStatus.online);
      expect(cubit.state.syncStatus, SyncStatus.idle);
      expect(cubit.state.pendingActionsCount, 0);
    });

    test('isOnline returns true when connected', () {
      expect(cubit.state.isOnline, isTrue);
      expect(cubit.state.isOffline, isFalse);
    });

    blocTest<ConnectivityCubit, ConnectivityState>(
      'triggerSync calls syncService when online',
      build: () {
        when(() => mockSyncService.syncPendingActions()).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.triggerSync(),
      verify: (_) {
        verify(() => mockSyncService.syncPendingActions()).called(1);
      },
    );

    blocTest<ConnectivityCubit, ConnectivityState>(
      'refreshConnectivity calls service refresh',
      build: () {
        when(() => mockConnectivityService.refresh()).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.refreshConnectivity(),
      verify: (_) {
        verify(() => mockConnectivityService.refresh()).called(1);
      },
    );
  });
}
