import 'package:authentication/pages/admin_page.dart';
import 'package:authentication/pages/customer_support.dart';
import 'package:authentication/widgets/auth_guard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FAQAdminPage extends StatefulWidget {
  static const String routeName = '/FAQAdminPage';

  @override
  _FAQAdminPageState createState() => _FAQAdminPageState();
}

class _FAQAdminPageState extends State<FAQAdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  String _editDocId = '';

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _questionController.clear();
    _answerController.clear();
    _editDocId = '';
  }

  Future<void> _addOrUpdateFAQ() async {
    if (_questionController.text.isEmpty || _answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill both question and answer')),
      );
      return;
    }

    try {
      if (_editDocId.isEmpty) {
        // Add new FAQ
        await _firestore.collection('faqs').add({
          'question': _questionController.text,
          'answer': _answerController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('FAQ added successfully')),
        );
      } else {
        // Update existing FAQ
        await _firestore.collection('faqs').doc(_editDocId).update({
          'question': _questionController.text,
          'answer': _answerController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('FAQ updated successfully')),
        );
      }
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteFAQ(String docId) async {
    try {
      await _firestore.collection('faqs').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('FAQ deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _editFAQ(DocumentSnapshot faq) {
    _questionController.text = faq['question'];
    _answerController.text = faq['answer'];
    _editDocId = faq.id;
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Manage FAQs",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminPage()),
              );
            },
          ),
          backgroundColor: Color(0xFF0e99c9),
          iconTheme: IconThemeData(color: Colors.white, weight: 20, size: 26),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _clearForm();
                _showFAQDialog(context);
              },
            ),
          ],
        ),
        body: Container(
          color: Color(0xFFeeeeee),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('faqs').orderBy('createdAt').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No FAQs available yet.\nAdd some using the + button.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final faq = snapshot.data!.docs[index];
                  return Card(
                    color: Colors.grey.shade200,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        faq['question'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        faq['answer'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _editFAQ(faq);
                              _showFAQDialog(context);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(context, faq.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_editDocId.isEmpty ? 'Add New FAQ' : 'Edit FAQ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _answerController,
                  decoration: InputDecoration(
                    labelText: 'Answer',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearForm();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addOrUpdateFAQ();
                Navigator.pop(context);
              },
              child: Text(_editDocId.isEmpty ? 'Add' : 'Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0e99c9),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this FAQ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteFAQ(docId);
                Navigator.pop(context);
              },
              child: Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
}