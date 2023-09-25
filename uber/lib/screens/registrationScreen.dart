// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;






import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber/allWidgets/progressDialog.dart';
import 'package:uber/configMaps.dart';
import 'package:uber/screens/loginScreen.dart';
import 'package:uber/screens/mainScreen.dart';
import 'package:uber/screens/riderService.dart';

class RegistrationScreen extends StatelessWidget{

  static const String idScreen = "register";

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  riderService ridersService = riderService(); 

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              SizedBox(height: 65.0,),
              Image(
                image: AssetImage('images/logo.png'),
                width: 350.0,
                height: 350.0,
                alignment: Alignment.center,
              ),
              SizedBox(height: 1,),
              Text(
                'Register as Rider',
                style: TextStyle(fontSize: 24, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
                ),
        
        
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    // ignore: prefer_const_literals_to_create_immutables
                          children: [
        
                            SizedBox(height: 1,),
                            TextField(
                              controller: nameTextEditingController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "Name",
                                labelStyle: TextStyle(
                                  fontSize: 14
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                )
                              ),
                              style: TextStyle(fontSize: 14),
                            ),


                            SizedBox(height: 1,),
                            TextField(
                              controller: emailTextEditingController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(
                                  fontSize: 14
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                )
                              ),
                              style: TextStyle(fontSize: 14),
                            ),


                            SizedBox(height: 1,),
                            TextField(
                              controller: phoneTextEditingController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Phone number",
                                labelStyle: TextStyle(
                                  fontSize: 14
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                )
                              ),
                              style: TextStyle(fontSize: 14),
                            ),
        
        
                            SizedBox(height: 1,),
                            TextField(
                              controller: passwordTextEditingController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(
                                  fontSize: 14
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                )
                              ),
                              style: TextStyle(fontSize: 14),
                            ),
        
        
                            SizedBox(height: 10,),
                            ElevatedButton(
                              onPressed: () {
                                if(nameTextEditingController.text.length < 4){
                                  displayToastMessage("Name must be at least four characters.", context);
                                }
                                else if(!emailTextEditingController.text.contains('@')){
                                  displayToastMessage("Email is invalid", context);
                                }
                                else if(phoneTextEditingController.text.isEmpty){
                                  displayToastMessage("Phone number mandatory", context);
                                }
                                else if(passwordTextEditingController.text.length < 7){
                                  displayToastMessage("Password must be at least six characters", context);
                                }
                                else{
                                  saveUser(nameTextEditingController.text, emailTextEditingController.text, phoneTextEditingController.text, passwordTextEditingController.text, context);
                                }                                
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,
                                foregroundColor: Colors.white,
                                // primary: Colors.yellow,
                                // onPrimary: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                )
        
                              ),
                              child: Container(
                                height: 50.0,
                                child: Center(
                                  child: Text(
                                    "Create Account",
                                    style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
                                    ),
                                ),
                              )
                            ),
                    ],
                  ),
                ),
        
                TextButton(onPressed:() {
                  Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                }, 
                child: 
                Text(
                  "Already have an account? Login here.",
                )
                )
            ],
          ),
        ),
      )
    );

  }

  displayToastMessage(String message, BuildContext context){
    Fluttertoast.showToast(msg: message);
  }

  Future<bool> saveUser(
      String name, String email, String phone, String password, BuildContext context) async {
        showDialog(context: context, 
        barrierDismissible: false,
        builder: (BuildContext context)
        {
          return ProgressDialog(message: "Signing up, Please wait...",);
        }
        );
        //create uri
        var uri = Uri.parse("http://10.0.2.2:8080/api/v1/auth/register");
        //header
        Map<String, String> headers = {"Content-Type": "application/json"};
        //body
        Map data = {
          'name': '$name',
          'email': '$email',
          'phone': '$phone',
          'password': '$password',
        };
        //convert the above data into json
        var body = json.encode(data);
        var response = await http.post(uri, headers: headers, body: body);

        //print the response body
        print("${response.body}");

        if ( response.body == '{"token":"null"}'){
          print("null not registered");
          return false;
          

        }
        else{
          print("registered");
          displayToastMessage("Your account has been created", context);
          userEmail = '$email';
          print("Your email is " + userEmail);
          Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
          return true;

        }
    
  }
  


}



