package com.smartchat.Config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.auth.oauth2.ServiceAccountCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import org.springframework.context.annotation.Configuration;

import java.util.Collections;

@Configuration
public class FirebaseConfig {

    @PostConstruct
    public void initialize() {

        try {

            String privateKeyId = require("FIREBASE_PRIVATE_KEY_ID");
            String clientEmail  = require("FIREBASE_CLIENT_EMAIL");
            String clientId     = require("FIREBASE_CLIENT_ID");

            // Único punto donde se convierte el "\n" literal en salto de línea real
            String privateKey = require("FIREBASE_PRIVATE_KEY").replace("\\n", "\n");

            GoogleCredentials credentials = ServiceAccountCredentials.fromPkcs8(
                    clientId,
                    clientEmail,
                    privateKey,
                    privateKeyId,
                    Collections.emptyList()
            );

            FirebaseOptions options =
                    FirebaseOptions.builder()
                            .setCredentials(credentials)
                            .setProjectId("smartchat-477f3")
                            .build();

            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
            }

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private String require(String envVar) {
        String value = System.getenv(envVar);
        if (value == null || value.isBlank()) {
            throw new IllegalStateException("Falta la variable de entorno: " + envVar);
        }
        return value;
    }
}