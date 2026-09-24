abstract class AuthEvent {}

class LoginGoogleEvent
    extends AuthEvent {}


class LoginLocalEvent
    extends AuthEvent {
  final String email;
  final String password;
  LoginLocalEvent({
    required this.email,
    required this.password,

});
}


class CompleteProfileRequested extends AuthEvent {
  final String username;
  final String fullName;
  final String birthDate;

  CompleteProfileRequested({
    required this.username,
    required this.fullName,
    required this.birthDate,
  });
}