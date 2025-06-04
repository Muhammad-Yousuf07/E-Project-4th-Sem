import 'package:flutter/material.dart';
import '../services/authentication.dart';
import '../services/validation.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  static const String routeName = '/SignupPage';

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final signupNameController = TextEditingController();
  final signupPnoneNumberController = TextEditingController();
  final signupAddressController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();

  String? name = "";
  String? phone = "";
  String? address = "";
  String? email = "";
  String? password = "";
  bool _isObscure = true;
  bool isRegisterLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFeeeeee),
          padding: EdgeInsets.all(20),
          child: SafeArea(
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text("Welcome Buddy!",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
        
                          SizedBox(height: 20,),
        
                          Text("You're just a few steps away from something awesome."),
        
                          SizedBox(height: 60,),
        
                          // name
                          Material(
                            elevation: 20,
                            shadowColor: Colors.black38,
                            child: TextFormField(
                              controller: signupNameController,
                              keyboardType: TextInputType.name,
                              validator: validateFullName,
                              onSaved: (value) {
                                setState(() {
                                  name = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Enter Full Name",
                                prefixIcon: Icon(Icons.person_outline),
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
        
                          // phone number
                          Material(
                            elevation: 20,
                            shadowColor: Colors.black38,
                            child: TextFormField(
                              controller: signupPnoneNumberController,
                              keyboardType: TextInputType.phone,
                              validator: validatePnoneNumber,
                              onSaved: (value) {
                                setState(() {
                                  phone = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Enter Pnone Number",
                                prefixIcon: Icon(Icons.phone_outlined),
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
                              controller: signupAddressController,
                              keyboardType: TextInputType.streetAddress,
                              validator: validateAddress,
                              onSaved: (value) {
                                setState(() {
                                  address = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Enter Billing Address",
                                prefixIcon: Icon(Icons.streetview_outlined),
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
        
                          // email
                          Material(
                            elevation: 20,
                            shadowColor: Colors.black38,
                            child: TextFormField(
                              controller: signupEmailController,
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
                            ),
                          ),
        
                          SizedBox(height: 20),
        
                          // password
                          Material(
                            elevation: 20,
                            shadowColor: Colors.black38,
                            child: TextFormField(
                              obscureText: _isObscure,
                              controller: signupPasswordController,
                              validator: validatePassword,
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
        
                          SizedBox(height: 30),
        
                          SizedBox(
                            child:
                            isRegisterLoading
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
                                onPressed: _signupUser,
                                style: TextButton.styleFrom(
                                  backgroundColor: Color(0xFF0e99c9),
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero, // No rounded corners
                                  ),
                                ),
                                child: Text(
                                  "REGISTER",
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
                                Navigator.pushReplacementNamed(context, "/LoginPage");
                              },
                              child: Text("Already have an account? Login",
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



  void _signupUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isRegisterLoading = true;
      });

      var result = await AuthenticationHelper().signUp(
        name: name.toString(),
        phone : phone.toString(),
        address: address.toString(),
        email: email.toString(),
        password: password.toString(),
      );

      setState(() {
        isRegisterLoading = false;
      });

      if (result == null) {
        ScaffoldMessenger.of(
            context
        ).showSnackBar(SnackBar(content: Text("\"$name\" Registered Successfully")));
        Navigator.pushReplacementNamed(context, "/LoginPage");
      } else {
        ScaffoldMessenger.of(
            context
        ).showSnackBar(SnackBar(content: Text(result.toString())));
      }
    }
  }


  void clearData(){
    signupNameController.clear();
    signupPnoneNumberController.clear();
    signupAddressController.clear();
    signupEmailController.clear();
    signupPasswordController.clear();
  }


}
