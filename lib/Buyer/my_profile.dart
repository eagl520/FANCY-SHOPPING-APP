import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

import '../Account/login_screen.dart';
import 'save_item.dart';
import 'my_order.dart';
import '../Buyer/profile/edit_screen.dart';
import 'notification_screen.dart';
import 'terms_condition_screen.dart';


class ProfileMenuOverlayScreen extends StatefulWidget { 
  const ProfileMenuOverlayScreen({super.key});

  @override
  State<ProfileMenuOverlayScreen> createState() => _ProfileMenuOverlayScreenState();
}

class _ProfileMenuOverlayScreenState extends State<ProfileMenuOverlayScreen> {
  String _userName = 'Loading...';
  String _userAddress = 'Loading...';
  String? _profileImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _userName = data['fullName'] ?? currentUser.displayName ?? 'No Name';
            _userAddress = data['address'] ?? 'No Address Added';
            _profileImageUrl = data['profileImage'];
          });
        } else {
          setState(() {
            _userName = currentUser.displayName ?? 'User';
            _userAddress = 'No Address Added';
          });
        }
      }
    } catch (e) {
      print("Error fetching profile menu data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.78,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 12.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                ? NetworkImage(_profileImageUrl!) as ImageProvider
                                : const NetworkImage(''),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userName, 
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _userAddress, 
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            title: 'Edit Profile',
                            onTap: () async {
                              
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                              );
                              _fetchUserData(); 
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.notifications_none,
                            title: 'Notifications',
                            onTap: () {
                              Navigator.push(
                                context,
                               MaterialPageRoute(builder: (context) => const NotificationScreen()),
                              );
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.shopping_bag_outlined,
                            title: 'My Orders',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
                              );
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.favorite_border,
                            title: 'Favourites',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const WishlistScreen()),
                              );
                            },
                          ),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                          ),

                          _buildMenuItem(
                            icon: Icons.help_outline,
                            title: 'Terms & Conditions',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TermsConditionScreen()),
                              );
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.logout_outlined,
                            title: 'Logout',
                            color: Colors.red, 
                            onTap: () async {
                              try {
                                await FirebaseAuth.instance.signOut();

                                final SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.clear();

                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Logout Error: $e')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? Colors.black87; 

    return ListTile(
      leading: Icon(
        icon, 
        color: itemColor,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: itemColor,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 8,
    );
  }
}