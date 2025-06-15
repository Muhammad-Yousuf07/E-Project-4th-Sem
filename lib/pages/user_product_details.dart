import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  static const String routeName = '/ProductDetailPage';

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  bool isWishlisted = false;
  Map<String, dynamic>? productData;
  bool isLoading = true;
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  void fetchProduct() async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
    if (doc.exists) {
      setState(() {
        productData = doc.data() as Map<String, dynamic>;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Yeh images list bana le — productData load hone ke baad
    final List<String> images =
    productData != null ? List<String>.from(productData!['images'] ?? []) : [];

    return Scaffold(
      backgroundColor: Color(0xFFeeeeee),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : productData == null
          ? Center(child: Text('Product not found'))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/ProductPage");
                  },
                ),
              ),
            ),

            // Product Image
            Center(
              child: ClipRRect(
                child: images.isNotEmpty
                    ? Image.network(
                  images.first,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 200,
                  width: 250,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 80, color: Colors.grey[500]),
                ),
              ),
            ),

            SizedBox(height: 40),

            // White Container
            Container(
              width: MediaQuery.of(context).size.width,
              height: 270,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Wishlist Icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          productData!['name'] ?? 'No Name',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
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
                          color: Color(0xFF0e99c9),
                          size: 26,
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 10),

                  // Price
                  Text(
                    '\$${(productData!['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0e99c9)),
                  ),

                  SizedBox(height: 20),

                  // Description and Quantity Selector Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 6),
                            Text(
                              productData!['description'] ??
                                  'No description available.',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),

                      // Quantity Selector
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (quantity > 1) quantity--;
                                });
                              },
                              icon: Icon(Icons.remove,
                                  size: 28, color: Colors.black87),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '$quantity',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                              icon: Icon(Icons.add,
                                  size: 28, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add to cart logic
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Color(0xFF0e99c9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Add To Cart',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
