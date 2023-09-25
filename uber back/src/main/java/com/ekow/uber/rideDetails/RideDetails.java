package com.ekow.uber.rideDetails;

import com.ekow.uber.rider.Role;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "ride_details")
public class RideDetails {
    @jakarta.persistence.Id
    @GeneratedValue//(strategy = GenerationType.SEQUENCE)
    @JsonProperty("id")
    private Integer Id;
    private String driver_id;
    private String payment_method;
    private String pickUpLatitude;
    private String pickUpLongitude;
    private String dropOffLatitude;
    private String dropOffLongitude;
    private String created_at;
    private String rider_email;
    private String pickUp_address;
    private String dropOff_address;
}
