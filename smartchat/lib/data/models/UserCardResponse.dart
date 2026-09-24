class UserCardResponse {
  final String id;
  final String? username;
  final String? fullName;
  final String? bio;
  final String? country;
  final String? profilePicture;
  final bool? online;
  final bool? verifiedCreator;
  final String? subscriptionPlan;

  UserCardResponse({
    required this.id,
    this.username,
    this.fullName,
    this.bio,
    this.country,
    this.profilePicture,
    this.online,
    this.verifiedCreator,
    this.subscriptionPlan,
  });

  factory UserCardResponse.fromJson(Map<String, dynamic> json) {
    return UserCardResponse(
      id: json['id'] ?? '',
      username: json['username'],
      fullName: json['fullName'],
      bio: json['bio'],
      country: json['country'],
      profilePicture: json['profilePicture'],
      online: json['online'],
      verifiedCreator: json['verifiedCreator'],
      subscriptionPlan: json['subscriptionPlan'],
    );
  }
}