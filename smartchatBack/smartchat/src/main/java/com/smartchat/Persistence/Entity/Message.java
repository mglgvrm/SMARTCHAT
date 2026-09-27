package com.smartchat.Persistence.Entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.CompoundIndex;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Document(collection = "messages")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@CompoundIndex(
        name = "conversation_created_at",
        def = "{'conversationId': 1, 'createdAt': 1}"
)
public class Message {

    @Id
    private String id;

    private String conversationId;

    private String senderId;

    private String receiverId;

    private String content;

    @Builder.Default
    private String type = "TEXT";

    private Instant createdAt;

    @Indexed(
            name = "message_expiration_ttl",
            expireAfter = "0s"
    )
    private Instant expiresAt;

    private Instant readAt;
}