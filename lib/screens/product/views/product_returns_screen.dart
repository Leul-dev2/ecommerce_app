import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../constants.dart';

class ProductReturnsScreen extends StatefulWidget {
  const ProductReturnsScreen({super.key});

  @override
  State<ProductReturnsScreen> createState() => _ProductReturnsScreenState();
}

class _ProductReturnsScreenState extends State<ProductReturnsScreen> {
  String? title;
  String? description;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchReturnPolicy();
  }

  Future<void> fetchReturnPolicy() async {
    try {
      final response = await http.get(
        Uri.parse('https://backend-ecomm-jol4.onrender.com/api/return-policy'), // Use your backend IP/URL
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          title = data['title'];
          description = data['description'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load policy.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching policy.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : Column(
                    children: [
                      const SizedBox(height: defaultPadding),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(
                              width: 40,
                              child: BackButton(),
                            ),
                            Text(
                              title ?? "Return",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(defaultPadding),
                          child: Text(
                            description ?? "No return policy available.",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    ],
                  ),
      ),
    );
  }
}
