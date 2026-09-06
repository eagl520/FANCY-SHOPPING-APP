import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Buyer/home_screen.dart';  
import '../Seller/home_screen.dart'; 

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = 'Buyer';
  bool _isLoading = false;

  Future<void> _saveRoleAndProceed() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'role': _selectedRole,
      });

      if (mounted) {
        
        if (_selectedRole == 'Buyer') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()), 
            (route) => false,
          );
        } else if (_selectedRole == 'Seller') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SellerDashboardScreen()), 
            (route) => false,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 59, 58, 58),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose Your Role",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please select how you want to use the application.",
                style: TextStyle(fontSize: 14, color: Colors.white60),
              ),
              const SizedBox(height: 30),

              
              Container(
                decoration: BoxDecoration(
                  color: _selectedRole == 'Buyer' ? Colors.white12 : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedRole == 'Buyer' ? Colors.white : Colors.white24,
                  ),
                ),
                child: RadioListTile<String>(
                  title: const Text('Buyer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Explore and buy fashion items', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  value: 'Buyer',
                  groupValue: _selectedRole,
                  activeColor: Colors.white,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              
              Container(
                decoration: BoxDecoration(
                  color: _selectedRole == 'Seller' ? Colors.white12 : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedRole == 'Seller' ? Colors.white : Colors.white24,
                  ),
                ),
                child: RadioListTile<String>(
                  title: const Text('Seller', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text('List and sell your items', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  value: 'Seller',
                  groupValue: _selectedRole,
                  activeColor: Colors.white,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 40),

              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _saveRoleAndProceed,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}