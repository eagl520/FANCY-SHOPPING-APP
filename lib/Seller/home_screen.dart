import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'add_product.dart';
import 'profile_screen.dart';
import 'order_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  String selectedCategory = 'All';
   String? shopName;

   bool hasNewNotification = true;
  
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> categories = [
    'All',
    'Lifestyle',
    'Shoes',
    'Accessories',
    'Clothing',
    'Beauty',
    'Bags',
    'Watches',
  ];

  @override
  void initState() {
    super.initState();
   
    
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
/*
   Future<void> _markNotificationsAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('buyerId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }*/

  @override
  Widget build(BuildContext context) {
    
    final User? currentUser = FirebaseAuth.instance.currentUser;
     final String currentBuyerId = currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'FANCY',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
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
                                  MaterialPageRoute(builder: (context) => const SellerOrdersScreen()),
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
                      const SizedBox(width: 10),
                      
                      
                      currentUser == null
                          ? const CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(''),
                            )
                          : StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUser.uid)
                                  .snapshots(),
                              builder: (context, userSnapshot) {
                                String? profileImgUrl;
                               
                                
                                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                                  
                                  profileImgUrl = userData?['profileImage'] ?? userData?['imageUrl'] ?? currentUser.photoURL;
                                  shopName = userData?['ShopName'];
                                } else {
                                  profileImgUrl = currentUser.photoURL;
                                }

                                return CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: (profileImgUrl != null && profileImgUrl.isNotEmpty)
                                      ? NetworkImage(profileImgUrl)
                                      : const NetworkImage('') as ImageProvider,
                                );
                              },
                            ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black54, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase().trim();
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search products by name...',
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                        child: const Icon(Icons.close, size: 18, color: Colors.grey),
                      ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.search, size: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:  [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(
                                    'New Orders:', 
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              Icon(Icons.storefront, size: 20),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text('${shopName ?? 'My Store'}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:  [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(
                                    'New Orders', 
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8), 
                                const Icon(Icons.shopping_cart_outlined, size: 20),
                              
                            ],
                          ),
                          SizedBox(height: 6),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('orders') 
                                .where('buyerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
                                
                                .snapshots(),
                            builder: (context, snapshot) {
                              
                              int pendingCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

                              return Text(
                                '$pendingCount Pending',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat == selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color.fromARGB(255, 70, 68, 68)  : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                              color: isSelected ? const Color.fromARGB(255, 19, 18, 17) : Colors.grey.shade300,
                            ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                          
                          
                          fontSize: 14
                          ,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Product Management',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            
            Expanded(
              child: currentUser == null
                  ? const Center(child: Text('Please login to view your products'))
                  : StreamBuilder<QuerySnapshot>(
                      stream: selectedCategory == 'All'
                          ? FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .collection('products')
                              .orderBy('createdAt', descending: true)
                              .snapshots()
                          : FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .collection('products')
                              .where('category', isEqualTo: selectedCategory)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No products found!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        final docs = snapshot.data!.docs;

                        final filteredDocs = docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final String title = (data['productName'] ?? '').toString().toLowerCase();
                          return title.contains(_searchQuery);
                        }).toList();

                        if (filteredDocs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No matching products found!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.builder(
                            itemCount: filteredDocs.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemBuilder: (context, index) {
                              final doc = filteredDocs[index];
                              final data = doc.data() as Map<String, dynamic>;

                              final String title = data['productName'] ?? 'No Title';
                              final String price = data['price']?.toString() ?? '0';
                              final String imageUrl = data['imageUrl'] ?? '';
                              final bool inStock = data['inStock'] ?? true;

                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: 110,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                            image: DecorationImage(
                                              image: NetworkImage(imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '\$$price',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Transform.scale(
                                                scale: 0.6,
                                                alignment: Alignment.centerLeft,
                                                child: Switch(
                                                  value: inStock,
                                                  activeColor: const Color(0xFFFFD700),
                                                  onChanged: (val) async {
                                                    await FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(currentUser.uid)
                                                        .collection('products')
                                                        .doc(doc.id)
                                                        .update({'inStock': val});
                                                  },
                                                ),
                                              ),
                                              IconButton(
                                                constraints: const BoxConstraints(),
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                                onPressed: () async {
                                                  await FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(currentUser.uid)
                                                      .collection('products')
                                                      .doc(doc.id)
                                                      .delete();
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        
      ),
       
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[400],
        onTap: (index) {
          if (index == 0) {
            
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProductScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false, 
                pageBuilder: (context, animation, secondaryAnimation) => const ProfileMenuOverlayScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            
            icon: Container(
              padding: const EdgeInsets.all(0),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.black),
            ),
            label: 'Add Product',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}