package com.smartchat.Controller.models;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserCardResponse {

    private String id;

    private String username;

    private String fullName;

    private String bio;

    private String country;

    private String profilePicture;

    private Boolean online;

    private Boolean verifiedCreator;

    private String subscriptionPlan;
}