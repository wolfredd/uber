import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber/configMaps.dart';
import 'package:uber/screens/loginScreen.dart';
import 'package:uber/screens/mainScreen.dart';
import 'package:uber/screens/registrationScreen.dart';

import 'DataHandler/appData.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Uber Rider',
        theme: ThemeData(
          fontFamily: "Brand Bold",
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: userEmail == "" ? RegistrationScreen.idScreen : MainScreen.idScreen,
        routes: 
        {
          RegistrationScreen.idScreen: (context) => RegistrationScreen(),
          LoginScreen.idScreen: (context) => LoginScreen(),
          MainScreen.idScreen: (context) => MainScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
