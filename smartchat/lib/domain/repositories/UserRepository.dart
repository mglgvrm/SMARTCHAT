

import 'package:smartchat/data/models/UserCardResponse.dart';

abstract class UserRepository {
  Future<List<UserCardResponse>> getChatableUsers();
}