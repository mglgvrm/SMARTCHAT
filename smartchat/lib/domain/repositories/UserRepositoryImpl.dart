
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:smartchat/data/models/UserCardResponse.dart';
import 'dart:convert';

import 'package:smartchat/domain/repositories/UserRepository.dart';

class UserRepositoryImpl implements UserRepository {

  final Dio dio;
  final FlutterSecureStorage authStorage;

  UserRepositoryImpl(this.authStorage, this.dio);


  @override
  Future<List<UserCardResponse>> getChatableUsers() async {

    final token = await authStorage.read(key: "token");

    if (token == null || token.isEmpty) {
      throw Exception('Token no encontrado');
    }

    final response = await dio.get(
      "/api/users/chatable",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    if (response.statusCode == 200) {

      final List<dynamic> data = response.data;

      return data
          .map(
            (json) => UserCardResponse.fromJson(json),
      )
          .toList();
    }

    if (response.statusCode == 400) {
      throw Exception(
        'Token de autorización inválido',
      );
    }

    throw Exception(
      'Error al obtener usuarios: ${response.statusCode}',
    );
  }
}