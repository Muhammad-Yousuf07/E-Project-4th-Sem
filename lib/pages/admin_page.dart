import 'package:authentication/widgets/admin_drawer.dart';
import 'package:authentication/widgets/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/authentication.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  static const String routeName = '/AdminPage';

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String adminName = "Admin";
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    setState(() => isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()?['role'] == 'admin') {
          setState(() {
            adminName = doc.data()?['name'] ?? "Admin";
            isLoading = false;
          });
        } else {
          await _auth.signOut();
          Navigator.pushReplacementNamed(context, "/LoginPage");
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load admin data";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        drawer: AdminSideDrawer(),
        appBar: AppBar(
          title: const Text(
            'Admin Panel',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                setState(() => isLoading = true);
                try {
                  await AuthenticationHelper().signOut();
                  Navigator.pushReplacementNamed(context, "/LoginPage");
                } catch (e) {
                  setState(() {
                    errorMessage = "Logout failed";
                    isLoading = false;
                  });
                }
              },
              icon: Icon(Icons.logout_outlined),
            ),
          ],
          backgroundColor: Color(0xFF0e99c9),
          iconTheme: IconThemeData(color: Colors.white, weight: 20, size: 26),
          centerTitle: true,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          SizedBox(height: 20),
          _buildStatsGrid(),
          SizedBox(height: 30),
          _buildRecentProductsSection(),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Text(
      "Welcome, $adminName",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0e99c9),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.5,
        children: [
          _buildStatCard(
            "Total Users",
            Icons.people,
            _buildUserCountStream(),
            Colors.blue,
          ),
          _buildStatCard(
            "Total Products",
            Icons.shopping_bag,
            _buildCollectionCountStream('products'),
            Colors.green,
          ),
          _buildStatCard(
            "Total Feedbacks",
            Icons.feedback,
            _buildCollectionCountStream('feedbacks'),
            Colors.orange,
          ),
          _buildStatCard(
            "Total FAQs",
            Icons.question_answer,
            _buildCollectionCountStream('faqs'),
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCountStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Error", style: TextStyle(color: Colors.red));

        if (!snapshot.hasData) return Text("0", style: TextStyle(fontSize: 24));

        final users = snapshot.data!.docs;
        final userCount = users.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['role'] == 'user';
        }).length;

        return Text(
          userCount.toString(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  Widget _buildCollectionCountStream(String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Error", style: TextStyle(color: Colors.red));

        if (!snapshot.hasData) return Text("0", style: TextStyle(fontSize: 24));

        return Text(
          snapshot.data!.docs.length.toString(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  Widget _buildStatCard(String title, IconData icon, Widget valueWidget, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 5),
            valueWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildRecentProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Recent Products", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/ProductManagement'),
              child: Text("View All"),
            ),
          ],
        ),
        SizedBox(height: 10),
        _buildRecentItemsTable('products', ['name', 'price', 'stock']),
      ],
    );
  }

  Widget _buildRecentItemsTable(String collection, List<String> columns) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(collection)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Error loading $collection", style: TextStyle(color: Colors.red)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text("No ${collection.replaceAll('messages', '')} found"),
            ),
          );
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              columnWidths: {for (var i = 0; i < columns.length; i++) i: FlexColumnWidth(2)},
              border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Color(0xFF0e99c9).withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  children: columns.map((col) => _buildTableHeaderCell(col)).toList(),
                ),
                ...snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return TableRow(
                    children: columns.map((col) => _buildTableCell(data[col]?.toString() ?? 'N/A')).toList(),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0e99c9)),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}