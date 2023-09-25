package com.ekow.uber.rider;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RiderRepository extends JpaRepository <Rider, Integer>{

    Optional<Rider> findByEmail(String email);
    //    Optional<Client> findByRole();
    List<Rider> findAllByRole(Role role);
    Rider findUserByEmailIs(String email);

}
