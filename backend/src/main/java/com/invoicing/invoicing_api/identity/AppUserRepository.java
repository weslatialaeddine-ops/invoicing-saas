package com.invoicing.invoicing_api.identity;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface AppUserRepository extends JpaRepository<AppUser, UUID> {
    List<AppUser> findByEmail(String email);
}