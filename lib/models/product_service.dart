import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product_model.dart';

class ProductService {
  final String baseUrl = 'https://backend-ecomm-jol4.onrender.com'; // ✅ Use live backend

  Future<List<ProductModel>> fetchProducts() async {
    final url = Uri.parse('$baseUrl/api/products');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ProductModel.fromMap(json)).toList();
    } else {
      throw Exception('❌ Failed to load products: ${response.statusCode}');
    }
  }
}
