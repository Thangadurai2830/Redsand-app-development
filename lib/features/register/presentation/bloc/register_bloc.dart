import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/register_user.dart';
import '../../domain/usecases/register_user_usecase.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUserUsecase registerUser;

  RegisterBloc({required this.registerUser}) : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    final result = await registerUser(RegisterUser(
      fullName: event.fullName,
      email: event.email,
      phone: event.phone,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(const RegisterFailure('Registration failed. Please try again.')),
      (message) => emit(RegisterSuccess(email: event.email, phone: event.phone)),
    );
  }
}
