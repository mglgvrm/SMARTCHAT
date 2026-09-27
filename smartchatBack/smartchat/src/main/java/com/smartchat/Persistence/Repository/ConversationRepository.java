package com.smartchat.Persistence.Repository;

import com.smartchat.Persistence.Entity.Conversation;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ConversationRepository
        extends MongoRepository<Conversation, String> {

    @Query("{ 'participantIds': { '$all': [ ?0, ?1 ] } }")
    Optional<Conversation> findBetweenUsers(
            String firstUserId,
            String secondUserId
    );

    List<Conversation> findByParticipantIdsContaining(
            String userId
    );
}