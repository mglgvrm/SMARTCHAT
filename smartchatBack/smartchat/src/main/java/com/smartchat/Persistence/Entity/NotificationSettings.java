package com.smartchat.Persistence.Entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationSettings {

    private Boolean messages;

    private Boolean comments;

    private Boolean reactions;

    private Boolean followers;

    private Boolean missions;

    private Boolean events;

}
