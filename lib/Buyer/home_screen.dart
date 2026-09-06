import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hugeicons/hugeicons.dart';

import '../Buyer/product_screen.dart';
import '../Buyer/save_item.dart';
import '../Buyer/my_order.dart';
import '../Buyer/my_profile.dart';
import '../Buyer/product_detail.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _markNotificationsAsRead();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  
  Future<void> _toggleFavorite(String productId, Map<String, dynamic> productData) async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save favorites!')),
      );
      return;
    }

    final favDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId);

    final docSnapshot = await favDocRef.get();

    if (docSnapshot.exists) {
      await favDocRef.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from Favorites')),
      );
    } else {
      await favDocRef.set({
        'productId': productId,
        'productName': productData['productName'] ?? productData['title'] ?? '',
        'price': productData['price'] ?? 0,
        'imageUrl': productData['imageUrl'] ?? productData['image'] ?? '',
        'addedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to Favorites!')),
      );
    }
  }

  
  Future<void> _markNotificationsAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('buyerId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final String currentBuyerId = currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('FANCY', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('notifications')
                              .where('buyerId', isEqualTo: currentBuyerId)
                              .where('isRead', isEqualTo: false)
                              .snapshots(),
                          builder: (context, snapshot) {
                            bool hasUnread = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                                );
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.notifications_none, size: 22, color: Colors.black),
                                  ),
                                  if (hasUnread)
                                    Positioned(
                                      right: 2,
                                      top: 2,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${snapshot.data!.docs.length}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      currentUser == null
                          ? const CircleAvatar(
                              radius: 16,
                             backgroundImage: NetworkImage(''),
                            )
                          : StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUser.uid)
                                  .snapshots(),
                              builder: (context, userSnapshot) {
                                String? profileImageUrl;

                                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                                  profileImageUrl = userData?['profileImage'] ?? userData?['imageUrl'] ?? currentUser.photoURL;
                                } else {
                                  profileImageUrl = currentUser.photoURL;
                                }

                                return CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                                      ? NetworkImage(profileImageUrl) as ImageProvider
                                      : const NetworkImage(''),
                                );
                              },
                            ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search products by name or category...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : GestureDetector(
                          onTap: () {
                            FocusScope.of(context).requestFocus(_searchFocusNode);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(50)),
                            child: const Icon(Icons.search, color: Colors.black),
                          ),
                        ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              
              if (searchQuery.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 210, 208, 116),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.85,
                    children: [
                      _buildCategoryItem(Icons.watch_outlined, 'Watches'),
                      _buildCategoryItem(Icons.shopping_bag_outlined, 'Bags'),
                      _buildCategoryItem(Icons.auto_fix_high, 'Beauty'),
                      _buildCategoryItem(Icons.checkroom, 'Clothing'),
                      _buildCategoryItem(Icons.panorama_horizontal_select_rounded, 'Accessories'),
                      _buildCategoryItem(Icons.snowshoeing, 'Shoes'),
                      _buildCategoryItem(Icons.favorite_outline, 'Lifestyle'),
                      _buildCategoryItem(Icons.more_horiz, 'More'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    searchQuery.isEmpty ? 'Recommended Styles' : 'Search Results',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (searchQuery.isNotEmpty)
                    Text(
                      'for "$searchQuery"',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collectionGroup('products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Text('No products available right now.', style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }

                  final allDocs = snapshot.data!.docs;

                  final filteredDocs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = (data['productName'] ?? data['title'] ?? '').toString().toLowerCase();
                    final category = (data['category'] ?? '').toString().toLowerCase();

                    if (searchQuery.isEmpty) return true;
                    return title.contains(searchQuery) || category.contains(searchQuery);
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          'No products found matching "$searchQuery".',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final String productId = doc.id;

                      final String title = data['productName'] ?? data['title'] ?? 'No Title';
                      final String price = data['price']?.toString() ?? '0';
                      final String imageUrl = data['imageUrl'] ?? data['image'] ?? '';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                productId: productId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                        image: imageUrl.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(imageUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: imageUrl.isEmpty
                                          ? const Icon(Icons.image_not_supported, color: Colors.grey)
                                          : null,
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: currentUser == null
                                          ? GestureDetector(
                                              onTap: () => _toggleFavorite(productId, data),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.favorite_border, size: 18, color: Colors.black),
                                              ),
                                            )
                                          : StreamBuilder<DocumentSnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(currentUser.uid)
                                                  .collection('favorites')
                                                  .doc(productId)
                                                  .snapshots(),
                                              builder: (context, favSnapshot) {
                                                bool isFavorite = favSnapshot.hasData && favSnapshot.data!.exists;

                                                return GestureDetector(
                                                  onTap: () => _toggleFavorite(productId, data),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                                      size: 18,
                                                      color: isFavorite ? Colors.red : Colors.white,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                title,
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$$price',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
              );
              break;
            case 4:
              setState(() {
                selectedIndex = 4;
              });

              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: 'ProfileOverlay',
                barrierColor: Colors.transparent,
                transitionDuration: const Duration(milliseconds: 200),
                pageBuilder: (context, anim1, anim2) {
                  return const ProfileMenuOverlayScreen();
                },
              ).then((_) {
                setState(() {
                  selectedIndex = 0;
                });
              });
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favourite'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Order'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchController.text = title.toLowerCase();
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}