package com.ekow.uber.rider;

import org.springframework.web.bind.annotation.RestController;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;


@RestController
@RequestMapping("/api/v1/client")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class RiderController {

    private final RiderService riderService;



    @GetMapping("/currentRider")
    public ResponseEntity<Rider> returnCurrentRider(){
        return ResponseEntity.ok(riderService.getCurrentRider());
    }


    @PutMapping("/updateRiderEmail/{email}")
    public ResponseEntity<Rider> updateRiderEmail(
            @PathVariable("email") String email){
        return ResponseEntity.ok(riderService.updateRiderEmail(email));
    }

}
