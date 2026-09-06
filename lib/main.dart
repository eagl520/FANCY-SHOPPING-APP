import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart'; 
import 'Account/splash_screen.dart'; 


void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp( Shop());
}

class Shop extends StatelessWidget {
  const Shop({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FANCY',
      
      theme: ThemeData(
        
        
        useMaterial3: true, 
        
        
        colorSchemeSeed: const Color.fromARGB(255, 107, 106, 106), 
        
        
        scaffoldBackgroundColor: const Color.fromARGB(255, 136, 135, 135),
        
        
        
      ),
      home: const  SplashScreen(),
    );
  }
}