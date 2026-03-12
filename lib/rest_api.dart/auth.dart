import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Cambia esta URL por la de tu API real
  static const String baseUrl = "https://tiendita-caballerito.onrender.com";

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
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final String mensajeServidor =
            errorData['mensaje'] ?? "Error desconocido";

        print("Mensaje del servidor: $mensajeServidor");
        return false;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }

  static Future<bool> register(
    String name,
    String email,
    String password,
    String rol,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/User'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "rol": rol,
        }),
      );

      if (response.statusCode == 201) {
        // Registro exitoso
        return true;
      } else {
        // Error en el registro
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final String mensajeServidor =
            errorData['mensaje'] ?? "Error desconocido";

        print("Mensaje del servidor: $mensajeServidor");
        return false;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }
}
