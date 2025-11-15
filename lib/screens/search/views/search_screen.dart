import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/product_model.dart';
import '../../product/views/product_details_screen.dart'; // Import your product detail screen

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _allProducts = [];
  List<ProductModel> _searchResults = [];
  bool _isLoading = true;
  String _error = '';
  Timer? _debounce;

  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
    _loadSearchHistory();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> fetchAllProducts() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final res = await http.get(
        Uri.parse('https://backend-ecomm-jol4.onrender.com/api/products'),
      );

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        _allProducts =
            data.map<ProductModel>((json) => ProductModel.fromMap(json)).toList();

        setState(() {
          _isLoading = false;
          _searchResults = [];
        });
      } else {
        setState(() {
          _error = 'Failed to load products';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterProducts();
    });
  }

  void _filterProducts() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final filtered = _allProducts.where((product) {
      return product.title.toLowerCase().contains(query) ||
          product.brandName.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _searchResults = filtered;
    });
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('search_history') ?? [];
    });
  }

  Future<void> _saveSearchHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove existing occurrence to avoid duplicates
    _searchHistory.remove(query);

    // Insert query at the start
    _searchHistory.insert(0, query);

    // Keep only last 3 entries
    if (_searchHistory.length > 3) {
      _searchHistory = _searchHistory.sublist(0, 3);
    }

    await prefs.setStringList('search_history', _searchHistory);

    setState(() {});
  }

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    setState(() {
      _searchHistory.clear();
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;

    _saveSearchHistory(query.trim());
    _filterProducts();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isSearching = _searchController.text.isNotEmpty;
    final showHistory = !isSearching && _searchHistory.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("🔍 Search"),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearchSubmitted,
              decoration: InputDecoration(
                hintText: 'Search for products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _error = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          if (showHistory)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Recent Searches", style: theme.textTheme.titleMedium),
                      TextButton(
                        onPressed: _clearSearchHistory,
                        child: const Text("Clear"),
                      ),
                    ],
                  ),
                  ..._searchHistory.map((query) {
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(query),
                      onTap: () {
                        _searchController.text = query;
                        _filterProducts();
                      },
                    );
                  }).toList(),
                  const Divider(),
                ],
              ),
            ),

          if (_isLoading) const LinearProgressIndicator(),

          Expanded(
            child: _error.isNotEmpty
                ? Center(child: Text(_error))
                : (isSearching ? _searchResults : _allProducts).isEmpty
                    ? Center(
                        child: Text(
                          isSearching ? "No products found" : "No products available",
                          style: theme.textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: isSearching ? _searchResults.length : _allProducts.length,
                        itemBuilder: (context, index) {
                          final product = isSearching ? _searchResults[index] : _allProducts[index];
                          return ProductTile(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailsScreen(product: product),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductTile({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            product.image,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        ),
        title: Text(product.title),
        subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: theme.primaryColor),
      ),
    );
  }
}
