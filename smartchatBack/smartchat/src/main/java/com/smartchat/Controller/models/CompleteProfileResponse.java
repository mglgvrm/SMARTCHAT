package com.smartchat.Controller.models;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CompleteProfileResponse {

    private String userId;

    private Boolean profileCompleted;
}