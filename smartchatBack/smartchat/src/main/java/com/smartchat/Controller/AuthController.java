package com.smartchat.Controller;


import com.smartchat.Controller.models.*;
import com.smartchat.Domain.Dto.FirebaseAuthRequest;
import com.smartchat.Domain.Service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;


@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(
            @RequestBody RegisterRequest request
    ){
        System.out.println("ENTRO A REGISTER");

        return ResponseEntity.ok(
                authService.register(request)
        );
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {

        try {
            AuthResponse response = authService.login(request);

            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {

            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of(
                            "message", e.getMessage()
                    ));
        }
    }

    @PostMapping("/firebase/google")
    public ResponseEntity<AuthResponse> firebaseLoginGoogle(
            @RequestBody FirebaseAuthRequest request
    ) {

        return ResponseEntity.ok(
                authService.firebaseLoginGoogle(request)
        );
    }

    @PostMapping("/complete-profile")
    public ResponseEntity<AuthResponse> completeProfile(
            @RequestHeader("Authorization") String token,
            @RequestBody CompleteProfileRequest request
    ) {

        System.out.println("TOKEN: " + token);
        return ResponseEntity.ok(
                authService.completeProfile(
                        token.replace("Bearer ",""),
                        request
                )
        );
    }
}
