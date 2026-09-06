import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'payment_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId; 

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  
  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.productId)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          isFavorite = true;
        });
      }
    }
  }

  
  Future<void> _toggleFavorite(Map<String, dynamic> productData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save favorites!')),
      );
      return;
    }

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.productId);

    if (isFavorite) {
      await favRef.delete();
      setState(() => isFavorite = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from Favorites')),
      );
    } else {
      await favRef.set({
        'productId': widget.productId,
        'productName': productData['productName'] ?? productData['title'] ?? '',
        'price': productData['price'] ?? 0,
        'imageUrl': productData['imageUrl'] ?? productData['image'] ?? '',
        'addedAt': FieldValue.serverTimestamp(),
      });
      setState(() => isFavorite = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to Favorites!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collectionGroup('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Product details not found.'));
          }

          
          var productDoc;
          try {
            productDoc = snapshot.data!.docs.firstWhere((doc) => doc.id == widget.productId);
          } catch (e) {
            return const Center(child: Text('Product does not exist.'));
          }

          final data = productDoc.data() as Map<String, dynamic>;
          final String title = data['productName'] ?? data['title'] ?? 'No Title';
          final String price = data['price']?.toString() ?? '0';
          final String imageUrl = data['imageUrl'] ?? data['image'] ?? '';
          final String description = data['description'] ?? 'No description available for this product.';
          final String location = data['location'] ?? 'Aisa Pakistan';
          final String category = data['category'] ?? 'Standard';
          return Stack(
            children: [
              
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Stack(
                      children: [
                        Container(
                          height: 350,
                          width: double.infinity,
                          color: Colors.grey[100],
                          child: imageUrl.isNotEmpty
                              ? Image.network(imageUrl, fit: BoxFit.cover)
                              : const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('1/1', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text('Rs. ${(num.tryParse(price) ?? 0) * 2} off with Promo', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text('Rs. $price', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                                      const SizedBox(width: 8),
                                       Text('Rs. ${(num.tryParse(price) ?? 0) * 3}', style: TextStyle(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                                        child: const Text('-67%', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.grey,
                                  size: 26,
                                ),
                                onPressed: () => _toggleFavorite(data),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          
                          Text(
                            title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),

                          
                          Row(
                            children: const [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Icon(Icons.star_border, color: Colors.grey, size: 16),
                              Icon(Icons.star_border, color: Colors.grey, size: 16),
                              SizedBox(width: 6),
                              Text('3.0 (1)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const Divider(height: 30),

                          
                          const Text('Product Options', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.amber),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.grey[200],
                                  child: imageUrl.isNotEmpty ? Image.network(imageUrl, fit: BoxFit.cover) : const Icon(Icons.image),
                                ),
                                const SizedBox(width: 8),
                                 Text(' $category', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          const Divider(height: 30),

                          
                          const Text('Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:  [
                              Text(' $location', style: TextStyle(fontSize: 13, color: Colors.blue)),
                              const  Text('Rs. 190', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const Text('Standard Delivery, Guaranteed by 8-10 Day', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const Divider(height: 30),

                          
                          const Text('Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          const Text('• 14 days easy return', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const Text('• Warranty not available', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber, 
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                        _showCheckoutBottomSheet(context, {
                          'imageUrl': imageUrl,
                          'price': price,
                          'productName': title,
                          'sellerId': data['sellerId'] ?? '',
                          
                        });
                      },
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}



void _showCheckoutBottomSheet(BuildContext context, Map<String, dynamic> productData) {
  String selectedSize = 'Black, 2-3yrs';
  
  
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, 
    backgroundColor: Colors.transparent, 
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            
            height: MediaQuery.of(context).size.height * 0.85, 
            decoration: const BoxDecoration(
              color: Color.fromARGB(244, 46, 45, 45),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(productData['imageUrl'] ?? ''),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(
                                    'Rs. ${(num.tryParse(productData['price']) ?? 0) * 2} off with Promo',
                                    style: TextStyle(color: const Color.fromARGB(255, 228, 217, 216), fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Rs. ${productData['price'] ?? 665}',
                                    style: const TextStyle(color: Color.fromARGB(255, 255, 254, 253), fontSize: 22, fontWeight: FontWeight.bold , ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        'Rs. ${(num.tryParse(productData['price']) ?? 0) * 3}',
                                        style: TextStyle(color: const Color.fromARGB(255, 244, 67, 54), decoration: TextDecoration.lineThrough, fontSize: 13),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red[50],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('-65%', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Size: $selectedSize',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 10),

                        
                        const Text('Color Family', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 10),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange, width: 2),
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(productData['imageUrl'] ?? ''),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        
                         Center(

                          child: Text(
                            
                            'Payment',
                            style: TextStyle(color: Colors.white70, fontSize: 28 , fontWeight: FontWeight.bold),
                          ),
                        ),
                       

                         
                        
                        const Text(
                          'Card Number',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: cardNumberController,
                           
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0000 0000 0000 0000 ',
                            filled: true,
                            fillColor:  Color.fromARGB(255, 75, 72, 72),
                            suffixIcon: const Icon(Icons.credit_card, color: Colors.orange),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: expiryController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'MM / YYYY',
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor:  const Color.fromARGB(255, 75, 72, 72),
                                  suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: cvvController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'CVV',
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Color.fromARGB(255, 75, 72, 72),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.grey, 
                      padding: const EdgeInsets.symmetric( vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                      onPressed: () async {
                      try {
                        
                        String buyerId = FirebaseAuth.instance.currentUser!.uid;

                        
                        String sellerId = productData['sellerId'] ?? ''; 
                        String productName = productData['productName'] ?? 'Product'; 
                        String productPrice = productData['price'].toString();

                        print("Saving order for Seller: $sellerId");

                        
                        await FirebaseFirestore.instance.collection('orders').add({
                          'buyerId': buyerId,
                          'sellerId': sellerId,
                          'productName': productName,
                          'imageUrl': productData['imageUrl'] ?? '',
                          'price': productPrice,
                          'status': 'Pending',
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        print("Order successfully saved to Firestore!");

                        
                        if (context.mounted) {
                          Navigator.pop(context); 
                        }

                        
                        if (context.mounted) {
                          PaymentReceiptDialog.show(context, amountPaid: productPrice);
                        }
                        
                      } catch (e) {
                        print("Error saving order: $e");
                      }
                    },
                    child: const Text(
                      'Confirm Order',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}