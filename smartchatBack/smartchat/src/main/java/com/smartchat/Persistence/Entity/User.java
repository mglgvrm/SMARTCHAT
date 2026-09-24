package com.smartchat.Persistence.Entity;

import com.smartchat.Persistence.Entity.Enums.AuthProvider;
import com.smartchat.Persistence.Entity.Enums.Role;
import com.smartchat.Persistence.Entity.Enums.SubscriptionPlan;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Document(collection = "users")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    private String id;

    // ==========================
    // AUTENTICACIÓN
    // ==========================

    private String email;

    private String password;

    private AuthProvider provider;

    private String providerId;

    private Boolean emailVerified;

    private Boolean profileCompleted;

    // ==========================
    // PERFIL
    // ==========================

    private String username;

    private String fullName;

    private LocalDate birthDate;

    private String bio;

    private String country;

    private String profilePicture;

    private String coverPhoto;

    // ==========================
    // PLAN Y ROLES
    // ==========================

    private Role role;

    private SubscriptionPlan subscriptionPlan;

    // ==========================
    // ECONOMÍA
    // ==========================

    private Long coins;

    private Long tickets;

    // ==========================
    // ESTADÍSTICAS
    // ==========================

    private Long followers;

    private Long following;

    private Long posts;

    private Long totalLikesReceived;

    // ==========================
    // ESTADO
    // ==========================

    private Boolean online;

    private Boolean active;

    private Boolean banned;

    private Boolean verifiedCreator;

    private LocalDateTime lastConnection;

    // ==========================
    // CONFIGURACIONES
    // ==========================

    private PrivacySettings privacy;

    private NotificationSettings notifications;

    // ==========================
    // AUDITORÍA
    // ==========================

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;
}