import 'package:authentication/widgets/admin_drawer.dart';
import 'package:authentication/widgets/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/authentication.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  static const String routeName = '/UserManagement';

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        drawer: const AdminSideDrawer(),
        appBar: AppBar(
          title: const Text(
            'User Management',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                await AuthenticationHelper().signOut();
                Navigator.pushReplacementNamed(context, "/LoginPage");
              },
              icon: const Icon(Icons.logout_outlined),
            ),
          ],
          backgroundColor: const Color(0xFF0e99c9),
          iconTheme: const IconThemeData(color: Colors.white, weight: 20, size: 26),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'User Management',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0e99c9),
                        ),
                        onPressed: () => _showAddUserDialog(context),
                        child: const Text('Add User', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading users'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs.where((doc) {
                    if (_searchQuery.isEmpty) return true;
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name']?.toString().toLowerCase() ?? '';
                    final email = data['email']?.toString().toLowerCase() ?? '';
                    final phone = data['phone']?.toString().toLowerCase() ?? '';
                    return name.contains(_searchQuery) ||
                        email.contains(_searchQuery) ||
                        phone.contains(_searchQuery);
                  }).toList();

                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty ? 'No users found' : 'No matching users',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final data = user.data() as Map<String, dynamic>;
                      final createdAt = data['createdAt']?.toDate();
                      final formattedDate = createdAt != null
                          ? DateFormat('MMM d, yyyy').format(createdAt)
                          : 'Unknown date';
                      final role = data['role'] ?? 'user';
                      final isAdmin = role == 'admin';

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 3,
                        child: InkWell(
                          onTap: () => _showUserDetails(context, data),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User Avatar
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: isAdmin ? Colors.blue[100] : Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                                      size: 30,
                                      color: isAdmin ? Colors.blue : Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // User Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'] ?? 'No Name',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        data['email'] ?? 'No Email',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            'Role: $role',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isAdmin ? Colors.blue : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Joined: $formattedDate',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Action Buttons
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showEditUserDialog(context, user.id, data),
                                    ),
                                    if (!isAdmin) // Prevent deleting admin accounts
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteUser(user.id, data['email']),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> data) {
    final createdAt = data['createdAt']?.toDate();
    final formattedDate = createdAt != null
        ? DateFormat('MMM d, yyyy - hh:mm a').format(createdAt)
        : 'Unknown date';
    final role = data['role'] ?? 'user';
    final isAdmin = role == 'admin';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data['name'] ?? 'User Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isAdmin ? Colors.blue[100] : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isAdmin ? Icons.admin_panel_settings : Icons.person,
                        size: 40,
                        color: isAdmin ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Name', data['name'] ?? 'Not provided'),
                _buildDetailRow('Email', data['email'] ?? 'Not provided'),
                _buildDetailRow('Phone', data['phone'] ?? 'Not provided'),
                _buildDetailRow('Address', data['address'] ?? 'Not provided'),
                _buildDetailRow(
                  'Role',
                  role,
                  style: TextStyle(
                    color: isAdmin ? Colors.blue : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildDetailRow('Account Created', formattedDate),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: style,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddUserDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    String? selectedRole = 'user';
    bool _obscurePassword = true;
    bool _obscureConfirmPassword = true;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New User'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Full Name*'),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email*'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password*',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (value!.length < 6) return 'Minimum 6 characters';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password*',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (value != passwordController.text) return 'Passwords don\'t match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role*',
                          border: OutlineInputBorder(),
                        ),
                        items: ['user', 'admin'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0e99c9),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );

                        // 1. Create user in Firebase Authentication
                        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );

                        // 2. Add user data to Firestore
                        await _firestore.collection('users').doc(userCredential.user?.uid).set({
                          'uid': userCredential.user?.uid,
                          'name': nameController.text,
                          'email': emailController.text,
                          'phone': phoneController.text.isNotEmpty ? phoneController.text : null,
                          'address': addressController.text.isNotEmpty ? addressController.text : null,
                          'role': selectedRole,
                          'createdAt': FieldValue.serverTimestamp(),
                          'updatedAt': FieldValue.serverTimestamp(),
                        });

                        // Close loading indicator
                        if (!mounted) return;
                        Navigator.pop(context); // Close loading
                        Navigator.pop(context); // Close dialog

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User created successfully!')),
                        );
                      } on FirebaseAuthException catch (e) {
                        // Close loading indicator
                        Navigator.pop(context);

                        String errorMessage;
                        switch (e.code) {
                          case 'email-already-in-use':
                            errorMessage = 'Email already in use';
                            break;
                          case 'invalid-email':
                            errorMessage = 'Invalid email address';
                            break;
                          case 'weak-password':
                            errorMessage = 'Password is too weak';
                            break;
                          default:
                            errorMessage = 'Error creating user: ${e.message}';
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMessage)),
                        );
                      } catch (e) {
                        // Close loading indicator
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error creating user: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Create User', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditUserDialog(BuildContext context, String userId, Map<String, dynamic> data) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: data['name']);
    final emailController = TextEditingController(text: data['email']);
    final phoneController = TextEditingController(text: data['phone'] ?? '');
    final addressController = TextEditingController(text: data['address'] ?? '');
    String? selectedRole = data['role'] ?? 'user';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit User'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Full Name*'),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email*'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role*',
                          border: OutlineInputBorder(),
                        ),
                        items: ['user', 'admin'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0e99c9),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );

                        // Update user in Firestore
                        await _firestore.collection('users').doc(userId).update({
                          'name': nameController.text,
                          'email': emailController.text,
                          'phone': phoneController.text.isNotEmpty ? phoneController.text : null,
                          'address': addressController.text.isNotEmpty ? addressController.text : null,
                          'role': selectedRole,
                          'updatedAt': FieldValue.serverTimestamp(),
                        });

                        // Close loading indicator
                        if (!mounted) return;
                        Navigator.pop(context); // Close loading
                        Navigator.pop(context); // Close dialog

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User updated successfully!')),
                        );
                      } catch (e) {
                        // Close loading indicator
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating user: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Update', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteUser(String userId, String? email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && email != null) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        // 1. Delete from Authentication
        final user = await _auth.fetchSignInMethodsForEmail(email);
        if (user.isNotEmpty) {
          // User exists in Authentication
          final authUser = await _auth.currentUser;
          if (authUser != null && authUser.uid == userId) {
            await authUser.delete();
          }
        }

        // 2. Delete from Firestore
        await _firestore.collection('users').doc(userId).delete();

        // Close loading indicator
        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully!')),
        );
      } on FirebaseAuthException catch (e) {
        // Close loading indicator
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: ${e.message}')),
        );
      } catch (e) {
        // Close loading indicator
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }
}