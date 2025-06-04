import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


final user = FirebaseAuth.instance.currentUser;
final userName = user?.displayName ?? 'No Name';


class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 270,
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
              icon: Icons.support_agent_outlined,
              text: "Customer Support",
              onTap: () => Navigator.pushReplacementNamed(context, "/CustomerSupportPage"),
            ),

            drawerItem(
              icon: Icons.feedback_outlined,
              text: "Feedback",
              onTap: () => Navigator.pushReplacementNamed(context, "/FeedbackFormPage"),
            ),

            drawerItem(
              icon: Icons.edit_note,
              text: "Edit Profile",
              onTap: () => Navigator.pushReplacementNamed(context, "/EditUserPage"),
            ),

        // static const String routeName = '/EditUserPage';

            drawerItem(
              icon: Icons.logout,
              text: "Logout",
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, color: Color(0xFF0e99c9), size: 50),
                          SizedBox(height: 15),
                          Text(
                            "Log out?",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Are you sure you want to log out of your account?",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          ),
                          SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context, false),
                                icon: Icon(Icons.cancel, size: 18),
                                label: Text("Cancel"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  foregroundColor: Colors.black87,
                                  padding: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context, true),
                                icon: Icon(Icons.logout, size: 18),
                                label: Text("Logout"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF057ba4),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 17, vertical: 17),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );

                if (shouldLogout == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, "/LoginPage");
                }
              },
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
    return Container(
      height: 175,
      child: DrawerHeader(
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
              "\t\t\tWelcome!\n$userName ",
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
