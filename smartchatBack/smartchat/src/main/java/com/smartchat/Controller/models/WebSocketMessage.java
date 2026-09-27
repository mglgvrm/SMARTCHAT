package com.smartchat.Controller.models;

public record WebSocketMessage(
        String conversationId,
        String senderId,
        String receiverId,
        String content,
        String type,
        String messageId
) {
}