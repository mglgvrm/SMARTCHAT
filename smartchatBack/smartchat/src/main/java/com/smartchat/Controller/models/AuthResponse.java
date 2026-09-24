package com.smartchat.Controller.models;

import com.smartchat.Persistence.Entity.Enums.Role;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AuthResponse {

    private String token;

    private String refreshToken;

    private Boolean profileCompleted;

    private String userId;

    private Role role;
}