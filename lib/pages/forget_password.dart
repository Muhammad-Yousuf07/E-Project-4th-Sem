import 'package:authentication/pages/login_page.dart';
import 'package:flutter/material.dart';
import '../services/authentication.dart';

import '../services/validation.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  static const String routeName = '/ResetPasswordPage';


  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final forgetPasswordEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    String? result = await AuthenticationHelper().resetPasswordByEmail(email: forgetPasswordEmailController.text.trim());

    setState(() => isLoading = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reset link sent to your email.")),
      );
      Navigator.pushReplacementNamed(context, "/LoginPage");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFeeeeee),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFeeeeee),
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
        
                  Container(
                    height: 200,
                    width: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/banner_2.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
        
                  SizedBox(height: 35),
        
                  Text("Reset Password",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
        
                  SizedBox(height: 40),
        
                  Material(
                    elevation: 20, // this is the elevation
                    shadowColor: Colors.black38,
                    child: TextFormField(
                      controller: forgetPasswordEmailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: validateEmail,
                      decoration: InputDecoration(
                        hintText: "Enter recover email",
                        prefixIcon: Icon(Icons.email_outlined),
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
        
                  SizedBox(height: 20),
                  isLoading
                      ? CircularProgressIndicator()
                      : SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    child: TextButton(
                      onPressed: _resetPassword,
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF0e99c9),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // No rounded corners
                        ),
                      ),
                      child: Text(
                        "RESET PASSWORD",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 5,
                        ),
                      ),
                    ),
                  ),
        
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
