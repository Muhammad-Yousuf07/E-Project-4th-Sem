import 'package:authentication/services/validation.dart';
import 'package:authentication/widgets/auth_guard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'customer_support.dart';


final user = FirebaseAuth.instance.currentUser;
final userEmail = user?.email ?? 'No Email';



class ChatPage extends StatefulWidget {
  static const String routeName = '/ChatPage';

  @override
  _ChatPage createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  void _submitForm() async {

    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final messageData = {
      'email': user?.email ?? 'No Email',
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('supportMessages').add(messageData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Message sent successfully!')),
      );
      clearData();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error sending message. Please try again.')),
      );
    }

    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(title: const Text("Chat Page", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white,),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SupportHomePage()));
            },
          ),
          backgroundColor: Color(0xFF0e99c9),
          iconTheme: IconThemeData(color: Colors.white, weight: 20, size: 26),
          centerTitle: true,
        ),
        body: Container(
          color: Color(0xFFeeeeee),
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
      
              // yousuf styling
      
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Icon(Icons.support_agent, size: 60, color: Color(0xFF0e99c9),),
                      SizedBox(height: 15),
                      Text(
                        "We're here to help you!",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
      
                      SizedBox(height: 30),

                      // Material(
                      //   elevation: 20,
                      //   shadowColor: Colors.black38,
                      //   child: TextFormField(
                      //     controller: _emailController,
                      //     keyboardType: TextInputType.emailAddress,
                      //     validator: validateEmail,
                      //     decoration: InputDecoration(
                      //       hintText: "Enter Email",
                      //       prefixIcon: Icon(Icons.email_outlined),
                      //       prefixIconColor: Color(0xFF0e99c9),
                      //       isDense: true,
                      //       contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.zero,
                      //         borderSide: BorderSide(
                      //           color: Colors.transparent, // light white border
                      //           width: 1.0,
                      //         ),
                      //       ),
                      //       enabledBorder: OutlineInputBorder(
                      //         borderRadius: BorderRadius.zero,
                      //         borderSide: BorderSide(
                      //           color: Colors.transparent,
                      //         ),
                      //       ),
                      //       focusedBorder: OutlineInputBorder(
                      //         borderRadius: BorderRadius.zero,
                      //         borderSide: BorderSide(
                      //           color: Color(0xFF057ba4),
                      //           width: 1,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),



                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          "⚠️ Email can not be changed",
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
                          onPressed: _isSending ? null : _submitForm,
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
                              _isSending ? "Sending..." : "Send Message",
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
      
                    ],
                  ),
                    ],
                  ),
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




// taha styling

// child: Card(
//   elevation: 10,
//   color: Colors.grey.shade100,
//   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//   child: Padding(
//     padding: const EdgeInsets.all(24),
//     child: Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           Icon(Icons.support_agent, size: 60, color: Colors.red.shade600),
//           SizedBox(height: 16),
//           Text(
//             "We're here to help you!",
//             style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 24),
//
//           // Email Field
//           TextFormField(
//             controller: _emailController,
//             decoration: InputDecoration(
//               labelText: "Your Email",
//               prefixIcon: Icon(Icons.email_outlined),
//               filled: true,
//               fillColor: Colors.white,
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             validator: validateEmail,
//           ),
//           SizedBox(height: 20),
//
//           // Message Field
//           TextFormField(
//             controller: _messageController,
//             maxLines: 6,
//             decoration: InputDecoration(
//               labelText: "Describe your issue",
//               prefixIcon: Icon(Icons.message_outlined),
//               alignLabelWithHint: true,
//               filled: true,
//               fillColor: Colors.white,
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             validator: (value) =>
//             value == null || value.isEmpty ? 'Message can’t be empty' : null,
//           ),
//           SizedBox(height: 30),
//
//           // Send Button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: _isSending ? null : _submitForm,
//               icon: _isSending
//                   ? SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//                   : Icon(Icons.send_rounded, color: Colors.white),
//               label: Text(
//                 _isSending ? "Sending..." : "Send Message",
//                 style: TextStyle(color: Colors.white),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red.shade600,
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   ),
// ),