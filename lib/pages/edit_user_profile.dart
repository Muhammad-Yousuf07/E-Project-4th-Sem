import 'package:authentication/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String? _errorText;

  String? _userEmail;

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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.zero),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade600, width: 1.2),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not found.");

      if (_newPasswordController.text.isNotEmpty || _confirmPasswordController.text.isNotEmpty) {
        if (_currentPasswordController.text.trim().isEmpty) {
          throw FirebaseAuthException(
            code: "requires-recent-login",
            message: "Enter current password to change password.",
          );
        }

        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text.trim(),
        );

        await user.reauthenticateWithCredential(cred);

        if (_newPasswordController.text != _confirmPasswordController.text) {
          throw FirebaseAuthException(code: 'password-mismatch', message: 'Passwords do not match');
        }

        await user.updatePassword(_newPasswordController.text.trim());
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _fullNameController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _contactController.text.trim(),
        'uid': user.uid,
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorText = e.message);
    } catch (e) {
      setState(() => _errorText = "Unexpected error: $e");
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
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
          backgroundColor: Color(0xFF0e99c9),
          iconTheme: IconThemeData(color: Colors.white, weight: 20, size: 26),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_errorText!, style: TextStyle(color: Colors.red)),
                  ),
                Text("Change General Details", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 12),

                TextFormField(
                  controller: _fullNameController,
                  decoration: _inputDecoration("Full Name", Icons.person_outline),
                  validator: (value) => value == null || value.isEmpty ? 'Enter full name' : null,
                ),
                SizedBox(height: 16),

                if (_userEmail != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: _userEmail,
                        decoration: _inputDecoration("Email (not editable)", Icons.email_outlined).copyWith(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                        ),
                        readOnly: true,
                        enabled: false,
                      ),
                      SizedBox(height: 6),
                      Text(
                        "⚠️ Your email cannot be edited.",
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),

                TextFormField(
                  controller: _addressController,
                  decoration: _inputDecoration("Shipping Address", Icons.location_on_outlined),
                  validator: (value) => value == null || value.isEmpty ? 'Enter address' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _contactController,
                  decoration: _inputDecoration("Contact Number", Icons.phone_outlined),
                  validator: (value) => value == null || value.isEmpty ? 'Enter contact number' : null,
                ),
                SizedBox(height: 32),
                Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: _inputDecoration("Current Password", Icons.lock_outline),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: _inputDecoration("New Password", Icons.lock_open),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: _inputDecoration("Confirm New Password", Icons.lock),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0e99c9),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: _loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
