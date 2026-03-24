import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_hibrida/models/sale_model.dart';

class SalesService {
  static const String _baseUrl =
      'https://tiendita-caballerito.onrender.com'; // <-- cambia esto

  // GET todas las ventas
  static Future<List<Sale>> getSales() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/sales'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Sale.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getSales: $e');
    }
    return [];
  }

  // POST crear venta
  static Future<bool> createSale(Sale sale) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sales'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(sale.toJson()),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error createSale: $e');
      return false;
    }
  }

  // PUT actualizar venta
  static Future<bool> updateSale(String id, Sale sale) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/sales/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(sale.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updateSale: $e');
      return false;
    }
  }

  // DELETE eliminar venta
  static Future<bool> deleteSale(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/sales/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleteSale: $e');
      return false;
    }
  }
}
