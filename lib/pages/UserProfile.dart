import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_farmer_hub/login_flow/Registration_page.dart';
import 'package:digital_farmer_hub/models/FarmerModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../helper/localization/language_constants.dart';
import '../models/ExtraModel.dart';

class UserProfile extends StatefulWidget {
  final int signal; // 0--> When new user sign up, 1--> on update details
  final ExtraModel extraModel;
  final FarmerModel farmerModel;

  UserProfile(this.extraModel, this.farmerModel, this.signal);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late int signal; // 0--> When new user sign up, 1--> on update details
  late ExtraModel extraModel;
  late FarmerModel farmerModel;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _villageNameController = TextEditingController();
  final TextEditingController _districtNameController = TextEditingController();

  bool _isEditing = false; // To track if the user is in edit mode

  @override
  void initState() {
    super.initState();
    signal = widget.signal;
    extraModel = widget.extraModel;
    farmerModel = widget.farmerModel;

    _nameController.text = farmerModel.farmerName ?? "";
    _fatherNameController.text = farmerModel.fatherName ?? "";
    _villageNameController.text = farmerModel.villageName ?? "";
    _districtNameController.text = farmerModel.districtName ?? "";
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      // Revert to the original values
      _nameController.text = farmerModel.farmerName ?? "";
      _fatherNameController.text = farmerModel.fatherName ?? "";
      _villageNameController.text = farmerModel.villageName ?? "";
      _districtNameController.text = farmerModel.districtName ?? "";
    });
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Get the file
      File imageFile = File(pickedFile.path);

      // Upload the file to Firebase Storage
      try {
        String fileName = 'profile_images/${farmerModel.uid}.jpg';
        Reference ref = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = ref.putFile(imageFile);

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Update the FarmerModel with the new profile image URL
        setState(() {
          farmerModel.profileImage = downloadUrl;
        });

        // Update the profile image URL in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(farmerModel.uid)
            .update({'profileImage': downloadUrl});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile image updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  void _saveDetails() async {
    farmerModel.farmerName = _nameController.text;
    farmerModel.fatherName = _fatherNameController.text;
    farmerModel.villageName = _villageNameController.text;
    farmerModel.districtName = _districtNameController.text;

    // Update Firestore with the new values
    await FirebaseFirestore.instance
        .collection('users')
        .doc(farmerModel.uid)
        .update(farmerModel.getMap());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Details updated successfully')),
    );

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: farmerModel.profileImage != null
                      ? NetworkImage(farmerModel.profileImage!)
                      : AssetImage('assets/user.png') as ImageProvider,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: InkWell(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '+91-${farmerModel.phone ?? "Unknown"}',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              const SizedBox(width: 12),
              Icon(Icons.lock, size: 16, color: Colors.black),
            ],
          ),
          const SizedBox(height: 12),
          _buildProfileField('Name', _nameController, _isEditing),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 12),
          _buildProfileField('Village', _villageNameController, _isEditing),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 12),
          _buildProfileField('District', _districtNameController, _isEditing),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 12),
          _buildProfileField('Father\'s Name', _fatherNameController, _isEditing),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Center(
            child: _isEditing
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _cancelEdit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.grey,
                  ),
                  child: Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveDetails,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Save'),
                ),
              ],
            )
                : ElevatedButton(
              onPressed: _toggleEditMode,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.green,
              ),
              child: Text('Edit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, bool isEditable) {
    return TextField(
      controller: controller,
      readOnly: !isEditable,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
    );
  }
}