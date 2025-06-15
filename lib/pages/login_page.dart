import 'package:authentication/services/authentication.dart';
import 'package:authentication/services/validation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const String routeName = '/LoginPage';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  String? email = "";
  String? password = "";
  bool _isObscure = true;
  bool isLoginLoading = false;
  bool resetPassLoading = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      setState(() {
        Future.delayed(Duration.zero, () async{
          Navigator.pushReplacementNamed(context, "/HomePage");
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(14),
          color: Color(0xFFeeeeee),
          child: SafeArea(
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text("Welcome Back!",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
        
                          SizedBox(height: 20,),
        
                          Text("Let's get you signed in and back to what you love."),
        
                          SizedBox(height: 60,),
        
                          Material(
                            elevation: 20,
                            shadowColor: Colors.black38,
                            child: TextFormField(
                              controller: loginEmailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: validateEmail,
                              onSaved: (value) {
                                setState(() {
                                  email = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Enter Email",
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
        
                          Material(
                            elevation: 20,
                            shadowColor: Colors.black38,
                            child: TextFormField(
                              obscureText: _isObscure,
                              validator: validatePassword,
                              controller: loginPasswordController,
                              onSaved: (value) {
                                setState(() {
                                  password = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Enter Password",
                                prefixIcon: Icon(Icons.password_outlined),
                                prefixIconColor: Color(0xFF0e99c9),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                ),
                                suffixIconColor: Color(0xFF0e99c9),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(
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
        
                          // second method
        
                          SizedBox(height: 8),
        
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                                onPressed: (){
                                  Navigator.pushReplacementNamed(context, "/ResetPasswordPage");
                                },
                                child: Text("Forget Password ?",
                                  style: TextStyle(
                                    color: Color(0xFF057ba4),
                                  ),
                                ),
                            ),
                          ),
        
                          SizedBox(height: 20),
        
                          SizedBox(
                            child:
                                isLoginLoading
                                    ? Center(
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                    : SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 40,
                                      child: TextButton(
                                        onPressed: _loginUser,
                                        style: TextButton.styleFrom(
                                          backgroundColor: Color(0xFF0e99c9),
                                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero, // No rounded corners
                                          ),
                                        ),
                                        child: Text(
                                          "LOGIN",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            letterSpacing: 5,
                                          ),
                                        ),
                                      ),
        
                                ),
                          ),
        
                          SizedBox(height: 10),
        
                          Align(
                              alignment: Alignment.center,
                              child: TextButton(
                                  onPressed: (){
                                    Navigator.pushReplacementNamed(context, "/SignupPage");
                                  },
                                  child: Text("Don't have an account? SignUp",
                                    style: TextStyle(
                                      color: Color(0xFF057ba4),
                                    ),
                                  ),
                              ),
                          ),
        
                          SizedBox(height: 10),
        
                        ],
                      ),
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

  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoginLoading = true;
      });

      var result = await AuthenticationHelper().signIn(
        email: email.toString(),
        password: password.toString(),
      );

      setState(() {
        isLoginLoading = false;
      });

      if (result == null) {
        final user = FirebaseAuth.instance.currentUser;
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        final role = userDoc['role'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("\"$email\" Login Successfully")),
        );

        clearData();

        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, "/AdminPage");
        } else {
          Navigator.pushReplacementNamed(context, "/HomePage");
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.toString())),
        );
      }
    }
  }


  void clearData(){
    loginEmailController.clear();
    loginPasswordController.clear();
  }

}
