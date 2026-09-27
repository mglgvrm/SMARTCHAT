package com.smartchat.Domain.Service;

import com.smartchat.Controller.models.CreateMessageRequest;
import com.smartchat.Controller.models.MessageResponse;
import com.smartchat.Persistence.Entity.Conversation;
import com.smartchat.Persistence.Entity.Message;
import com.smartchat.Persistence.Entity.User;
import com.smartchat.Persistence.Repository.ConversationRepository;
import com.smartchat.Persistence.Repository.MessageRepository;
import com.smartchat.Persistence.Repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MessageService {

    private final MessageRepository messageRepository;
    private final ConversationRepository conversationRepository;
    private final UserRepository userRepository;
    private final SimpMessagingTemplate messagingTemplate;

    public MessageResponse sendMessage(
            String currentEmail,
            String conversationId,
            CreateMessageRequest request
    ) {
        User currentUser = getCurrentUser(currentEmail);

        validateChatAccount(currentUser);

        Conversation conversation =
                getConversation(conversationId);

        validateParticipant(
                conversation,
                currentUser.getId()
        );

        String content = request.content() == null
                ? ""
                : request.content().trim();

        if (content.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "El mensaje no puede estar vacío"
            );
        }

        if (content.length() > 5000) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "El mensaje no puede superar los 5000 caracteres"
            );
        }

        String receiverId =
                conversation.getParticipantIds()
                        .stream()
                        .filter(id ->
                                !id.equals(currentUser.getId())
                        )
                        .findFirst()
                        .orElseThrow(() ->
                                new ResponseStatusException(
                                        HttpStatus.BAD_REQUEST,
                                        "No se encontró el destinatario"
                                )
                        );

        User receiver =
                userRepository.findById(receiverId)
                        .orElseThrow(() ->
                                new ResponseStatusException(
                                        HttpStatus.NOT_FOUND,
                                        "El destinatario no existe"
                                )
                        );

        validateChatAccount(receiver);

        Instant now = Instant.now();

        Message message = Message.builder()
                .conversationId(conversation.getId())
                .senderId(currentUser.getId())
                .receiverId(receiverId)
                .content(content)
                .type("TEXT")
                .createdAt(now)
                .expiresAt(
                        now.plus(24, ChronoUnit.HOURS)
                )
                .readAt(null)
                .build();

        Message savedMessage =
                messageRepository.save(message);

        MessageResponse response =
                toResponse(savedMessage);

        messagingTemplate.convertAndSend(
                "/topic/conversation/"
                + conversation.getId(),
                response
        );

        conversation.setUpdatedAt(now);

        conversationRepository.save(conversation);

        return response;
    }

    public List<MessageResponse> getMessages(
            String currentEmail,
            String conversationId
    ) {
        User currentUser = getCurrentUser(currentEmail);
        Conversation conversation = getConversation(conversationId);

        validateParticipant(conversation, currentUser.getId());

        Instant now = Instant.now();

        return messageRepository
                .findByConversationIdAndExpiresAtAfterOrderByCreatedAtAsc(
                        conversation.getId(),
                        now
                )
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public MessageResponse markAsRead(
            String currentEmail,
            String conversationId,
            String messageId
    ) {
        User currentUser = getCurrentUser(currentEmail);
        Conversation conversation = getConversation(conversationId);

        validateParticipant(conversation, currentUser.getId());

        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "El mensaje no existe o ya fue eliminado"
                ));

        if (!message.getConversationId().equals(conversation.getId())) {
            throw new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "El mensaje no pertenece a esta conversación"
            );
        }

        if (!message.getReceiverId().equals(currentUser.getId())) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Solo el destinatario puede marcar el mensaje como leído"
            );
        }

        if (!message.getExpiresAt().isAfter(Instant.now())) {
            throw new ResponseStatusException(
                    HttpStatus.GONE,
                    "El mensaje ya venció"
            );
        }

        if (message.getReadAt() == null) {
            message.setReadAt(Instant.now());
            message = messageRepository.save(message);
        }

        return toResponse(message);
    }

    private User getCurrentUser(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "Usuario autenticado no encontrado"
                ));
    }

    private Conversation getConversation(String conversationId) {
        return conversationRepository.findById(conversationId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "La conversación no existe"
                ));
    }

    private void validateParticipant(
            Conversation conversation,
            String userId
    ) {
        if (!conversation.getParticipantIds().contains(userId)) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "No tienes acceso a esta conversación"
            );
        }
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

    private MessageResponse toResponse(Message message) {
        return new MessageResponse(
                message.getId(),
                message.getConversationId(),
                message.getSenderId(),
                message.getReceiverId(),
                message.getContent(),
                message.getType(),
                message.getCreatedAt(),
                message.getExpiresAt(),
                message.getReadAt()
        );
    }
}