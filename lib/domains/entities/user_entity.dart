import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? firstName; // Making these nullable for the user list
  final String? lastName;  // Making these nullable for the user list
  final String? avatar;    // Making these nullable for the user list
  final String? token;     // For the logged-in user

  const UserEntity({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatar,
    this.token,
  });

  @override
  List<Object?> get props => [id, email, firstName, lastName, avatar, token];
}