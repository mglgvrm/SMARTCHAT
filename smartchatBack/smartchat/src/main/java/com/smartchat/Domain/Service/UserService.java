package com.smartchat.Domain.Service;
import com.smartchat.Controller.models.UserCardResponse;
import com.smartchat.Persistence.Entity.User;
import com.smartchat.Persistence.Repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final JwtService jwtService;

    public List<UserCardResponse> getChatableUsers(String token) {

        System.out.println("TOKEN: " + token);
        String email =
                jwtService.extractUsername(token);

        List<User> users =
                userRepository.findByActiveTrueAndEmailNotAndRoleNot(
                        email,
                        "ADMIN"
                );

        for (User user : users) {
            System.out.println(
                    "ID: " + user.getId()
                    + " | EMAIL: " + user.getEmail()
                    + " | USERNAME: " + user.getUsername()
                    + " | ACTIVE: " + user.getActive()
                    + " | BANNED: " + user.getBanned()
            );
        }

        return users.stream()
                .filter(user -> Boolean.FALSE.equals(user.getBanned()))
                .map(this::mapToCard)
                .toList();
    }

    private UserCardResponse mapToCard(User user) {

        return UserCardResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .bio(user.getBio())
                .country(user.getCountry())
                .profilePicture(user.getProfilePicture())
                .online(user.getOnline())
                .verifiedCreator(user.getVerifiedCreator())
                .subscriptionPlan(
                        user.getSubscriptionPlan() != null
                                ? user.getSubscriptionPlan().name()
                                : null
                )
                .build();
    }
}