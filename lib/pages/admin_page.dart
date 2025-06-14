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
            'Admin Dashboard',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
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
              icon: Icon(Icons.logout, size: 26),
              tooltip: 'Logout',
            ),
          ],
          backgroundColor: Color(0xFF0e99c9),
          iconTheme: IconThemeData(color: Colors.white, size: 28),
          centerTitle: true,
          elevation: 0,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0e99c9).withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0e99c9)),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAdminData,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0e99c9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          SizedBox(height: 24),
          _buildStatsGrid(),
          SizedBox(height: 32),
          _buildRecentProductsSection(),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back,",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4),
        Text(
          adminName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0e99c9),
          ),
        ),
        SizedBox(height: 8),
        Divider(color: Colors.grey[800], thickness: 1),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          "Total Users",
          Icons.people_alt_rounded,
          _buildUserCountStream(),
          [Color(0xFF0e99c9), Color(0xFF3bb3e8)],
        ),
        _buildStatCard(
          "Total Products",
          Icons.shopping_bag_rounded,
          _buildCollectionCountStream('products'),
          [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        ),
        _buildStatCard(
          "Total Feedbacks",
          Icons.feedback_rounded,
          _buildCollectionCountStream('feedbacks'),
          [Color(0xFFFF9800), Color(0xFFFFC107)],
        ),
        _buildStatCard(
          "Total FAQs",
          Icons.question_answer_rounded,
          _buildCollectionCountStream('faqs'),
          [Color(0xFF9C27B0), Color(0xFFE91E63)],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, IconData icon, Widget valueWidget, List<Color> gradientColors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  child: valueWidget,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCountStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Error", style: TextStyle(color: Colors.white));

        if (!snapshot.hasData) return Text("0");

        final users = snapshot.data!.docs;
        final userCount = users.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['role'] == 'user';
        }).length;

        return Text(userCount.toString());
      },
    );
  }

  Widget _buildCollectionCountStream(String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Error", style: TextStyle(color: Colors.white));

        if (!snapshot.hasData) return Text("0");

        return Text(snapshot.data!.docs.length.toString());
      },
    );
  }

  Widget _buildRecentProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Products",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/ProductManagement'),
              child: Text(
                "View All",
                style: TextStyle(
                  color: Color(0xFF0e99c9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _buildRecentItemsTable('products', ['name', 'price', 'stock']),
      ],
    );
  }

  Widget _buildRecentItemsTable(String collection, List<String> columns) {
    return Container(
      width: double.infinity, // Makes container take full width
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection(collection)
              .orderBy('createdAt', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0e99c9)),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    "Error loading $collection",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    "No ${collection.replaceAll('messages', '')} found",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth, // Ensures table takes full width
                    ),
                    child: DataTable(
                      columnSpacing: 24,
                      horizontalMargin: 16,
                      headingRowHeight: 48,
                      dataRowHeight: 56,
                      headingRowColor: MaterialStateProperty.resolveWith<Color>(
                            (states) => Color(0xFF0e99c9).withOpacity(0.1),
                      ),
                      columns: columns.map((col) => DataColumn(
                        label: Container(
                          width: _calculateColumnWidth(col, columns, constraints.maxWidth),
                          child: Text(
                            col.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0e99c9),
                            ),
                          ),
                        ),
                      )).toList(),
                      rows: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DataRow(
                          cells: columns.map((col) => DataCell(
                            Container(
                              width: _calculateColumnWidth(col, columns, constraints.maxWidth),
                              child: Text(
                                data[col]?.toString() ?? 'N/A',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )).toList(),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  double _calculateColumnWidth(String column, List<String> allColumns, double maxWidth) {
    // Distribute width based on content
    final baseWidth = maxWidth / allColumns.length;
    switch (column) {
      case 'name': return baseWidth * 1; // Give more width to name
      case 'price': return baseWidth * 0.8;
      case 'stock': return baseWidth * 0.7;
      default: return baseWidth;
    }
  }
}