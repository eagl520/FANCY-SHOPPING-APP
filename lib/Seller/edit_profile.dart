import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http; 

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _shopController = TextEditingController();

  Uint8List? _imageBytes;
  String? _existingProfileImageUrl; 
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = true;
  bool _isSaving = false; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  
  Future<void> _loadUserData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        _emailController.text = currentUser.email ?? '';

        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _fullNameController.text = data['fullName'] ?? currentUser.displayName ?? '';
            _addressController.text = data['address'] ?? '';
            _phoneController.text = data['phone'] ?? currentUser.phoneNumber ?? '';
            _existingProfileImageUrl = data['profileImage'] ?? ''; 
            _shopController.text = data['ShopName'] ?? '';
          });
        } else {
          setState(() {
            _fullNameController.text = currentUser.displayName ?? '';
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
        print("Image picked successfully");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  
  Future<String?> _uploadImageToImgBB(Uint8List imageBytes) async {
    try {
      const String apiKey = "436525ef80528643fb27c8de8d1ebce2"; 
     final uri = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");

      var request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'profile_image.jpg',
        ));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResult = json.decode(responseData);
        
        return jsonResult['data']['url'];
      } else {
        print("Failed to upload image to ImgBB. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading to ImgBB: $e");
      return null;
    }
  }

  
  Future<void> _saveProfileChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      String imageUrl = _existingProfileImageUrl ?? '';

      
      if (_imageBytes != null) {
        String? uploadedUrl = await _uploadImageToImgBB(_imageBytes!);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(), 
        'address': _addressController.text.trim(),
        'ShopName': _shopController.text.trim(),
        'phone': _phoneController.text.trim(),
        'profileImage': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); 

      
      await currentUser.updateDisplayName(_fullNameController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Color(0xFF005B5C)),
      );

      Navigator.pop(context); 
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _shopController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Center(
                      child: GestureDetector(
                        onTap: _pickImageFromGallery,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: _imageBytes != null
                                  ? MemoryImage(_imageBytes!) as ImageProvider
                                  : (_existingProfileImageUrl != null && _existingProfileImageUrl!.isNotEmpty
                                      ? NetworkImage(_existingProfileImageUrl!) as ImageProvider
                                      : const NetworkImage(
                                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',

                                        )),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 28,
                                width: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    
                    _buildInputField(
                      label: 'Full Name',
                      controller: _fullNameController,
                    ),
                     const SizedBox(height: 16),

                    
                    _buildInputField(
                      label: 'Shop Name',
                      
                      controller: _shopController,
                      prefixIcon: Icons.mail_outline,
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),

                    
                    _buildInputField(
                      label: 'E-mail',
                      readOnly: true,
                      controller: _emailController,
                      prefixIcon: Icons.mail_outline,
                    ),
                    const SizedBox(height: 16),

                    
                    _buildInputField(
                      label: 'Address',
                      controller: _addressController,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),

                    
                    _buildInputField(
                      label: 'Phone',
                      controller: _phoneController,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 30),

                    
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _isSaving ? null : _saveProfileChanges,
                        child: _isSaving
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    IconData? prefixIcon,
    bool readOnly = false, 
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly, 
          style: TextStyle(
            color: readOnly ? Colors.grey.shade600 : Colors.black87, 
          ),
          decoration: InputDecoration(
            filled: readOnly, 
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white, 
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey, size: 20) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(
                color: readOnly ? Colors.grey.shade300 : const Color(0xFF005B5C), 
                width: readOnly ? 1 : 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}