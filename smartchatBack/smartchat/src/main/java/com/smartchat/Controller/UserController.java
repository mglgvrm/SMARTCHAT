package com.smartchat.Controller;

import com.smartchat.Controller.models.UserCardResponse;
import com.smartchat.Domain.Service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/chatable")
    public ResponseEntity<List<UserCardResponse>> getChatableUsers(
            @RequestHeader("Authorization") String authorizationHeader) {

        if (authorizationHeader == null ||
            !authorizationHeader.startsWith("Bearer ")) {

            return ResponseEntity.badRequest().build();
        }

        List<UserCardResponse> users =
                userService.getChatableUsers(authorizationHeader.replace("Bearer ",""));

        return ResponseEntity.ok(users);
    }
}
