import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/auth_guard.dart';


class FeedbackManagementPage extends StatefulWidget {
  static const String routeName = '/FeedbackManagement';

  @override
  _FeedbackManagementPageState createState() => _FeedbackManagementPageState();
}

class _FeedbackManagementPageState extends State<FeedbackManagementPage> {
  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        drawer: AdminSideDrawer(),
        appBar: AppBar(
          title: const Text(
            'All Feedbacks',
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
                .collection('feedbacks')
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
                return Center(child: Text('No feedbacks yet!'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var feedback = snapshot.data!.docs[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                feedback['email'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0e99c9),
                                ),
                              ),
                              Chip(
                                label: Text(feedback['type']),
                                backgroundColor: Color(0xFF0e99c9).withOpacity(0.2),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                Icons.star,
                                color: starIndex < feedback['rating']
                                    ? Colors.amber
                                    : Colors.grey,
                                size: 20,
                              );
                            }),
                          ),
                          SizedBox(height: 12),
                          Text(
                            feedback['message'],
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Submitted: ${feedback['timestamp']?.toDate().toString() ?? 'N/A'}',
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
}