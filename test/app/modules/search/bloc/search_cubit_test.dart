import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage/local_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:otogapo/app/modules/search/bloc/search_cubit.dart';
import 'package:otogapo/app/modules/search/bloc/search_state.dart';
import 'package:otogapo/models/post.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:pocketbase/pocketbase.dart';

class MockPocketBaseService extends Mock implements PocketBaseService {}

class MockLocalStorage extends Mock implements LocalStorage {}

class MockResultList extends Mock implements ResultList<RecordModel> {}

class MockRecordModel extends Mock implements RecordModel {}

void main() {
  group('SearchCubit', () {
    late PocketBaseService mockPocketBaseService;
    late LocalStorage mockLocalStorage;
    late SearchCubit cubit;

    setUp(() {
      mockPocketBaseService = MockPocketBaseService();
      mockLocalStorage = MockLocalStorage();

      when(() => mockLocalStorage.read<List<dynamic>>(any())).thenAnswer((_) async => null);

      cubit = SearchCubit(
        pocketBaseService: mockPocketBaseService,
        localStorage: mockLocalStorage,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state.status, SearchStatus.initial);
      expect(cubit.state.query, '');
      expect(cubit.state.postResults, isEmpty);
      expect(cubit.state.hasQuery, isFalse);
    });

    blocTest<SearchCubit, SearchState>(
      'clearSearch resets state',
      build: () => cubit,
      act: (cubit) => cubit.clearSearch(),
      expect: () => [
        predicate<SearchState>(
          (state) => state.query.isEmpty && state.status == SearchStatus.initial,
        ),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'searchPosts with empty query clears results',
      build: () => cubit,
      act: (cubit) => cubit.searchPosts(''),
      expect: () => [
        predicate<SearchState>(
          (state) => state.query.isEmpty && state.postResults.isEmpty,
        ),
      ],
    );
  });
}
