import 'package:authentication/widgets/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/authentication.dart';
import '../widgets/drawer.dart';



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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final feedbackData = {
      'email': _emailController.text.trim(),
      'type': _feedbackType,
      'rating': _rating,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('feedbacks').add(feedbackData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Feedback submitted successfully!')),
      );

      _emailController.clear();
      _messageController.clear();
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
            color: Colors.amber,
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
      // backgroundColor: Colors.grey.shade100,
    appBar: AppBar(
    title: const Text('Feedback', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(Icons.feedback, size: 60, color: Color(0xFF0e99c9)),
                  SizedBox(height: 16),
                  Text(
                    "We value your feedback!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Your Email",
                      prefixIcon: Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                    value == null || !value.contains('@') ? 'Enter a valid email' : null,
                  ),
                  SizedBox(height: 20),

                  // Feedback Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _feedbackType,
                    decoration: InputDecoration(
                      labelText: "Feedback Type",
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: ['General', 'Bug Report', 'Feature Request', 'Other']
                        .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _feedbackType = val);
                      }
                    },
                  ),
                  SizedBox(height: 20),

                  // Star Rating
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Rate Us",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  _buildStarRating(),
                  SizedBox(height: 20),

                  // Message Field
                  TextFormField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: "Your Feedback",
                      prefixIcon: Icon(Icons.message_outlined),
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Feedback can’t be empty' : null,
                  ),
                  SizedBox(height: 30),


                  // Send Button
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _submitFeedback,
                      icon: _isSending
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  )



                  //
                  // // Send Button
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton.icon(
                  //     onPressed: _isSending ? null : _submitFeedback,
                  //     icon: _isSending
                  //         ? SizedBox(
                  //       height: 20,
                  //       width: 20,
                  //       child: CircularProgressIndicator(
                  //         strokeWidth: 2,
                  //         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  //       ),
                  //     )
                  //         : Icon(Icons.send_rounded, color: Colors.white),
                  //     label: Text(
                  //       _isSending ? "Sending..." : "Submit Feedback",
                  //       style: TextStyle(color: Colors.white),
                  //     ),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.red.shade600,
                  //       padding: EdgeInsets.symmetric(vertical: 16),
                  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
