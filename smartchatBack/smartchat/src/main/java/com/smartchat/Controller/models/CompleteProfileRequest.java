package com.smartchat.Controller.models;

import lombok.Data;

@Data
public class CompleteProfileRequest {

    private String username;

    private String fullName;

    private String birthDate;
}