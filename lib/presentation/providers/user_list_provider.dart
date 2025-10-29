import 'package:flutter/material.dart';
import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '../../domains/entities/user_entity.dart';
import '../../domains/use_cases/get_users_use_case.dart';


enum UserListState { initial, loading, loaded, error }

class UserListProvider extends ChangeNotifier {
  final GetUsersUseCase getUsersUseCase;

  UserListProvider({required this.getUsersUseCase});

  UserListState _state = UserListState.initial;
  List<UserEntity> _users = [];
  String _errorMessage = '';

  // Getters
  UserListState get state => _state;
  List<UserEntity> get users => _users;
  String get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    _state = UserListState.loading;
    notifyListeners();

    final result = await getUsersUseCase(NoParams());

    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
        _state = UserListState.error;
      },
      (userList) {
        _users = userList;
        _state = UserListState.loaded;
      },
    );
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case CacheFailure:
        return failure.message;
      default:
        return 'An unexpected error occurred.';
    }
  }
}