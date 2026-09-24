import 'package:smartchat/domain/entities/AuthUser.dart';
import 'package:smartchat/domain/entities/User.dart';

abstract class AuthState {}

class AuthInitial
    extends AuthState {}

class AuthLoading
    extends AuthState {}

class AuthSuccess
    extends AuthState {

  final AuthUser user;

  AuthSuccess(this.user);

}
class CompleteSuccess
    extends AuthState {

  final User user;

  CompleteSuccess(this.user);

}

class AuthError
    extends AuthState {

  final String message;

  AuthError(this.message);

}