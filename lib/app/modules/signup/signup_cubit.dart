import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:otogapo/models/custom_error.dart';

part 'signup_cubit.freezed.dart';
part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit({
    required this.authRepository,
  }) : super(SignupState.initial());
  final AuthRepository authRepository;

  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    String? age,
  }) async {
    // TODO(PaoloTolentino): Disabled for now
    // emit(state.copyWith(signupStatus: SignupStatus.submitting));

    // try {
    //   await authRepository.signup(
    //     firstName: firstName,
    //     lastName: lastName,
    //     age: age,
    //     email: email,
    //     password: password,
    //   );
    //   emit(state.copyWith(signupStatus: SignupStatus.success));
    // } on CustomError catch (e) {
    //   emit(state.copyWith(signupStatus: SignupStatus.error, error: e));
    // }
  }
}
