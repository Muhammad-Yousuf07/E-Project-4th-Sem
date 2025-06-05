import 'dart:async';
import 'package:authentication/services/authentication.dart';
import 'package:authentication/widgets/auth_guard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/HomePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? uuid;
  late Duration _remainingTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final endTime = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _remainingTime = endTime.difference(now);

    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final endTime = DateTime(now.year, now.month, now.day, 23, 59, 59);
      setState(() {
        _remainingTime = endTime.difference(now);
      });
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uuid = user.uid;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        drawer: SideDrawer(),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
            backgroundColor: Color(0xFF0e99c9),
            iconTheme: IconThemeData(color: Colors.white, size: 26),
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "⌚ Flash Sale Ends In ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
                _buildStaticTimer(), // placed next to title
              ],
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await AuthenticationHelper().signOut();
                  Navigator.pushReplacementNamed(context, "/LoginPage");
                },
                icon: Icon(Icons.logout_outlined),
              ),
            ],
          ),
        ),
        body: Container(
          color: Color(0xFFeeeeee),
          child: Center(
            child: Text(
              "Coming Soon",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaticTimer() {
    final hours = _remainingTime.inHours.toString().padLeft(2, '0');
    final minutes = (_remainingTime.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime.inSeconds % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _timeUnitBox(value: hours),
        Text(":", style: TextStyle(color: Colors.white, fontSize: 20)),
        _timeUnitBox(value: minutes),
        Text(":", style: TextStyle(color: Colors.white, fontSize: 20)),
        _timeUnitBox(value: seconds),
      ],
    );
  }

  Widget _timeUnitBox({required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0e99c9),
        ),
      ),
    );
  }
}
