import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// State
class MyFeatureState extends Equatable {
  const MyFeatureState({
    this.isLoading = false,
    this.errorMessage,
    this.items = const <Object>[],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<Object> items;

  MyFeatureState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Object>? items,
  }) {
    return MyFeatureState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, errorMessage, items];
}

// Cubit
class MyFeatureCubit extends Cubit<MyFeatureState> {
  MyFeatureCubit({required this.repository}) : super(const MyFeatureState());

  final Object repository; // Replace with a concrete repository type

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      // final results = await repository.fetch();
      final results = <Object>[]; // placeholder
      emit(state.copyWith(isLoading: false, items: results));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}


