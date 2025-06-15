import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/validation.dart';
import '../widgets/auth_guard.dart';

class EditProfilePage extends StatefulWidget {
  static const String routeName = '/EditUserPage';

  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  String? _userEmail;

  // For password obscure toggle
  bool _isCurrentPasswordObscure = true;
  bool _isNewPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => _userEmail = user.email ?? '');

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _fullNameController.text = data?['name'] ?? '';
          _addressController.text = data?['address'] ?? '';
          _contactController.text = data?['phone'] ?? '';
        });
      }
    }
  }

  // Custom InputDecoration matching your style
  InputDecoration _customDecoration(String hintText, IconData prefixIcon, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: Color(0xFF0e99c9)),
      suffixIcon: suffixIcon,
      suffixIconColor: Color(0xFF0e99c9),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.transparent, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color(0xFF057ba4), width: 1),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not found.");

      final currentPass = _currentPasswordController.text.trim();
      final newPass = _newPasswordController.text.trim();
      final confirmPass = _confirmPasswordController.text.trim();

      if (newPass.isNotEmpty || confirmPass.isNotEmpty || currentPass.isNotEmpty) {
        if (currentPass.isEmpty) {
          throw FirebaseAuthException(
            code: "requires-recent-login",
            message: "Enter your current password to change it.",
          );
        }

        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPass,
        );

        await user.reauthenticateWithCredential(cred);

        if (newPass != confirmPass) {
          throw FirebaseAuthException(
            code: 'password-mismatch',
            message: 'New password and confirm password do not match.',
          );
        }

        await user.updatePassword(newPass);
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _fullNameController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _contactController.text.trim(),
        'uid': user.uid,
      }, SetOptions(merge: true));

      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final role = doc.data()?['role'];
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/AdminPage');
        } else {
          Navigator.pushReplacementNamed(context, '/HomePage');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/LoginPage');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An error occurred')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unexpected error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (_loading) return;

              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                final role = doc.data()?['role'] ?? 'user';

                if (role == 'admin') {
                  Navigator.pushReplacementNamed(context, '/AdminPage');
                } else {
                  Navigator.pushReplacementNamed(context, '/HomePage');
                }
              } else {
                Navigator.pushReplacementNamed(context, '/LoginPage');
              }
            },
          ),
          backgroundColor: Color(0xFF0e99c9),
          iconTheme: IconThemeData(color: Colors.white, weight: 20, size: 26),
          centerTitle: true,
        ),
        body: Container(
          color: Color(0xFFeeeeee),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SizedBox(height: 12),

                  if (_userEmail != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          initialValue: _userEmail,
                          decoration: _customDecoration("Email (not editable)", Icons.email_outlined).copyWith(
                            filled: true,
                            fillColor: Colors.grey.shade200,
                          ),
                          readOnly: true,
                          enabled: false,
                        ),
                        SizedBox(height: 6),
                        Text(
                          "⚠️ Your email cannot be edited!",
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),

                  SizedBox(height: 16),
                  Text("Change Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,)),
                  SizedBox(height: 12),

                  Material(
                    elevation: 20,
                    shadowColor: Colors.black38,
                    child: TextFormField(
                      controller: _fullNameController,
                      decoration: _customDecoration("Full Name", Icons.person_outline),
                      validator: validateFullName,
                    ),
                  ),

                  SizedBox(height: 16),

                  Material(
                    elevation: 20,
                    shadowColor: Colors.black38,
                    child: TextFormField(
                      controller: _addressController,
                      decoration: _customDecoration("Shipping Address", Icons.location_on_outlined),
                      validator: validateAddress,
                    ),
                  ),

                  SizedBox(height: 16),

                  Material(
                    elevation: 20,
                    shadowColor: Colors.black38,
                    child: TextFormField(
                      controller: _contactController,
                      decoration: _customDecoration("Contact Number", Icons.phone_outlined),
                      validator: validatePhoneNumber,
                    ),
                  ),

                  SizedBox(height: 32),
                  Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,)),
                  SizedBox(height: 12),

                  Material(
                    elevation: 20,
                    shadowColor: Colors.black38,
                    child: TextFormField(
                      controller: _currentPasswordController,
                      obscureText: _isCurrentPasswordObscure,
                      decoration: _customDecoration(
                        "Current Password",
                        Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isCurrentPasswordObscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _isCurrentPasswordObscure = !_isCurrentPasswordObscure;
                            });
                          },
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Current password can't be empty";
                        }
                        return null; // Firebase handles actual reauth
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  Material(
                    elevation: 20,
                    shadowColor: Colors.black38,
                    child: TextFormField(
                      controller: _newPasswordController,
                      obscureText: _isNewPasswordObscure,
                      decoration: _customDecoration(
                        "New Password",
                        Icons.lock_open,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewPasswordObscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _isNewPasswordObscure = !_isNewPasswordObscure;
                            });
                          },
                        ),
                      ),
                      validator: validatePassword,
                    ),
                  ),

                  SizedBox(height: 16),

                  Material(
                    elevation: 20,
                    shadowColor: Colors.black38,
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _isConfirmPasswordObscure,
                      decoration: _customDecoration(
                        "Confirm New Password",
                        Icons.lock,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordObscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
                            });
                          },
                        ),
                      ),
                      validator: (val) => validateConfirmPassword(val, _newPasswordController.text),
                    ),
                  ),

                  SizedBox(height: 24),

                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0e99c9),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: _loading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        "SAVE CHANGES",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 5,
                        ),
                      ),
                    ),
                  )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
