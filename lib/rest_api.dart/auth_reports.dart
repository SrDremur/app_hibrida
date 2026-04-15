import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportService {
  static const String baseUrl = "https://api-python-app.onrender.com";
  static const String baseUrl2 = "https://tiendita-caballerito.onrender.com";

  static Future<List<dynamic>> fetchProductos() async {
    try {
      // Usamos el endpoint '/products' que ya confirmamos que funciona
      final response = await http.get(Uri.parse('$baseUrl2/Products'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error en fetchProductos: $e');
      return [];
    }
  }

  static Future<List<dynamic>> fetchVentas() async {
    try {
      // Si el endpoint de ventas es /sales, cámbialo aquí
      final response = await http.get(Uri.parse('$baseUrl/Sale'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error en fetchVentas: $e');
      return [];
    }
  }
}
