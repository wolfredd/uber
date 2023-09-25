import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class riderService {
  //create the method to save user

  bool validated = false;

  Future<bool> saveUser(
      String name, String email, String phone, String password) async {
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
      validated = false;
      return false;
      

    }
    else{
      print("registered");
      validated = true;
      print("validated = " + validated.toString());
      return true;

    }
  }
}
