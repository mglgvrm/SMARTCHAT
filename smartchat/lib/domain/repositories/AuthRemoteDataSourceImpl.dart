import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smartchat/data/datasource/AuthRemoteDataSource.dart';
import 'package:smartchat/data/models/AuthUserModel.dart';
import 'package:smartchat/data/models/UserModel.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage storage;

  AuthRemoteDataSourceImpl(this.dio, this.storage);

  @override
  Future<AuthUserModel> loginWithLocal({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      "/api/auth/login",
      data: {"email": email, "password": password},
    );
    await storage.write(key: "token", value: response.data["token"]);
    return AuthUserModel.fromJson(response.data);
  }

  @override
  Future<AuthUserModel> loginWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw Exception("Login cancelado");
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await FirebaseAuth.instance.signInWithCredential(credential);

    final firebaseToken = await result.user!.getIdToken();

    final response = await dio.post(
      "/api/auth/firebase/google",
      data: {"firebaseToken": firebaseToken},
    );
    await storage.write(key: "token", value: response.data["token"]);
    return AuthUserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> completeProfile({
    required String username,
    required String fullName,
    required String birthDate,
  }) async {
    final token = await storage.read(key: "token");
    print("TOKEN STORAGE: $token");
    final response = await dio.post(
      "/api/auth/complete-profile",
      data: {
        "username": username,
        "fullName": fullName,
        "birthDate": birthDate,
      },
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    return UserModel.fromJson(response.data);
  }
}
