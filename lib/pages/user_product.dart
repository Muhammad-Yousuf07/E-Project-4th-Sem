import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Custom Icon Button with Counter widget
class IconBtnWithCounter extends StatelessWidget {
  final String svgSrc;
  final int numOfitem;
  final VoidCallback press;

  const IconBtnWithCounter({
    required this.svgSrc,
    required this.numOfitem,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: SvgPicture.asset(svgSrc, height: 24, width: 24),
          onPressed: press,
        ),
        if (numOfitem != 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              height: 18,
              width: 18,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                "$numOfitem",
                style: TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class UserProductsPage extends StatefulWidget {
  static const String routeName = '/ProductPage';

  @override
  State<UserProductsPage> createState() => _UserProductsPageState();
}

class _UserProductsPageState extends State<UserProductsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0e99c9),
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/HomePage");
          },
        ),
        title: Text(
          "Products",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // Search bar + icons row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Products...',
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val.toLowerCase();
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                // Wishlist Icon
                IconBtnWithCounter(
                  svgSrc: "assets/icons/Heart Icon.svg",
                  numOfitem: 0,
                  press: () {},
                ),
                // Filter Icon
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list, color: Colors.black, size: 30,),
                  onSelected: (value) {
                    print("Selected: $value");
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'All', child: Text('All')),
                    PopupMenuItem(value: 'Analog', child: Text('Analog')),
                    PopupMenuItem(value: 'Digital', child: Text('Digital')),
                  ],
                ),

              ],
            ),
          ),

          // Product List
          Expanded(
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
                  return Center(child: CircularProgressIndicator());
                }

                final allProducts = snapshot.data!.docs;

                // Filter products based on search query
                final products = allProducts.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      searchQuery.isEmpty
                          ? 'No products found.'
                          : 'No results for "$searchQuery"',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final data = products[index].data() as Map<String, dynamic>;
                      final images = List<String>.from(data['images'] ?? []);
                      final productId = products[index].id;
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
                                        topRight: Radius.circular(16),
                                      ),
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
                                              '\$${(data['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
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
