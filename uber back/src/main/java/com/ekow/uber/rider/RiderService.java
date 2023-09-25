package com.ekow.uber.rider;

import com.ekow.uber.config.JwtService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class RiderService {

    private final JwtService jwtService;
    private final UserDetailsService userDetailsService;
    @Autowired
    private RiderRepository riderRepository;

    public Rider getCurrentRider(){
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userEmail = authentication.getName();
        //User user = .orElseThrow();
        Rider rider = riderRepository.findByEmail(userEmail).orElseThrow();

        return rider;
    }


    @Transactional
    public Rider updateRiderEmail(String email){

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userEmail = authentication.getName();

        Rider rider = riderRepository.findByEmail(userEmail).orElseThrow();

        if(email!=null){
            rider.setEmail(email);
        }

        return rider;
    }

}
