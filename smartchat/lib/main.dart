import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smartchat/domain/repositories/AuthRemoteDataSourceImpl.dart';
import 'package:smartchat/domain/repositories/UserRepositoryImpl.dart';
import 'package:smartchat/domain/usecases/CompleteProfileUseCase.dart';
import 'package:smartchat/domain/usecases/GetChatableUsersUseCase.dart';
import 'package:smartchat/domain/usecases/LocalLoginUseCase.dart';
import 'package:smartchat/presentation/bloc/user/user_bloc.dart';

import 'firebase_options.dart';

import 'core/routes/app_routes.dart';

import 'data/datasource/AuthRemoteDataSource.dart';


import 'domain/repositories/AuthRepositoryImpl.dart';
import 'domain/usecases/GoogleLoginUseCase.dart';

import 'presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8080"
    ),
  );
  final storage = FlutterSecureStorage();
  final remoteDataSource =
  AuthRemoteDataSourceImpl(dio, storage);

  final repository =
  AuthRepositoryImpl(
    remoteDataSource,
  );

  final googleLoginUseCase =
  GoogleLoginUseCase(
    repository,
  );

  final completeProfileUseCase = CompleteProfileUseCase(repository);

  final localLoginUseCase =
  LocalLoginUseCase(
    repository,
  );

  final chatRepository= UserRepositoryImpl( storage, dio);
  final getChatableUsersUseCase= GetChatableUsersUseCase(chatRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            googleLoginUseCase, completeProfileUseCase, localLoginUseCase
          ),

        ),
        BlocProvider(
          create: (_) => UserBloc(
            getChatableUsersUseCase: getChatableUsersUseCase,

          ),

        ),
      ],
      child: const SmartChatApp(),
    ),
  );
}

class SmartChatApp extends StatelessWidget {
  const SmartChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SmartChat",
      debugShowCheckedModeBanner: false,

      initialRoute: AppRoutes.login,

      onGenerateRoute:
      AppRoutes.generateRoute,
    );
  }
}