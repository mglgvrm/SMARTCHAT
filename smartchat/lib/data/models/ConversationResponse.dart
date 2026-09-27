class ConversationResponse {
  final String id;
  final List<String> participantIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ConversationResponse({
    required this.id,
    required this.participantIds,
    this.createdAt,
    this.updatedAt,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      id: json['id']?.toString() ?? '',
      participantIds: (json['participantIds'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}