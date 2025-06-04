import 'package:flutter/material.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            drawerHeader(),
            const SizedBox(height: 16),

            drawerItem(
              icon: Icons.home_outlined,
              text: "Home",
              onTap: () => Navigator.pushReplacementNamed(context, "/HomePage"),
            ),

            drawerItem(
              icon: Icons.login_outlined,
              text: "Login",
              onTap: () => Navigator.pushReplacementNamed(context, "/LoginPage"),
            ),

            drawerItem(
              icon: Icons.support_agent_outlined,
              text: "Customer Support",
              onTap: () => Navigator.pushReplacementNamed(context, "/CustomerSupportPage"),
            ),

            drawerItem(
              icon: Icons.feedback_outlined,
              text: "Feedback",
              onTap: () => Navigator.pushReplacementNamed(context, "/FeedbackFormPage"),
            ),

            const Divider(thickness: 1, height: 32),
            ListTile(
              title: Text(
                "App Version - 1.0.0",
                style: TextStyle(color: Colors.black54),
              ),
              subtitle: Text(
                "© watch.hub - 2025",
                style: TextStyle(color: Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget drawerHeader() {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: const BoxDecoration(
        color: Color(0xFF0e99c9),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const CircleAvatar(
            radius: 40,
            child: CircleAvatar(
              radius : 38,
              backgroundImage: AssetImage("assets/images/user_avatar.png"),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Welcome!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget drawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF0e99c9)),
      title: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
      hoverColor: Colors.grey.shade200,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
