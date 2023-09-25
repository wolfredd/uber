import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber/DataHandler/appData.dart';
import 'package:uber/Models/address.dart';
import 'package:uber/Models/directDetails.dart';
import 'package:uber/Models/user.dart';
import 'package:uber/assistants/requestAssistant.dart';
import 'package:uber/configMaps.dart';







import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
class AssistantMethods
{
  Future<String> searchCoordinateAddress(Position position, context) async
  {
    String placeAddress = "";
    String st1, st2, st3, st4;   
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyC6OBHn1YYVTSgcWMcaELlyGgzHQTJrof0";

    var response = await RequestAssistant.getRequest(url);

    if(response != "failed")
    {
      // placeAddress = response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][3]["long_name"];
      st2 = response["results"][0]["address_components"][4]["long_name"];
      st3 = response["results"][0]["address_components"][5]["long_name"];
      st4 = response["results"][0]["address_components"][6]["long_name"];
      placeAddress = st1 + ", " + st2;

      Address userPickUpAddress = new Address.nulll();
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async
  {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?destination=${finalPosition.latitude},${finalPosition.longitude}&origin=${initialPosition.latitude},${initialPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(directionUrl);

    if(res == "failed")
    {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];

    directionDetails.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText = res["routes"][0]["legs"][0]["duration"]["text"];

    directionDetails.durationValue = res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails)
  {
    double timeTraveledFare = (directionDetails.durationValue! / 60) * 0.20;
    double distanceTraveledFare = (directionDetails.distanceValue! / 1000) * 0.20;
    double totalFare =  timeTraveledFare + distanceTraveledFare;
    double inCedis = totalFare * 12;

    return inCedis.truncate();
  }

  static void getCurrentOnlineUserInfo() async
  {
    print("From assistant methods your email is " + userEmail);



    var uri = Uri.parse("http://10.0.2.2:8080/api/v1/auth/current");

    Map<String, String> headers = {"Content-Type": "application/json"};
        //body
    Map data = {
      'email': '$userEmail',
    };

    var body = json.encode(data);
    var response = await http.post(uri, headers: headers, body: body);

    currentUser = response as User?;

    print("User email is " + currentUser!.email);
    print("User name is " + currentUser!.name);
    print("User phone is " + currentUser!.phone);

  }
}