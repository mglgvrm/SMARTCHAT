package com.smartchat.Persistence.Repository;

import com.smartchat.Persistence.Entity.Message;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;

@Repository
public interface MessageRepository
        extends MongoRepository<Message, String> {

    List<Message> findByConversationIdAndExpiresAtAfterOrderByCreatedAtAsc(
            String conversationId,
            Instant now
    );
}