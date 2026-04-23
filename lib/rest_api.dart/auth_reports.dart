import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportService {
  static const String _mongoUrl = "https://apinode-h3jg8hop0-srdremurs-projects.vercel.app";
  static const String _postgresUrl = "https://api-python-app.onrender.com";

  static Future<List<dynamic>> fetchVentas() async {
    try {
      final response = await http.get(Uri.parse('$_mongoUrl/Sale'));
      if (response.statusCode == 200) return jsonDecode(response.body);
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
