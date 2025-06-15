import 'package:authentication/widgets/admin_drawer.dart';
import 'package:authentication/widgets/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/authentication.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:universal_html/html.dart' as html;

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});
  static const String routeName = '/ProductManagement';

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  List<Uint8List> _imageBytes = []; // Changed to store bytes for both web and mobile
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isUploading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Uint8List>> _pickImages() async {
    if (kIsWeb) {
      // For web - use getMultiImagesAsBytes() instead
      final data = await ImagePickerWeb.getMultiImagesAsBytes();
      if (data == null) return [];
      return data;
    } else {
      // For mobile
      final pickedFiles = await _picker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFiles == null) return [];
      return await Future.wait(pickedFiles.map((file) => file.readAsBytes()));
    }
  }

  Future<String> _uploadImage(Uint8List bytes, String fileName) async {
    final ref = _storage.ref().child('product_images/$fileName');
    await ref.putData(bytes);
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        drawer: const AdminSideDrawer(),
        appBar: AppBar(
          title: const Text(
            'Product Management',
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
                        'Product Management',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0e99c9),
                        ),
                        onPressed: () => _showAddProductDialog(context),
                        child: const Text('Add Product', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
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
                stream: _firestore.collection('products').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading products'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs.where((doc) {
                    if (_searchQuery.isEmpty) return true;
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name']?.toString().toLowerCase() ?? '';
                    final description = data['description']?.toString().toLowerCase() ?? '';
                    return name.contains(_searchQuery) || description.contains(_searchQuery);
                  }).toList();

                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty ? 'No products found' : 'No matching products',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final data = product.data() as Map<String, dynamic>;
                      final stock = data['stock'] ?? 0;
                      final isAvailable = data['isAvailable'] ?? true;
                      final availability = stock > 0 && isAvailable ? 'Available' : 'N/A';
                      final images = List<String>.from(data['images'] ?? []);
                      final category = data['category'] ?? 'No Category';

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 3,
                        child: InkWell(
                          onTap: () => _showProductDetails(context, data, images),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (images.isNotEmpty)
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(images.first),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                  ),
                                const SizedBox(width: 12),
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
                                        'Price: \$${data['price']?.toStringAsFixed(2) ?? '0.00'}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Category: $category',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            'Stock: $stock',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: stock > 0 && isAvailable
                                                  ? Colors.green.withOpacity(0.2)
                                                  : Colors.red.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              availability,
                                              style: TextStyle(
                                                color: stock > 0 && isAvailable
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showEditProductDialog(context, product.id, data),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteProduct(product.id),
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

  void _showProductDetails(BuildContext context, Map<String, dynamic> data, List<String> images) {
    final stock = data['stock'] ?? 0;
    final isAvailable = data['isAvailable'] ?? true;
    final availability = stock > 0 && isAvailable ? 'Available' : 'N/A';
    final category = data['category'] ?? 'No Category';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data['name'] ?? 'Product Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (images.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            images[index],
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 60, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Price: \$${data['price']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Category: $category',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stock: $stock',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: $availability',
                  style: TextStyle(
                    fontSize: 16,
                    color: stock > 0 && isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (data['description'] != null && data['description'].toString().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(data['description']),
                    ],
                  ),
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

  Future<void> _showAddProductDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController(text: '1');
    final descController = TextEditingController();
    bool isAvailable = true;
    _imageBytes = [];
    _selectedCategory = null;
    _isUploading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Product'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Product Name*'),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Price*'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: stockController,
                        decoration: const InputDecoration(labelText: 'Stock Quantity*'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category*',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Analog', 'Digital'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a category' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: isAvailable,
                            onChanged: (value) {
                              setState(() {
                                isAvailable = value!;
                              });
                            },
                          ),
                          const Text('Make product available'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final bytes = await _pickImages();
                            if (bytes.isNotEmpty) {
                              setState(() {
                                _imageBytes = bytes;
                              });
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error picking images: $e')),
                            );
                          }
                        },
                        child: const Text('Upload Images'),
                      ),
                      if (_imageBytes.isNotEmpty)
                        Column(
                          children: [
                            Text(
                              '${_imageBytes.length} images selected',
                              style: const TextStyle(color: Colors.green),
                            ),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _imageBytes.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Image.memory(
                                      _imageBytes[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      if (_isUploading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isUploading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0e99c9),
                  ),
                  onPressed: _isUploading ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => _isUploading = true);

                      try {
                        List<String> imageUrls = [];

                        if (_imageBytes.isNotEmpty) {
                          for (var i = 0; i < _imageBytes.length; i++) {
                            final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
                            final url = await _uploadImage(_imageBytes[i], fileName);
                            imageUrls.add(url);
                          }
                        }

                        await _firestore.collection('products').add({
                          'name': nameController.text,
                          'price': double.parse(priceController.text),
                          'stock': int.parse(stockController.text),
                          'category': _selectedCategory,
                          'isAvailable': isAvailable,
                          'description': descController.text,
                          'images': imageUrls,
                          'createdAt': FieldValue.serverTimestamp(),
                          'updatedAt': FieldValue.serverTimestamp(),
                        });

                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product added successfully!')),
                        );
                      } catch (e) {
                        setState(() => _isUploading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error adding product: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditProductDialog(BuildContext context, String productId, Map<String, dynamic> data) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: data['name']);
    final priceController = TextEditingController(text: data['price']?.toString());
    final stockController = TextEditingController(text: data['stock']?.toString());
    final descController = TextEditingController(text: data['description']);
    bool isAvailable = data['isAvailable'] ?? true;
    _imageBytes = [];
    List<String> _existingImages = List.from(data['images'] ?? []);
    _selectedCategory = data['category'];
    _isUploading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Product'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Product Name*'),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Price*'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: stockController,
                        decoration: const InputDecoration(labelText: 'Stock Quantity*'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category*',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Analog', 'Digital'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a category' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: isAvailable,
                            onChanged: (value) {
                              setState(() {
                                isAvailable = value!;
                              });
                            },
                          ),
                          const Text('Make product available'),
                        ],
                      ),
                      if (_existingImages.isNotEmpty) ...[
                        const Text('Current Images:'),
                        Wrap(
                          children: _existingImages.map((url) => Stack(
                            children: [
                              Image.network(url, width: 80, height: 80),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _existingImages.remove(url);
                                    });
                                  },
                                ),
                              ),
                            ],
                          )).toList(),
                        ),
                      ],
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final bytes = await _pickImages();
                            if (bytes.isNotEmpty) {
                              setState(() {
                                _imageBytes = bytes;
                              });
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error picking images: $e')),
                            );
                          }
                        },
                        child: const Text('Add More Images'),
                      ),
                      if (_imageBytes.isNotEmpty) ...[
                        const Text('New Images:'),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imageBytes.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.memory(
                                  _imageBytes[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      if (_isUploading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isUploading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0e99c9),
                  ),
                  onPressed: _isUploading ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => _isUploading = true);

                      try {
                        List<String> allImageUrls = List.from(_existingImages);

                        if (_imageBytes.isNotEmpty) {
                          for (var i = 0; i < _imageBytes.length; i++) {
                            final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
                            final url = await _uploadImage(_imageBytes[i], fileName);
                            allImageUrls.add(url);
                          }
                        }

                        await _firestore.collection('products').doc(productId).update({
                          'name': nameController.text,
                          'price': double.parse(priceController.text),
                          'stock': int.parse(stockController.text),
                          'category': _selectedCategory,
                          'isAvailable': isAvailable,
                          'description': descController.text,
                          'images': allImageUrls,
                          'updatedAt': FieldValue.serverTimestamp(),
                        });

                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product updated successfully!')),
                        );
                      } catch (e) {
                        setState(() => _isUploading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating product: $e')),
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

  Future<void> _deleteProduct(String productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
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

    if (confirmed == true) {
      try {
        await _firestore.collection('products').doc(productId).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting product: $e')),
        );
      }
    }
  }
}