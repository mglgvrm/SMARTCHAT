package com.smartchat.Domain.Service;

import com.smartchat.Controller.models.ConversationResponse;
import com.smartchat.Persistence.Entity.Conversation;
import com.smartchat.Persistence.Entity.User;
import com.smartchat.Persistence.Repository.ConversationRepository;
import com.smartchat.Persistence.Repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ConversationService {

    private final ConversationRepository conversationRepository;
    private final UserRepository userRepository;

    public ConversationResponse getOrCreateConversation(
            String currentEmail,
            String otherUserId
    ) {
        User currentUser = userRepository.findByEmail(currentEmail)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "Usuario autenticado no encontrado"
                ));

        User otherUser = userRepository.findById(otherUserId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "El usuario destinatario no existe"
                ));

        if (currentUser.getId().equals(otherUser.getId())) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "No puedes crear una conversación contigo mismo"
            );
        }

        validateChatAccount(currentUser);
        validateChatAccount(otherUser);

        List<String> participantIds = List.of(
                currentUser.getId(),
                otherUser.getId()
        ).stream().sorted().toList();

        String participantKey = String.join("_", participantIds);

        Conversation conversation = conversationRepository
                .findBetweenUsers(
                        currentUser.getId(),
                        otherUser.getId()
                )
                .orElseGet(() -> {
                    Instant now = Instant.now();

                    Conversation newConversation = Conversation.builder()
                            .participantIds(participantIds)
                            .participantKey(participantKey)
                            .createdAt(now)
                            .updatedAt(now)
                            .build();

                    return conversationRepository.save(newConversation);
                });

        return toResponse(conversation);
    }

    public List<ConversationResponse> getMyConversations(
            String currentEmail
    ) {
        User currentUser = userRepository.findByEmail(currentEmail)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "Usuario autenticado no encontrado"
                ));

        return conversationRepository
                .findByParticipantIdsContaining(currentUser.getId())
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private void validateChatAccount(User user) {
        if (!Boolean.TRUE.equals(user.getActive())) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "La cuenta no está activa"
            );
        }

        if (Boolean.TRUE.equals(user.getBanned())) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "La cuenta no puede utilizar la mensajería"
            );
        }
    }

    private ConversationResponse toResponse(
            Conversation conversation
    ) {
        return new ConversationResponse(
                conversation.getId(),
                conversation.getParticipantIds(),
                conversation.getCreatedAt(),
                conversation.getUpdatedAt()
        );
    }
}