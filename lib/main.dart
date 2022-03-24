import 'package:bill_tracker/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'landing_page.dart';

Future<void> main() async {

  if(Firebase.apps.isEmpty){
    try{
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(// Replace with actual values
        options: const FirebaseOptions(
          apiKey: "AIzaSyC8EnyWlxcygDAuZjN3zp4NZ6M3AOkw3pg",
          appId: "1:758569299108:android:ed26338d2b3e1b72cb4a31",
          messagingSenderId: "758569299108",
          projectId: "billtracker-4d9f3",
        ),);


    }catch(e){
      print(e);
    }
  }
  else{
    Firebase.app();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BillTracker',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: LandingPage(
        auth: Auth(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
