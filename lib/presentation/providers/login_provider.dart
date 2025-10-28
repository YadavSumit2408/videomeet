import 'package:flutter/material.dart';
import '../../core/errors/failures.dart';
import '../../domains/entities/user_entity.dart';
import '../../domains/use_cases/login_use_case.dart';

enum LoginState { initial, loading, success, error }

class LoginProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  LoginProvider({required this.loginUseCase});

  LoginState _state = LoginState.initial;
  String _errorMessage = '';
  UserEntity? _user;

  // Getters for the UI
  LoginState get state => _state;
  String get errorMessage => _errorMessage;
  UserEntity? get user => _user;

  Future<void> login(String email, String password) async {
    _state = LoginState.loading;
    _errorMessage = '';
    notifyListeners();

    final result = await loginUseCase(LoginParams(email: email, password: password));

    result.fold(
      (failure) {
        // Handle failure
        _errorMessage = _mapFailureToMessage(failure);
        _state = LoginState.error;
      },
      (user) {
        // Handle success
        _user = user;
        _state = LoginState.success;
      },
    );

    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case ValidationFailure:
        return failure.message;
      default:
        return 'An unexpected error occurred.';
    }
  }
}