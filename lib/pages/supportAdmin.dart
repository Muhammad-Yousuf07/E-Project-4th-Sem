import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/auth_guard.dart';

class SupportAdminPage extends StatefulWidget {
  static const String routeName = '/SupportAdminPage';

  @override
  _SupportAdminPageState createState() => _SupportAdminPageState();
}

class _SupportAdminPageState extends State<SupportAdminPage> {
  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        drawer: AdminSideDrawer(),
        appBar: AppBar(
          title: const Text(
            'Support Messages',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFF0e99c9),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: Container(
          color: Color(0xFFeeeeee),
          padding: EdgeInsets.all(16),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('supportMessages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No support messages yet!'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var message = snapshot.data!.docs[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message['email'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0e99c9),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            message['message'],
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Submitted: ${_formatTimestamp(message['timestamp'])}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    if (timestamp == null) return 'N/A';

    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}