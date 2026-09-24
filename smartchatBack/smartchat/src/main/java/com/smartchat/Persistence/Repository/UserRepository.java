package com.smartchat.Persistence.Repository;

import com.smartchat.Persistence.Entity.User;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends MongoRepository<User, String> {

    Optional<User> findByEmail(String email);

    Optional<User> findByUsername(String username);

    Boolean existsByEmail(String email);

    Boolean existsByUsername(String username);



    List<User> findByActiveTrueAndEmailNotAndRoleNot(
            String email,
            String role
    );

}
