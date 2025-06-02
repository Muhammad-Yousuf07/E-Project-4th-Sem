import 'package:flutter/material.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[600],
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[

            drawerHeader(),

            SizedBox(height: 10,),

            drawerBody(icon: Icons.home, text: "Home", onTap: ()=>{
              Navigator.pushReplacementNamed(context, "/HomePage")
            }),

            SizedBox(height: 10,),

            drawerBody(icon: Icons.login, text: "Login", onTap: ()=> {
              Navigator.pushReplacementNamed(context, "/LoginPage")
            }),

            SizedBox(height: 10,),
            
            drawerBody(icon: Icons.support_agent_outlined, text: "Customer Support", onTap: ()=> {
              Navigator.pushReplacementNamed(context, "/CustomerSupportPage")
            }),

            const Divider(),
            ListTile(
              title: Text("App Version - 1.0.0", style: TextStyle(color: Colors.white)),
              subtitle: Text("copyright © 2025", style: TextStyle(color: Colors.white)),
            )

          ],
        ),
      ),
    );
  }


  Widget drawerHeader() {
    return SizedBox(
      height: 250,
      child: DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/banner.gif"),
              fit: BoxFit.fill
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.black,
              child: CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage("assets/images/avatar.jpg"),
              ),
            ),

            SizedBox(height: 20,),

            Container(
              padding: EdgeInsets.all(10),
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Side-Bar", style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }

  Widget drawerBody({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap
  }) {
    return ListTile(
      title: Row(
        children: [
          Icon(icon, color: Colors.white),
          Padding(padding: EdgeInsets.only(left: 16),
            child: Text(text, style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
      onTap: onTap,
    );
  }


}
