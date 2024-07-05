// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/login_screen.dart';
import 'Screens/splash_screen.dart'; // Import the splash screen
import 'Vedio/vedio_viewer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test',
      home: SplashScreenPage(),
    );
  }
}

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3)); // Set duration here
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const TestPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _checkLoginState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(); // Show the splash screen while waiting
        } else if (snapshot.hasData) {
          var userData = snapshot.data!;
          return VideoScreen(
            dbRef: FirebaseDatabase.instance
                .ref()
                .child('users')
                .child(userData['uid']),
            username: userData['username'],
            email: userData['email'],
          );
        } else {
          return const LoginScreen(title: 'Login');
        }
      },
    );
  }

  Future<Map<String, dynamic>?> _checkLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      String? uid = prefs.getString('uid');
      String? username = prefs.getString('username');
      String? email = prefs.getString('email');
      if (uid != null && username != null && email != null) {
        return {'uid': uid, 'username': username, 'email': email};
      }
    }
    return null;
  }
}
