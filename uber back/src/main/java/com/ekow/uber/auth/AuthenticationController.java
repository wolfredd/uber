package com.ekow.uber.auth;

import ch.qos.logback.core.net.server.Client;
import com.ekow.uber.rideDetails.RideDetails;
import com.ekow.uber.rider.Rider;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@Controller
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthenticationController {

    private final AuthenticationService authenticationService;

    @GetMapping("/getallclients")
    public ResponseEntity<List> getAllClients(){
        return ResponseEntity.ok(authenticationService.getAllRiders());
    }

    @PostMapping("/register")
    public ResponseEntity<AuthenticationResponse> register(@RequestBody RegisterRequest request){
        AuthenticationResponse response =authenticationService.register(request);
        if (response == null) {
            AuthenticationResponse nulll = new AuthenticationResponse("null");
            return ResponseEntity.badRequest().body(nulll);
        }
        return ResponseEntity.ok(response);
    }

    @PostMapping("/authenticate")
    public ResponseEntity<AuthenticationResponse> authenticate(@RequestBody AuthenticationRequest request){
        AuthenticationResponse response = authenticationService.authenticate(request);
        if (response == null) {
            AuthenticationResponse nulll = new AuthenticationResponse("null");
            return ResponseEntity.badRequest().body(nulll);
        }
        return ResponseEntity.ok(response);
    }

    @PostMapping("/current")
    public ResponseEntity<Rider> currentClient(@RequestBody RiderEmail email){
        Rider rider = authenticationService.getCurrentRider(email);
//        if (rider == null) {
//            AuthenticationResponse nulll = new AuthenticationResponse("null");
//            return ResponseEntity.badRequest().body(nulll);
//        }
        return ResponseEntity.ok(rider);
    }

    @PostMapping("/ride")
    public ResponseEntity<Integer> ride(@RequestBody RideDetails ride){
        Integer rideDetailId = authenticationService.addRide(ride);
//        if (rider == null) {
//            AuthenticationResponse nulll = new AuthenticationResponse("null");
//            return ResponseEntity.badRequest().body(nulll);
//        }
        return ResponseEntity.ok(rideDetailId);
    }

    @DeleteMapping("/delete")
    public ResponseEntity<String> delete(@RequestBody RideDetailIdNumber rideDetailIdNumber){
        String success = authenticationService.removeRide(rideDetailIdNumber);
//        if (rider == null) {
//            AuthenticationResponse nulll = new AuthenticationResponse("null");
//            return ResponseEntity.badRequest().body(nulll);
//        }
        return ResponseEntity.ok(success);
    }

}


