package com.smartchat.Controller;

import com.smartchat.Controller.models.ConversationResponse;
import com.smartchat.Controller.models.CreateMessageRequest;
import com.smartchat.Controller.models.MessageResponse;
import com.smartchat.Domain.Service.ConversationService;
import com.smartchat.Domain.Service.MessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/conversations")
@RequiredArgsConstructor
public class ConversationController {

    private final ConversationService conversationService;
    private final MessageService messageService;

    @PostMapping("/{otherUserId}")
    public ResponseEntity<ConversationResponse> getOrCreateConversation(
            Authentication authentication,
            @PathVariable String otherUserId
    ) {
        ConversationResponse response =
                conversationService.getOrCreateConversation(
                        authentication.getName(),
                        otherUserId
                );

        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<List<ConversationResponse>> getMyConversations(
            Authentication authentication
    ) {
        List<ConversationResponse> conversations =
                conversationService.getMyConversations(
                        authentication.getName()
                );

        return ResponseEntity.ok(conversations);
    }

    @GetMapping("/{conversationId}/messages")
    public ResponseEntity<List<MessageResponse>> getMessages(
            Authentication authentication,
            @PathVariable String conversationId
    ) {
        List<MessageResponse> messages =
                messageService.getMessages(
                        authentication.getName(),
                        conversationId
                );

        return ResponseEntity.ok(messages);
    }

    @PostMapping("/{conversationId}/messages")
    public ResponseEntity<MessageResponse> sendMessage(
            Authentication authentication,
            @PathVariable String conversationId,
            @RequestBody CreateMessageRequest request
    ) {
        MessageResponse response =
                messageService.sendMessage(
                        authentication.getName(),
                        conversationId,
                        request
                );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }

    @PostMapping("/{conversationId}/messages/{messageId}/read")
    public ResponseEntity<MessageResponse> markAsRead(
            Authentication authentication,
            @PathVariable String conversationId,
            @PathVariable String messageId
    ) {
        MessageResponse response =
                messageService.markAsRead(
                        authentication.getName(),
                        conversationId,
                        messageId
                );

        return ResponseEntity.ok(response);
    }
}