import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

typedef OnProfileSave = Future<void> Function({
  required String name,
  required String email,
  required String phone,
  File? profileImage,
});

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final String? initialProfileImageUrl;
  final OnProfileSave onSave;

  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
    this.initialProfileImageUrl,
    required this.onSave,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  File? _newProfileImageFile;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked == null) return;

      setState(() {
        _newProfileImageFile = File(picked.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await widget.onSave(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        profileImage: _newProfileImageFile,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  Widget _buildProfileImage() {
    final double size = 100;

    ImageProvider? imageProvider;
    if (_newProfileImageFile != null) {
      imageProvider = FileImage(_newProfileImageFile!);
    } else if (widget.initialProfileImageUrl != null && widget.initialProfileImageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(widget.initialProfileImageUrl!);
    } else {
      imageProvider = const AssetImage('assets/avatar.png');
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundImage: imageProvider,
          backgroundColor: Colors.grey.shade300,
        ),
        Positioned(
          bottom: 0,
          right: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _isSaving ? null : _pickImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
              ),
              child: Icon(
                Icons.camera_alt,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
          ),
        )
      ],
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(child: _buildProfileImage()),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Full Name'),
                textInputAction: TextInputAction.next,
                enabled: !_isSaving,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter your full name';
                  if (v.trim().length < 3) return 'Name must be at least 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('Email Address'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !_isSaving,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter your email';
                  final emailRegEx = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegEx.hasMatch(v.trim())) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration('Phone Number'),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                enabled: !_isSaving,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter your phone number';
                  final phoneRegEx = RegExp(r'^\+?\d{7,15}$');
                  if (!phoneRegEx.hasMatch(v.trim())) return 'Enter a valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Cancel', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('Save', style: TextStyle(fontSize: 16)),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
