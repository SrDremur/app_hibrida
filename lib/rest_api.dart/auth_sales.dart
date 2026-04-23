import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_hibrida/models/sale_model.dart';

class SalesService {
  static const String _baseUrl =
      'https://apinode-h3jg8hop0-srdremurs-projects.vercel.app'; // <-- cambia esto

  // GET todas las ventas
  static Future<List<Sale>> getSales() async {
  try {
    final response = await http.get(Uri.parse('$_baseUrl/Sale'));

    print("Respuesta de la API: ${response.statusCode}");
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Sale.fromJson(json)).toList();
    } else {
      // Si no es 200, queremos saber por qué
      print("Error en el servidor: ${response.body}");
      return [];
    }
  } catch (e) {
    // Aquí es donde te salía el error del 'int' vs 'String'
    print('Error crítico en getSales: $e');
    return [];
  }
}

  // POST crear venta
  static Future<bool> createSale(Sale sale) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Sale'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(sale.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("¡Venta guardada!");
      } else {
  // ESTO ES LO QUE NECESITAMOS VER:
        print("CÓDIGO DE ERROR: ${response.statusCode}");
        print("DETALLE DEL ERROR: ${response.body}"); 
      }
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
        Uri.parse('$_baseUrl/Sale/$id'),
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
      final response = await http.delete(Uri.parse('$_baseUrl/Sale/$id'));
      return response.statusCode == 404;
    } catch (e) {
      print('Error deleteSale: $e');
      return false;
    }
  }
}
