package com.smartchat.Domain.Service;

import com.smartchat.Persistence.Entity.Enums.AuthProvider;
import com.smartchat.Persistence.Entity.Enums.Role;
import com.smartchat.Persistence.Entity.Enums.SubscriptionPlan;
import com.smartchat.Persistence.Entity.User;
import com.smartchat.Persistence.Repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class OAuth2SuccessHandler
        implements AuthenticationSuccessHandler {

    private final UserRepository userRepository;
    private final JwtService jwtService;

    @Override
    public void onAuthenticationSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication
    ) throws IOException {

        OAuth2User oauthUser =
                (OAuth2User) authentication.getPrincipal();

        String email =
                oauthUser.getAttribute("email");

        String providerId =
                oauthUser.getAttribute("sub");

        User user =
                userRepository.findByEmail(email)
                        .orElseGet(() -> {

                            User newUser =
                                    User.builder()

                                            .email(email)

                                            .provider(
                                                    AuthProvider.GOOGLE
                                            )

                                            .providerId(
                                                    providerId
                                            )

                                            .profileCompleted(false)

                                            .role(Role.USER)

                                            .subscriptionPlan(
                                                    SubscriptionPlan.FREE
                                            )

                                            .coins(0L)

                                            .build();

                            return userRepository.save(newUser);
                        });

        String token =
                jwtService.generateToken(
                        user.getEmail()
                );

        response.sendRedirect(
                "smartchat://auth?token=" + token
        );
    }
}