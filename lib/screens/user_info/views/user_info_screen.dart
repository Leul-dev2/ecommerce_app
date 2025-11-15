import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/screens/user_info/views/Edit_Profile_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  User? _user;
  String? _profileImageUrl;
  bool _loading = true;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _loading = true);
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      setState(() {
        _user = null;
        _loading = false;
      });
      return;
    }

    final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

    setState(() {
      _user = currentUser;
      _profileImageUrl = userDoc.data()?['profileImageUrl'] ?? currentUser.photoURL;
      _loading = false;
    });
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile == null) return;

      setState(() => _uploadingImage = true);

      final file = File(pickedFile.path);
      final ref = _storage.ref().child('profile_images').child('${_user!.uid}.jpg');
      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();

      await _user!.updatePhotoURL(downloadUrl);
      await _firestore.collection('users').doc(_user!.uid).set({
        'profileImageUrl': downloadUrl,
      }, SetOptions(merge: true));

      await _user!.reload();
      _user = _auth.currentUser;

      setState(() {
        _profileImageUrl = downloadUrl;
        _uploadingImage = false;
      });

      if (!mounted) return;
      _showSnackBar('Profile picture updated.');
    } catch (e) {
      setState(() => _uploadingImage = false);
      if (!mounted) return;
      _showSnackBar('Error updating picture: $e');
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    if (_user?.email == null) {
      _showSnackBar('No email found.');
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: _user!.email!);
      _showSnackBar('Password reset email sent.');
    } catch (e) {
      _showSnackBar('Error sending reset: $e');
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildProfileImage() {
    final radius = 48.0;
    final provider = _profileImageUrl != null && _profileImageUrl!.isNotEmpty
        ? NetworkImage(_profileImageUrl!)
        : const AssetImage('assets/avatar.png') as ImageProvider;

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: provider,
          backgroundColor: Colors.grey.shade300,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: InkWell(
            onTap: _uploadingImage ? null : _pickAndUploadImage,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
              ),
              child: _uploadingImage
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt, size: 20, color: Color(0xFF7C5CFC)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openEditProfileScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          initialName: _user!.displayName ?? '',
          initialEmail: _user!.email ?? '',
          initialPhone: _user!.phoneNumber ?? '',
          initialProfileImageUrl: _profileImageUrl,
          onSave: ({
            required String name,
            required String email,
            required String phone,
            File? profileImage,
          }) async {
            // ✅ 1. Update displayName & email in Auth
            await _user!.updateDisplayName(name);
            if (_user!.email != email) {
              await _user!.updateEmail(email);
            }

            String? newProfileImageUrl;

            if (profileImage != null) {
              final ref = _storage.ref().child('profile_images').child('${_user!.uid}.jpg');
              await ref.putFile(profileImage);
              newProfileImageUrl = await ref.getDownloadURL();
              await _user!.updatePhotoURL(newProfileImageUrl);
            }

            // ✅ 2. Update Firestore
            await _firestore.collection('users').doc(_user!.uid).set({
              'displayName': name,
              'email': email,
              'phoneNumber': phone,
              if (newProfileImageUrl != null) 'profileImageUrl': newProfileImageUrl,
            }, SetOptions(merge: true));

            await _user!.reload();
            _user = _auth.currentUser;

            setState(() {
              _profileImageUrl = newProfileImageUrl ?? _profileImageUrl;
            });
          },
        ),
      ),
    );

    await _loadUserProfile(); // refresh
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'No user found.\nPlease login.',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        actions: [
          TextButton(
            onPressed: _openEditProfileScreen,
            child: const Text(
              'Edit',
              style: TextStyle(color: Color(0xFF7C5CFC), fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: ListView(
          children: [
            Row(
              children: [
                _buildProfileImage(),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user!.displayName ?? 'No Name',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _user!.email ?? 'No Email',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                      ),
                      if (_user!.phoneNumber != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _user!.phoneNumber!,
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _ProfileItem(title: 'Name', value: _user!.displayName ?? 'No Name'),
            _ProfileItem(title: 'Email', value: _user!.email ?? 'No Email'),
            _ProfileItem(title: 'Phone Number', value: _user!.phoneNumber ?? 'Not provided'),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Change Password', style: TextStyle(color: Color(0xFF7C5CFC))),
              trailing: const Icon(Icons.lock_outline, color: Color(0xFF7C5CFC)),
              onTap: _sendPasswordResetEmail,
            ),
            const Divider(height: 32),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              trailing: const Icon(Icons.logout, color: Colors.redAccent),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String title;
  final String value;

  const _ProfileItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 17)),
        ],
      ),
    );
  }
}
