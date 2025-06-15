import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class UserProductsPage extends StatefulWidget {
  static const String routeName = '/ProductPage';

  @override
  State<UserProductsPage> createState() => _UserProductsPageState();
}

class _UserProductsPageState extends State<UserProductsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: false,
            floating: true,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/HomePage");
              },
            ),
            title: Text(
              "Products",
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            actions: [
              PopupMenuButton<String>(
                padding: EdgeInsets.only(right: 16),
                icon: Icon(Icons.filter_list, color: Colors.black),
                onSelected: (value) {
                  print("Selected: $value");
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'All',
                    child: Text('All'),
                  ),
                  PopupMenuItem(
                    value: 'Analog',
                    child: Text('Analog'),
                  ),
                  PopupMenuItem(
                    value: 'Digital',
                    child: Text('Digital'),
                  ),
                ],
              ),
            ],
          ),

          // Product List (sliver)
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('products')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading products'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center();
                }

                final products = snapshot.data!.docs;

                if (products.isEmpty) {
                  return Center(child: Text('No products found'));
                }

                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final data = products[index].data() as Map<String, dynamic>;
                      final images = List<String>.from(data['images'] ?? []);
                      final product = products[index];
                      final productId = product.id;
                      bool isWishlisted = false;

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                "/ProductDetailPage",
                                arguments: productId,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(16)),
                                      child: images.isNotEmpty
                                          ? Image.network(
                                        images.first,
                                        fit: BoxFit.cover,
                                      )
                                          : Container(
                                        color: Colors.grey[300],
                                        child: Icon(Icons.image,
                                            size: 60, color: Colors.grey[600]),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['name'] ?? 'No Name',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              '\$${data['price']?.toStringAsFixed(2) ?? '0.00'}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF0e99c9),
                                              ),
                                            ),
                                            Spacer(),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  isWishlisted = !isWishlisted;
                                                });
                                              },
                                              child: Icon(
                                                isWishlisted
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                size: 20,
                                                color: Color(0xFF0e99c9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),


    );
  }
}
