package com.smartchat.Persistence.Entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PrivacySettings {

    private Boolean allowMessages;

    private Boolean allowFollowers;

    private Boolean showOnlineStatus;

    private Boolean showBirthDate;

    private Boolean publicProfile;

}