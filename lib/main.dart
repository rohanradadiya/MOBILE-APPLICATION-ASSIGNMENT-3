import 'package:flutter/material.dart';
import 'home_screen.dart';

//represents the main entry point of the Food Ordering application.
void main() {
  runApp(MyApp());
}

//represents the main widget of the application.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //represents the title of the application - shown on the home page.
      title: 'Food Ordering App by RR',
      theme: ThemeData(
        //represents the main colour of the application.
        primarySwatch: Colors.blue,
      ),
      //home screen of the app.
      home: HomeScreen(),
    );
  }
}


