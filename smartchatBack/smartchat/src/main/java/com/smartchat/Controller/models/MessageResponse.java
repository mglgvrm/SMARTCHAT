package com.smartchat.Controller.models;

import java.time.Instant;

public record MessageResponse(
        String id,
        String conversationId,
        String senderId,
        String receiverId,
        String content,
        String type,
        Instant createdAt,
        Instant expiresAt,
        Instant readAt
) {
}