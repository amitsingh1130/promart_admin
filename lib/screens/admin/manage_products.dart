import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../models/product_model.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final ImagePicker _picker = ImagePicker();
  
  // ImgBB API Key
  final String imgBBKey = " ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products found. Add some!'));
          }
          
          final docs = snapshot.data!.docs;
          
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final product = Product.fromFirestore(data, docs[index].id);
              
              return _buildProductCard(product);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showProductDialog(context, product: product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: product.imageUrl.isNotEmpty 
                        ? Image.network(product.imageUrl, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                  if (product.images.length > 1)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${product.images.length} images',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _deleteProduct(context, product.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.price}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(product.rating.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDialog(BuildContext context, {Product? product}) {
    final nameController = TextEditingController(text: product?.name);
    final priceController = TextEditingController(text: product?.price.toString());
    final oldPriceController = TextEditingController(text: product?.oldPrice.toString());
    final categoryController = TextEditingController(text: product?.category);
    final brandController = TextEditingController(text: product?.brand);
    final descController = TextEditingController(text: product?.description);
    final ratingController = TextEditingController(text: product?.rating.toString());
    
    List<Uint8List> newImages = [];
    List<String> existingImages = product?.images != null ? List.from(product!.images) : [];
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickImages() async {
            try {
              final List<XFile> files = await _picker.pickMultiImage(imageQuality: 70);
              if (files.isNotEmpty) {
                for (var file in files) {
                  final bytes = await file.readAsBytes();
                  newImages.add(bytes);
                }
                setDialogState(() {});
              }
            } catch (e) {
              debugPrint('Error picking images: $e');
            }
          }

          Future<void> captureImage() async {
            try {
              final XFile? file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
              if (file != null) {
                final bytes = await file.readAsBytes();
                newImages.add(bytes);
                setDialogState(() {});
              }
            } catch (e) {
              debugPrint('Error capturing image: $e');
            }
          }

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Text(product == null ? 'Add New Product' : 'Edit Product', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Multi-Image Preview
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) => SafeArea(
                                child: Wrap(
                                  children: [
                                    ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () { Navigator.pop(ctx); captureImage(); }),
                                    ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () { Navigator.pop(ctx); pickImages(); }),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Icon(Icons.add_a_photo_outlined, color: Colors.grey), SizedBox(height: 4), Text('Add Image', style: TextStyle(fontSize: 10, color: Colors.grey))],
                            ),
                          ),
                        ),
                        // Existing Images from Firestore
                        ...existingImages.map((url) => Stack(
                          children: [
                            Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!), image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)),
                            ),
                            Positioned(
                              top: 4, right: 12,
                              child: GestureDetector(
                                onTap: () => setDialogState(() => existingImages.remove(url)),
                                child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                              ),
                            ),
                          ],
                        )),
                        // New Picked Images
                        ...newImages.map((bytes) => Stack(
                          children: [
                            Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!), image: DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover)),
                            ),
                            Positioned(
                              top: 4, right: 12,
                              child: GestureDetector(
                                onTap: () => setDialogState(() => newImages.remove(bytes)),
                                child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Product Name')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price (₹)'), keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: oldPriceController, decoration: const InputDecoration(labelText: 'Old Price (₹)'), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: ratingController, decoration: const InputDecoration(labelText: 'Rating'), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: brandController, decoration: const InputDecoration(labelText: 'Brand')),
                  const SizedBox(height: 12),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isUploading ? null : () async {
                        if (nameController.text.isEmpty || priceController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
                          return;
                        }
                        if (newImages.isEmpty && existingImages.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one image')));
                          return;
                        }

                        setDialogState(() => isUploading = true);

                        try {
                          List<String> finalImageUrls = List.from(existingImages);

                          // Upload new images to ImgBB
                          for (var bytes in newImages) {
                            var request = http.MultipartRequest('POST', Uri.parse('https://api.imgbb.com/1/upload?key=$imgBBKey'));
                            request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: 'product.jpg'));
                            
                            var response = await request.send();
                            var responseData = await response.stream.bytesToString();
                            var jsonResponse = json.decode(responseData);

                            if (response.statusCode == 200) {
                              finalImageUrls.add(jsonResponse['data']['url']);
                            } else {
                              throw 'ImgBB Error: ${jsonResponse['error']['message'] ?? "Unknown error"}';
                            }
                          }

                          final data = {
                            'name': nameController.text,
                            'price': double.tryParse(priceController.text) ?? 0.0,
                            'oldPrice': double.tryParse(oldPriceController.text) ?? 0.0,
                            'category': categoryController.text,
                            'brand': brandController.text,
                            'rating': double.tryParse(ratingController.text) ?? 0.0,
                            'imageUrl': finalImageUrls.isNotEmpty ? finalImageUrls[0] : '', // First image as thumbnail
                            'images': finalImageUrls, // List of all images
                            'description': descController.text,
                          };

                          if (product == null) {
                            await FirebaseFirestore.instance.collection('products').add(data);
                          } else {
                            await FirebaseFirestore.instance.collection('products').doc(product.id).update(data);
                          }
                          
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          debugPrint('UPLOAD ERROR: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                            setDialogState(() => isUploading = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
                      child: isUploading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : Text(product == null ? 'ADD PRODUCT' : 'UPDATE PRODUCT', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _deleteProduct(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('products').doc(id).delete();
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
