import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportService {
<<<<<<< HEAD
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
=======
  static const String _mongoUrl = "https://tiendita-caballerito.onrender.com";
  static const String _postgresUrl = "https://api-python-app.onrender.com";

  static Future<List<dynamic>> fetchVentas() async {
    try {
      final response = await http.get(Uri.parse('$_mongoUrl/Sale'));
      if (response.statusCode == 200) return jsonDecode(response.body);
>>>>>>> 75d84cb10f361b1d070af9c5556d1abe1ccb3921
      return [];
    } catch (e) {
      print('Error en fetchVentas: $e');
      return [];
    }
  }

  // NUEVA FUNCIÓN: Formatea los datos para que el PDF los entienda
  static Future<List<Map<String, dynamic>>> getVentasParaReporte() async {
    List<dynamic> ventasRaw = await fetchVentas();

    return ventasRaw.map((v) {
      return {
        // Ajustamos los nombres de los campos de MongoDB a los que usa tu tabla
        'fecha': v['sale_date']?.toString().split('T')[0] ?? 'Sin fecha',
        'usuario': v['id_user'] ?? 'Desconocido',
        'total': v['total_price']?.toDouble() ?? 0.0,
      };
    }).toList();
  }

  static Future<List<dynamic>> fetchProductos() async {
    try {
      final response = await http.get(Uri.parse('$_postgresUrl/products'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      print('Error en fetchProductos: $e');
      return [];
    }
  }
}
