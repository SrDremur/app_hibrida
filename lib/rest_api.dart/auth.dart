import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Cambia esta URL por la de tu API real
  static const String baseUrl = "https://tiendita-caballerito.onrender.com/";

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        // El servidor dice que el usuario y contraseña coinciden
        return true;
      } else {
        // Credenciales incorrectas o error de servidor
        return false;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }
}
