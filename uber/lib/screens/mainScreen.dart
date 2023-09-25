import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber/DataHandler/appData.dart';
import 'package:uber/Models/directDetails.dart';
import 'package:uber/allWidgets/Divider.dart';
import 'package:uber/allWidgets/progressDialog.dart';
import 'package:uber/assistants/assistantMethods.dart';
import 'package:uber/configMaps.dart';
import 'package:uber/screens/loginScreen.dart';
import 'package:uber/screens/searchScreen.dart';




// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget 
{
  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin
{
  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();
  late GoogleMapController newGoogleMapController;  

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  DirectionDetails? tripDirectionDetails;
  String tripDistanceText = "";

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  
  Position? currentPosition;
  var geolocator = Geolocator();
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailsContainerHeight = 0.0;
  double requestRideDetailsContainerHeight = 0.0;
  double searchContainerHeight = 320.0;

  bool drawerOpen = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    AssistantMethods.getCurrentOnlineUserInfo();
  }

  void saveRideRequest() async
  {
    var pickUp = Provider.of<AppData>(context, listen:false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen:false).dropOffLocation;

    Map pickUpLocMap = 
    {
      "latitude": pickUp?.latitude.toString(),
      "longitude": pickUp?.longitude.toString()

    };

    Map dropOffLocMap = 
    {
      "latitude": dropOff?.latitude.toString(),
      "longitude": dropOff?.longitude.toString()

    };

    Map rideInfoMap = 
    {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickUpLat": pickUp?.latitude.toString(),
      "pickUpLong": pickUp?.longitude.toString(),
      "dropOffLat": dropOff?.latitude.toString(),
      "dropOffLong": dropOff?.longitude.toString(),
      "created_at": DateTime.now().toString(),
      "rider_name": userEmail,
      "pickUp_address": pickUp?.placeName,
      "dropOff_address": dropOff?.placeName,

    };


    var uri = Uri.parse("http://10.0.2.2:8080/api/v1/auth/ride");

    Map<String, String> headers = {"Content-Type": "application/json"};
        //body
    Map data = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickUpLatitude": pickUp?.latitude.toString(),
      "pickUpLongitude": pickUp?.longitude.toString(),
      "dropOffLatitude": dropOff?.latitude.toString(),
      "dropOffLongitude": dropOff?.longitude.toString(),
      "created_at": DateTime.now().toString(),
      "rider_email": userEmail,
      "pickUp_address": pickUp?.placeName,
      "dropOff_address": dropOff?.placeName,
    };

    var body = json.encode(data);
    var response = await http.post(uri, headers: headers, body: body);
    rideDetailId = response.body;
    print(rideDetailId);

    print("${response.body}");
  }

  void cancelRideRequest() async
  {
    var uri = Uri.parse("http://10.0.2.2:8080/api/v1/auth/delete");

    Map<String, String> headers = {"Content-Type": "application/json"};
    Map data = {
      "id": rideDetailId,
    };

    var body = json.encode(data);
    var response = await http.delete(uri, headers: headers, body: body);


    print("${response.body}");

  }

  void displayRequestRideContainer()
  {
    setState(() {
      requestRideDetailsContainerHeight = 300.0;
      rideDetailsContainerHeight = 0.0;
      bottomPaddingOfMap = 0;
      drawerOpen = true;
    });

    saveRideRequest();
  }

  resetApp()
  {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 320.0;
      rideDetailsContainerHeight = 0.0;
      bottomPaddingOfMap = 230.0;
      requestRideDetailsContainerHeight = 0;
      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });
    locatePosition();
  }
  void displayRideDetailsContainer() async
  {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0.0;
      rideDetailsContainerHeight = 300.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = false;
    });
  }


  void locatePosition() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    AssistantMethods assistantMethods = new AssistantMethods();

    String address = await  assistantMethods.searchCoordinateAddress(position, context);
    print("This is your address :: "+ address);
    print("Your email is \n and \n and \n and \n" + userEmail);




  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Main Screen"),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [

              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset("images/user_icon.png", height: 65.0, width: 65.0,),
                      SizedBox(width: 16.0,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Profile Name", style: TextStyle(fontSize: 16.0, fontFamily: "Brand-Bold"),),
                          SizedBox(height: 6.0,),
                          Text("Visit Profile"),
                        ],
                      )
                    ],
                  )
                ),
              ),

              DividerWidget(),

              SizedBox(height: 12.0,),


              ListTile(
                leading: Icon(Icons.history),
                title: Text("History", style: TextStyle(fontSize: 15.0),),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Visit Profile", style: TextStyle(fontSize: 15.0),),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text("About", style: TextStyle(fontSize: 15.0),),
              ),
              GestureDetector(
                onTap: ()
                {
                  userEmail = "";
                  Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text("Sign out", style: TextStyle(fontSize: 15.0),),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true, 
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 200;
              });

              locatePosition();
              
            },
          ),


          Positioned(
            top: 38.0,
            left: 22.0,
            child: GestureDetector(
              onTap: ()
              {
                if(drawerOpen)
                {
                  scaffoldKey.currentState?.openDrawer();
                }
                else
                {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7
                        )
                    )
                  ]
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon((drawerOpen) ? Icons.menu : Icons.close, color: Colors.black,),
                  radius: 20.0,
                ),
              ),
            ),
          ),

          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: GestureDetector(

              onTap: () async
              {
                var res = await Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));

                if(res == "obtainDirection")
                {
                  displayRideDetailsContainer();
                };
              },
              child: AnimatedSize(
                curve: Curves.bounceIn,
                duration: new Duration(milliseconds: 160),
                child: Container(
                  height: searchContainerHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6.0,),
                        Text("Hi there!", style: TextStyle(fontSize: 12.0),),
                        Text("Where to!", style: TextStyle(fontSize: 20.0, fontFamily: "Brand-Bold"),),
                        SizedBox(height: 20.0,),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 6.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              )
                            ]
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.blueAccent,),
                                SizedBox(width: 10.0),
                                Text("Search drop off")
                              ],
                            ),
                          ),
                        ),
                          
                        SizedBox(height: 24.0,),
                        Row(
                          children: [
                            Icon(Icons.home, color: Colors.grey,),
                            SizedBox(width: 12.0,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [                        
                                Text(
                                  Provider.of<AppData>(context).pickUpLocation?.placeName ?? "Add Home",
                                ),                              
                                SizedBox(height: 4.0,),
                                Text("Your living home address", style: TextStyle(color: Colors.black54, fontSize: 12.0))
                              ],
                            )
                          ],
                        ),
                          
                        SizedBox(height: 24.0,),
                          
                        DividerWidget(),
                          
                        SizedBox(height: 16.0),
                          
                        Row(
                          children: [
                            Icon(Icons.work, color: Colors.grey,),
                            SizedBox(width: 12.0,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Add work"),
                                SizedBox(height: 4.0,),
                                Text("Your office address", style: TextStyle(color: Colors.black54, fontSize: 12.0))
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ),

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ), 
                  ]
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 17.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.tealAccent[100],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset("images/taxi.png", height: 70.0, width: 80.0,),
                              SizedBox(width: 16.0,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Car", style: TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold"),
                                  ),
                                  Text(
                                    ((tripDirectionDetails != null) ? tripDistanceText : ''), style: TextStyle(fontSize: 18.0, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container()),
                                Text(
                                    ((tripDirectionDetails != null) ? '\$${AssistantMethods.calculateFares(tripDirectionDetails!)}' : ''), style: TextStyle(fontSize: 18.0, color: Colors.grey),
                                  ),                
                            ],
                          ),
                          ),
                      ),
                      SizedBox(height: 20.0,),
            
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.moneyCheckAlt, size: 18.0, color: Colors.black54,),
                            Text("Cash"),
                            SizedBox(width: 6.0,),
                            Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16.0,),
                          ],
                        ),
                      ),
            
                      SizedBox(height: 24.0,),
            
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: ()
                          {
                            displayRequestRideContainer();
                          },
                          child: Padding(
                            padding: EdgeInsets.all(17.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Request", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                                Icon(FontAwesomeIcons.taxi, color: Colors.white, size: 26.0,),
                              ],
                            ),
                            ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
            
                    ],
                  ),
                ),
              ),
            )
          ),

          Positioned(
            bottom: 0.0,
            right: 0.0,
            left: 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 0.5,
                    blurRadius: 16.0,
                    color: Colors.black54,
                    offset: Offset(0.7, 0.7),
                  )
                ]
              ),
              height: requestRideDetailsContainerHeight,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    SizedBox(height: 12.0,),
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          ColorizeAnimatedText('Requesting a ride...', textStyle: TextStyle(fontSize: 55.0, fontFamily: 'Signatra',),
                          colors:  [
                              Colors.green,
                                Colors.purple,
                                Colors.pink,
                                Colors.blue,
                                Colors.yellow,
                                Colors.red,
                              ],
                          ),
                          ColorizeAnimatedText('Please wait...', textStyle: TextStyle( fontSize: 55.0, fontFamily: 'Signatra',),
                            colors:  [
                                  Colors.purple,
                                  Colors.blue,
                                  Colors.yellow,
                                  Colors.red,
                              ],
                          ),
                          ColorizeAnimatedText('Finding a driver...', textStyle: TextStyle( fontSize: 55.0, fontFamily: 'Signatra',),
                            colors:  [
                                  Colors.purple,
                                  Colors.blue,
                                  Colors.yellow,
                                  Colors.red,
                              ],
                          ),
                        ],
                        isRepeatingAnimation: true, 
                        onTap: () {
                          print("Tap Event");
                          },
                      ),
                    ),
              
                    SizedBox(height: 22.0),
              
                    GestureDetector(
                      onTap: () 
                      {
                        resetApp();
                        cancelRideRequest();
                      },
                      child: Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.0),
                          border: Border.all(width: 2.0, color: Colors.grey),
                        ),
                        child: Icon(Icons.close, size: 26.0,),
                      ),
                    ),
              
                    SizedBox(height: 10.0),
              
                    Container(
                      width: double.infinity,
                      child: Text('Cancel ride', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0),),
                    )
              
              
                  ],
                ),
              ),
            ),
          )

        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async
  {
    var initialPos = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos!.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos!.latitude, finalPos.longitude);

    showDialog(context: context,
     builder: (BuildContext context) => ProgressDialog(message: "Please wait...")
    );

    var details = await AssistantMethods.obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);

    setState(() {
      tripDirectionDetails = details;
      tripDistanceText = tripDirectionDetails?.distanceText as String;
    });

    Navigator.pop(context);

    print("this is Encoded Points :: ");
    print(details!.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    String encodedPoints = details.encodedPoints as String;

    List<PointLatLng> decodePolylinePointsResult = polylinePoints.decodePolyline(encodedPoints);

    pLineCoordinates.clear();

    if(decodePolylinePointsResult.isNotEmpty)
    {
      decodePolylinePointsResult.forEach((PointLatLng pointLatLng) 
      {
        pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
      );
    }

    polylineSet.clear;

    setState(() {
      Polyline polyline = Polyline(
      color: Colors.pink,
      polylineId: PolylineId("PolylineID"),
      jointType: JointType.round,
      points: pLineCoordinates,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );

    polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;

    if(pickUpLatLng.latitude > dropOffLatLng.latitude && pickUpLatLng.longitude > dropOffLatLng.longitude)
    {
      latLngBounds = LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    }

    else if(pickUpLatLng.longitude > dropOffLatLng.longitude)
    {
      latLngBounds = LatLngBounds(southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude), northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    }

    else if(pickUpLatLng.latitude > dropOffLatLng.latitude)
    {
      latLngBounds = LatLngBounds(southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude), northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    }

    else
    {
      latLngBounds = LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: initialPos.placeName, snippet: "My Location"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId")
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "My Destination"),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId")
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.yellow,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.yellowAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.red,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.redAccent,
      circleId: CircleId("dropOffId"),
    );

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
      
    });

  }
}
