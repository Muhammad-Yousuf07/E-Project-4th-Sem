import 'package:authentication/widgets/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import '../services/authentication.dart';
import '../services/validation.dart';
import '../widgets/drawer.dart';


final user = FirebaseAuth.instance.currentUser;
final userEmail = user?.email ?? 'No Email';

class FeedbackFormPage extends StatefulWidget {
  static const String routeName = '/FeedbackFormPage';
  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _feedbackType = 'General';
  int _rating = 0;
  bool _isSending = false;

  void _submitFeedback() async {

    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final feedbackData = {
    'email': user?.email ?? 'No Email',
      'type': _feedbackType,
      'rating': _rating,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('feedbacks')
          .add(feedbackData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Feedback submitted successfully!')),
      );

      clearData();

      setState(() {
        _feedbackType = 'General';
        _rating = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to send feedback. Please try again.')),
      );
    }

    setState(() => _isSending = false);
  }

  Widget _buildStarRating() {
    return Row(
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          icon: Icon(
            _rating >= starIndex ? Icons.star : Icons.star_border,
            color: Color(0xFF0e99c9),
          ),
          onPressed: () {
            setState(() => _rating = starIndex);
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        drawer: SideDrawer(),
        appBar: AppBar(
          title: const Text(
            'Feedback Page',
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
        body: Container(
          color: Color(0xFFeeeeee),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Icon(Icons.feedback, size: 60, color: Color(0xFF0e99c9)),
                    SizedBox(height: 16),
                    Text(
                      "We value your feedback!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),

                    // Email Field

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        "⚠️ Email can be changed in user profile settings",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Material(
                      elevation: 20,
                      shadowColor: Colors.black38,
                      child: TextFormField(
                        initialValue: FirebaseAuth.instance.currentUser?.email ?? 'No Email',
                        enabled: false, // Makes the field read-only
                        decoration: InputDecoration(
                          hintText: "Enter Email",
                          prefixIcon: Icon(Icons.email_outlined),
                          prefixIconColor: Color(0xFF0e99c9),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Color(0xFF057ba4),
                              width: 1,
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Feedback Type Dropdown
                    Material(
                      elevation: 20,
                      shadowColor: Colors.black38,
                      child: DropdownButtonFormField<String>(
                        value: _feedbackType,
                        decoration: InputDecoration(
                          hintText: "Select Feedback Type",
                          prefixIcon: Icon(Icons.category_outlined),
                          prefixIconColor: Color(0xFF0e99c9),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Color(0xFF057ba4),
                              width: 1,
                            ),
                          ),
                        ),
                        items: ['General', 'Bug Report', 'Feature Request', 'Other']
                            .map(
                              (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ),
                        )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _feedbackType = val);
                          }
                        },
                      ),
                    ),

                    SizedBox(height: 30),

                    // Star Rating
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Rate Us",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 3),
                    _buildStarRating(),
                    SizedBox(height: 20),

                    // Message Field
                    Material(
                      elevation: 20,
                      shadowColor: Colors.black38,
                      child: TextFormField(
                        controller: _messageController,
                        maxLines: 4,
                        validator: validateMessage,
                        decoration: InputDecoration(
                          hintText: "Describe your issue",
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 48), // Top position
                            child: Icon(
                              Icons.message_outlined,
                            ),
                          ),
                          prefixIconColor: Color(0xFF0e99c9),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Colors.transparent, // light white border
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Color(0xFF057ba4),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Send Button
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: _isSending ? null : _submitFeedback,
                        icon:
                            _isSending
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Icon(Icons.send_rounded, color: Colors.white),
                        label: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            _isSending ? "Sending..." : "Send Feedback",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0e99c9),
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    ),


                  ],
                ),
                  ],

              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  void clearData() {
    _emailController.clear();
    _messageController.clear();
  }

}
