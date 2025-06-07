import 'package:authentication/widgets/admin_drawer.dart';
import 'package:authentication/widgets/auth_guard.dart';
import 'package:flutter/material.dart';

import '../services/authentication.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});
  static const String routeName = '/AdminPage';

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        drawer: AdminSideDrawer(),
        appBar: AppBar(
          title: const Text(
            'Admin Panel',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                await AuthenticationHelper().signOut();
                Navigator.pushReplacementNamed(context, "/LoginPage");
              },
              icon: Icon(Icons.logout_outlined),
            ),
          ],
          backgroundColor: Color(0xFF0e99c9),
          iconTheme: IconThemeData(color: Colors.white, weight: 20, size: 26),
          centerTitle: true,
        ),
        body: Center(
          child: Text("Coming Soon"),
        ),
      ),
    );
  }
}
