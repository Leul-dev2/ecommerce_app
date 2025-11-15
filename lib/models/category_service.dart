import 'package:http/http.dart' as http;
import 'dart:convert';
import 'category_model.dart';

Future<List<CategoryModel>> fetchCategories() async {
  final res = await http.get(
    Uri.parse('https://backend-ecomm-jol4.onrender.com/api/categories'),
  );

  if (res.statusCode == 200) {
    final decoded = jsonDecode(res.body) as List<dynamic>;
    return decoded.map((json) => CategoryModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load categories');
  }
}
