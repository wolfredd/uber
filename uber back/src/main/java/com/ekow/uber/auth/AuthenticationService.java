package com.ekow.uber.auth;

import com.ekow.uber.config.JwtService;
import com.ekow.uber.rideDetails.RideDetails;
import com.ekow.uber.rideDetails.RideDetailsRepository;
import com.ekow.uber.rider.Rider;
import com.ekow.uber.rider.RiderRepository;
import com.ekow.uber.rider.Role;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;













import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@RequiredArgsConstructor
@Service
public class AuthenticationService {

    private final RiderRepository riderRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final RideDetailsRepository rideDetailsRepository;

    public List getAllRiders(){
        List<Rider> riders =  riderRepository.findAllByRole(Role.CLIENT);
        System.out.println(riders);
        return riders;
    }

    public AuthenticationResponse register(RegisterRequest request) {

        Optional<Rider> riderOptional = riderRepository.findByEmail(request.getEmail());

        if(riderOptional.isEmpty()) {
            var user = Rider.builder().name(request.getName()).email(request.getEmail()).phone(request.getPhone()).password(passwordEncoder.encode(request.getPassword())).role(Role.CLIENT).build();
            riderRepository.save(user);
            var jwtToken = jwtService.generateToken(user);

            return AuthenticationResponse.builder().token(jwtToken).build();
        }
        else {
            return null;
        }
    }

    public AuthenticationResponse authenticate(AuthenticationRequest request) {
        authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword()));
        //var user = riderRepository.findByEmail(request.getEmail()).orElseThrow();
        Optional<Rider> riderOptional = riderRepository.findByEmail(request.getEmail());
//        if (user.getRole() == Role.CLIENT) {
//            var jwtToken = jwtService.generateToken(user);
//
//            return AuthenticationResponse.builder().token(jwtToken).build();
//        }
//
//        else {
//            return null;
//        }

        if(riderOptional.isPresent()) {
            var user = riderRepository.findByEmail(request.getEmail()).orElseThrow();
            var jwtToken = jwtService.generateToken(user);
            return AuthenticationResponse.builder().token(jwtToken).build();
        }
        else {
            return null;
        }


    }


    public Rider getCurrentRider(RiderEmail email) {
        String emaill = email.getEmail();
        return riderRepository.findByEmail(emaill).orElseThrow();
    }

    public Integer addRide(RideDetails ride) {
        rideDetailsRepository.save(ride);
        return ride.getId();
    }

    public String removeRide(RideDetailIdNumber rideId) {
        int id = Integer.parseInt(rideId.getId());
        rideDetailsRepository.deleteById(id);
        System.out.println("deleted");
        return "done";
    }

}

