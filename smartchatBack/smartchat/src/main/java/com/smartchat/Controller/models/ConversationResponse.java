package com.smartchat.Controller.models;

import java.time.Instant;
import java.util.List;

public record ConversationResponse(
        String id,
        List<String> participantIds,
        Instant createdAt,
        Instant updatedAt
) {
}