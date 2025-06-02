import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Future.microtask(() {
        final currentRoute = ModalRoute.of(context)?.settings.name;
        if (currentRoute != "/LoginPage") {
          Navigator.pushReplacementNamed(context, "/LoginPage");
        }
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return child;
  }
}
