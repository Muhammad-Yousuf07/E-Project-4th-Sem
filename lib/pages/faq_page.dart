import 'package:authentication/pages/customer_support.dart';
import 'package:authentication/widgets/auth_guard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  static const String routeName = '/FAQPage';

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(title: const Text("FAQ's", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
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
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search FAQs...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) {
                    setState(() {
                      searchQuery = val.toLowerCase();
                    });
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('faqs').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No FAQs available yet.\nPlease check back later.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }
      
                    // Filter FAQs based on search query
                    final faqs = snapshot.data!.docs.where((doc) {
                      final question = doc['question'].toString().toLowerCase();
                      final answer = doc['answer'].toString().toLowerCase();
                      return question.contains(searchQuery) || answer.contains(searchQuery);
                    }).toList();
      
                    if (faqs.isEmpty) {
                      return Center(
                        child: Text(
                          "No results found for \"$searchQuery\"",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }
      
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      itemCount: faqs.length,
                      itemBuilder: (context, index) {
                        final faq = faqs[index];
                        return Card(
                          color: Colors.grey.shade200,
                          margin: EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          child: ExpansionTile(
                            iconColor: Colors.grey.shade600,
                            collapsedIconColor: Colors.grey.shade600,
                            title: Text(
                              faq['question'],
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            children: [
                              Text(
                                faq['answer'],
                                style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.4),
                              ),
                            ],
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
      ),
    );
  }
}
