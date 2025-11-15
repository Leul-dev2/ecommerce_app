import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _phone = TextEditingController();

  bool _isDefault = false;
  bool _isEditing = false;
  Map<String, dynamic>? _selectedCountry;
  DocumentSnapshot? editingAddress;

  final List<Map<String, dynamic>> countries = [
    {'name': 'Ethiopia', 'code': '+251', 'iso': 'ET'},
    {'name': 'USA', 'code': '+1', 'iso': 'US'},
    {'name': 'India', 'code': '+91', 'iso': 'IN'},
    {'name': 'UK', 'code': '+44', 'iso': 'GB'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCountry = countries[0];
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _street.dispose();
    _city.dispose();
    _state.dispose();
    _phone.dispose();
    super.dispose();
  }

  String flagFromCountryCode(String countryCode) {
    return countryCode.toUpperCase().replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) =>
          String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
    );
  }

  void clearForm() {
    _firstName.clear();
    _lastName.clear();
    _street.clear();
    _city.clear();
    _state.clear();
    _phone.clear();
    _isDefault = false;
    _selectedCountry = countries[0];
    editingAddress = null;
    _isEditing = false;
  }

  void populateForm(DocumentSnapshot data) {
    _firstName.text = data['firstName'] ?? '';
    _lastName.text = data['lastName'] ?? '';
    _street.text = data['street'] ?? '';
    _city.text = data['city'] ?? '';
    _state.text = data['state'] ?? '';
    _isDefault = data['isDefault'] ?? false;
    _selectedCountry = countries.firstWhere(
      (c) => c['name'] == data['country'],
      orElse: () => countries[0],
    );
    final phone = data['phone'] ?? '';
    final phoneWithoutPrefix = phone.toString().replaceFirst(RegExp(r'^\+\d+\s*'), '');
    _phone.text = phoneWithoutPrefix;

    editingAddress = data;
    _isEditing = true;
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    final address = {
      'firstName': _firstName.text,
      'lastName': _lastName.text,
      'street': _street.text,
      'city': _city.text,
      'state': _state.text,
      'phone': '${_selectedCountry?['code']} ${_phone.text}',
      'country': _selectedCountry?['name'],
      'isDefault': _isDefault,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final ref = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('addresses');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      if (_isDefault) {
        final snapshot = await ref.where('isDefault', isEqualTo: true).get();
        for (var doc in snapshot.docs) {
          transaction.update(doc.reference, {'isDefault': false});
        }
      }

      if (_isEditing && editingAddress != null) {
        transaction.update(editingAddress!.reference, address);
      } else {
        final newDoc = ref.doc();
        transaction.set(newDoc, address);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? "Address updated!" : "Address saved!")),
    );

    clearForm();
    setState(() {});
  }

  Future<void> delete(DocumentSnapshot doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Address"),
        content: const Text("Are you sure you want to delete this address?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await doc.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address deleted.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('addresses');

    return Scaffold(
      appBar: AppBar(title: const Text("Your Addresses")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstName,
                          decoration: const InputDecoration(labelText: "First Name"),
                          validator: (value) => value!.isEmpty ? "Required" : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lastName,
                          decoration: const InputDecoration(labelText: "Last Name"),
                          validator: (value) => value!.isEmpty ? "Required" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _street,
                    decoration: const InputDecoration(labelText: "Street Address"),
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _city,
                          decoration: const InputDecoration(labelText: "City"),
                          validator: (value) => value!.isEmpty ? "Required" : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _state,
                          decoration: const InputDecoration(labelText: "State"),
                          validator: (value) => value!.isEmpty ? "Required" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      DropdownButton<Map<String, dynamic>>(
                        value: _selectedCountry,
                        items: countries.map((country) {
                          final flag = flagFromCountryCode(country['iso']);
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: country,
                            child: Text('$flag ${country['name']} (${country['code']})'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedCountry = value),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: "Phone Number"),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Required";
                            if (!RegExp(r'^[0-9]{7,15}$').hasMatch(value)) return "Invalid number";
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _isDefault,
                    onChanged: (value) => setState(() => _isDefault = value!),
                    title: const Text("Set as default address"),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: save,
                    icon: Icon(_isEditing ? Icons.save_as : Icons.save),
                    label: Text(_isEditing ? "Update Address" : "Save Address"),
                  ),
                  const Divider(height: 32),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: ref.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Column(
                    children: const [
                      Icon(Icons.location_off, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("No addresses added."),
                    ],
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text('${data['firstName']} ${data['lastName']}'),
                        subtitle: Text('${data['street']}, ${data['city']}, ${data['state']}\n${data['phone']} (${data['country']})'),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            if (data['isDefault'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text("Default", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                populateForm(doc);
                                setState(() {});
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => delete(doc),
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
    );
  }
}
