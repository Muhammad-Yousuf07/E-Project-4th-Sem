import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


Future<void> _checkUserAndNavigate(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final role = doc.data()?['role'];
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/AdminPage');
    } else{
      Navigator.pushReplacementNamed(context, '/HomePage');
    }
  } else {
    Navigator.pushReplacementNamed(context, '/LaunchingPage');
  }



}

class LaunchingPage extends StatefulWidget {
  const LaunchingPage({super.key});
  static const String routeName = '/LaunchingPage';



  @override
  State<LaunchingPage> createState() => _LaunchingPageState();
}


class _LaunchingPageState extends State<LaunchingPage> {

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Mobile friendly check
    final isMobile = screenWidth < 650;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Color(0xFFeeeeee),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(14, 20, 14, 20),
            child: Center(
              child: SizedBox(
                width: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 60),
        
                    Container(
                      height: 250,
                      width: 350,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/banner_1.png"),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(height: 60),
        
                    Text(
                      'Discover timeless style at Watch Hub — your curated space for premium watches. Log in to explore iconic classics and modern designs.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 30),
        
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  child: TextButton(
                    onPressed: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        Navigator.pushReplacementNamed(context, "/LoginPage");
                      } else {
                        _checkUserAndNavigate(context); // Re-check role if user is already logged in
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF0e99c9),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // No rounded corners
                      ),
                    ),
                    child: Text(
                      "GET STARTED",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        letterSpacing: 5,
                      ),
                    ),
                  ),
                ),
                  ],
                ),
              ),
            )
        
          ),
        ),
      ),
    );
  }
}


