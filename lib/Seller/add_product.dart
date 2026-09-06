import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final String imgBbApiKey = 'fc9ed1328f4eba0fbd8d6beb26344f8f';

  XFile? _selectedImageFile; 
  String? _selectedCategory;

  final List<String> categories = [

      'Accessories',
      'Clothing',
      'Lifestyle',
      'Watches',
      'Beauty',
      'Shoes',
      'Bags',
      
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _colorController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  
  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImageFile = image; 
      });
    }
  }

  
  
  
  Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    if (_selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product image!')),
      );
      return;
    }

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No user logged in!')),
      );
      return;
    }

    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      ),
    );

    try {
      String sellerUid = currentUser.uid;
      String sellerEmail = currentUser.email ?? '';

      
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(sellerUid)
          .get();

      String sellerName = 'Unknown Seller';
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        sellerName = userData['name'] ?? userData['fullName'] ?? 'Seller';
      }

      
      List<int> imageBytes = await _selectedImageFile!.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      var response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload?key=$imgBbApiKey'),
        body: {
          'image': base64Image,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to upload image to ImgBB');
      }

      var jsonResponse = jsonDecode(response.body);
      String downloadUrl = jsonResponse['data']['url']; 

      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(sellerUid)
          .collection('products')
          .add({
        'sellerId': sellerUid,
        'sellerName': sellerName,
        'sellerEmail': sellerEmail,
        'productName': _nameController.text.trim(),
        'category': _selectedCategory,
        'price': double.parse(_priceController.text.trim()),
        'color': _colorController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': downloadUrl, 
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context); 

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product Added Successfully!')),
      );

      
      _formKey.currentState!.reset();
      _nameController.clear();
      _priceController.clear();
      _colorController.clear();
      _locationController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedImageFile = null;
        _selectedCategory = null;
      });

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Add Product',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      image: _selectedImageFile != null
                          ? DecorationImage(
                              image: kIsWeb
                                  ? NetworkImage(_selectedImageFile!.path) as ImageProvider
                                  : FileImage(File(_selectedImageFile!.path)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Tap to upload product image',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                
                const Text('Product Title', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('e.g. Leather Jacket'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter product name' : null,
                ),
                const SizedBox(height: 15),

                
                const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _buildInputDecoration('Select Category'),
                  items: categories.map((String cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  },
                  validator: (val) => val == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 15),

                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Price (\$)', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('250'),
                            validator: (val) => val == null || val.isEmpty ? 'Enter price' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _colorController,
                            decoration: _buildInputDecoration('e.g. Black'),
                            validator: (val) => val == null || val.isEmpty ? 'Enter color' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                
                const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _locationController,
                  decoration: _buildInputDecoration('e.g. Warehouse , Pakistan'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter location' : null,
                ),
                const SizedBox(height: 15),

                
                const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _buildInputDecoration('Enter item details...'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 25),

                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
      ),
    );
  }
}