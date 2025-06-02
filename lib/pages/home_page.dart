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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      setState(() {
        uuid = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        drawer: SideDrawer(),
        appBar: AppBar(
          title: const Text('Home Page', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
          actions: <Widget>[
            IconButton(
              onPressed: () async{
                await AuthenticationHelper().signOut();
                Navigator.pushReplacementNamed(context, "/LoginPage");
              },
              icon: Icon(Icons.logout_outlined),
            )
          ],
          backgroundColor: Color(0xFF0e99c9),
          iconTheme: IconThemeData(color: Colors.white, weight: 20, size: 26),
          centerTitle: true,
        ),
        body: Container(
          color: Color(0xFFeeeeee),
          child: Center(
            child: Text("Coming Soon", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,),),
          ),
        ),
      ),
    );
  }
}
