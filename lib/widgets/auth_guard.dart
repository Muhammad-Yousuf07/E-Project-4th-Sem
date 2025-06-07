import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;

  const AuthGuard({required this.child, super.key});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  bool isAllowed = false;

  @override
  void initState() {
    super.initState();
    checkUserRoleAndRedirect();
  }

  Future<void> checkUserRoleAndRedirect() async {
    final user = _auth.currentUser;

    if (user == null) {
      Navigator.pushReplacementNamed(context, "/LoginPage");
      return;
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      Navigator.pushReplacementNamed(context, "/LoginPage");
      return;
    }

    final role = doc['role'];
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (role != 'admin' && currentRoute == "/AdminPage") {
      Navigator.pushReplacementNamed(context, "/HomePage");
      return;
    }

    setState(() {
      isAllowed = true;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return widget.child;
  }
}
