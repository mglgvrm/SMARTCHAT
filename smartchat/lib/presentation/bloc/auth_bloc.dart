import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartchat/domain/usecases/CompleteProfileUseCase.dart';
import 'package:smartchat/domain/usecases/GoogleLoginUseCase.dart';
import 'package:smartchat/domain/usecases/LocalLoginUseCase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleLoginUseCase googleLoginUseCase;

  final CompleteProfileUseCase completeProfileUseCase;

  final LocalLoginUseCase localLoginUseCase;

  AuthBloc(
    this.googleLoginUseCase,
    this.completeProfileUseCase,
    this.localLoginUseCase,
  ) : super(AuthInitial()) {
    on<LoginGoogleEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        final user = await googleLoginUseCase();
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LoginLocalEvent>(_localLogin);

    on<CompleteProfileRequested>(_completeProfile);
  }

  Future<void> _localLogin(
    LoginLocalEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await localLoginUseCase(
        email: event.email,
        password: event.password,
      );
      emit(AuthSuccess(user));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final message =
            e.response?.data?["message"] ?? "Credenciales inválidas";

        emit(AuthError(message));
        return;
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        emit(AuthError("No hay conexión a Internet."));
        return;
      }

      if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        emit(AuthError("Error del servidor. Intenta nuevamente."));
        return;
      }

      emit(AuthError("No se pudo iniciar sesión."));
    }
  }

  Future<void> _completeProfile(
    CompleteProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final user = await completeProfileUseCase.call(
        username: event.username,
        fullName: event.fullName,
        birthDate: event.birthDate,
      );

      emit(CompleteSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
