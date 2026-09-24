package com.smartchat.Domain.Service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.smartchat.Controller.models.*;
import com.smartchat.Domain.Dto.FirebaseAuthRequest;
import com.smartchat.Persistence.Entity.Enums.AuthProvider;
import com.smartchat.Persistence.Entity.Enums.Role;
import com.smartchat.Persistence.Entity.Enums.SubscriptionPlan;
import com.smartchat.Persistence.Entity.User;
import com.smartchat.Persistence.Repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;

    private final PasswordEncoder passwordEncoder;

    private final JwtService jwtService;

    public AuthResponse register(RegisterRequest request){

        if(userRepository.existsByEmail(request.getEmail())){

            throw new RuntimeException(
                    "El correo ya existe"
            );
        }

        User user = User.builder()
                .email(request.getEmail())
                .password(
                        passwordEncoder.encode(
                                request.getPassword()
                        )
                )
                .provider(AuthProvider.LOCAL)
                .emailVerified(false)
                .profileCompleted(false)
                .role(Role.USER)
                .subscriptionPlan(
                        SubscriptionPlan.FREE
                )
                .coins(0L)
                .tickets(0L)
                .followers(0L)
                .following(0L)
                .posts(0L)
                .active(true)
                .banned(false)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        userRepository.save(user);

        String token =
                jwtService.generateToken(user.getEmail());

        return AuthResponse.builder()
                .token(token)
                .profileCompleted(false)
                .userId(user.getId())
                .build();
    }

    public AuthResponse login(LoginRequest request){

        User user = userRepository
                .findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Credenciales inválidas"));
        System.out.println( "###############################################" +request.getEmail() );

        boolean matches =
                passwordEncoder.matches(
                        request.getPassword(),
                        user.getPassword()
                );

        if(!matches){

            throw new RuntimeException(

                    "Credenciales inválidas"
            );
        }

        String token =
                jwtService.generateToken(
                        user.getEmail()
                );

        return AuthResponse.builder()
                .token(token)
                .profileCompleted(
                        user.getProfileCompleted()
                )
                .role(user.getRole())
                .userId(user.getId())
                .build();
    }

    public AuthResponse firebaseLoginGoogle(
            FirebaseAuthRequest request
    ) {

        try {

            FirebaseToken decodedToken =
                    FirebaseAuth.getInstance()
                            .verifyIdToken(
                                    request.getFirebaseToken()
                            );

            String email =
                    decodedToken.getEmail();

            User user =
                    userRepository.findByEmail(email)
                            .orElseGet(() -> {

                                User newUser =
                                        User.builder()
                                                .email(email)
                                                .provider(AuthProvider.GOOGLE)
                                                .emailVerified(true)
                                                .profileCompleted(false)
                                                .role(Role.USER)
                                                .subscriptionPlan(
                                                        SubscriptionPlan.FREE
                                                )
                                                .coins(0L)
                                                .tickets(0L)
                                                .followers(0L)
                                                .following(0L)
                                                .posts(0L)
                                                .active(true)
                                                .banned(false)
                                                .createdAt(
                                                        LocalDateTime.now()
                                                )
                                                .updatedAt(
                                                        LocalDateTime.now()
                                                )
                                                .build();

                                return userRepository.save(
                                        newUser
                                );
                            });

            String jwt =
                    jwtService.generateToken(
                            user.getEmail()
                    );

            return AuthResponse.builder()
                    .token(jwt)
                    .userId(user.getId())
                    .profileCompleted(
                            user.getProfileCompleted()
                    )
                    .role(user.getRole())
                    .build();

        } catch (Exception e) {

            throw new RuntimeException(
                    "Firebase Token inválido"
            );
        }
    }

    public AuthResponse completeProfile(
            String token,
            CompleteProfileRequest request
    ) {
        System.out.println("TOKEN: " + token);
        String email =
                jwtService.extractUsername(token);

        System.out.println("EMAIL: " + email);

        User user =
                userRepository.findByEmail(email)
                        .orElseThrow();

        if(
                userRepository.existsByUsername(
                        request.getUsername()
                )
        ){

            throw new RuntimeException(
                    "Username ya existe"
            );
        }

        user.setUsername(
                request.getUsername()
        );

        user.setFullName(
                request.getFullName()
        );

        user.setBirthDate(
                LocalDate.parse(
                        request.getBirthDate()
                )
        );

        user.setProfileCompleted(
                true
        );

        user.setUpdatedAt(
                LocalDateTime.now()
        );

        User userRol = userRepository.save(user);
 System.out.println(userRol.getRole());
        return AuthResponse.builder()
                .token(token)
                .userId(user.getId())
                .profileCompleted(true)
                .role(userRol.getRole())
                .build();
    }
}