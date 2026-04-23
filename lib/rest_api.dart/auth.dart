import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Cambia esta URL por la de tu API real
  static const String baseUrl = "https://apinode-h3jg8hop0-srdremurs-projects.vercel.app";

  // ─── USUARIO LOGUEADO EN MEMORIA ───────────────────────────────────────────
  static String? currentUserId;
  static String? currentUserName;
  static String? currentUserEmail;
  static String? currentUserRol;
  static String? currentPassword;

  static Future<bool> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    // DEBUG: Mira qué está respondiendo Vercel exactamente
    print("Status Code: ${response.statusCode}");

    // Si recibimos HTML, no intentamos decodificar como JSON
    if (response.headers['content-type']?.contains('text/html') ?? false) {
      print("ERROR: El servidor respondió con HTML. Probablemente la ruta /login no existe o la API crasheó.");
      return false;
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // MONGODB TIP: Mongo siempre devuelve el ID como '_id'
      currentUserId = data['_id']?.toString() ?? '';
      currentUserName = data['username'] ?? data['nombre'] ?? ''; // Revisa este campo en tu modelo
      currentUserEmail = data['email'] ?? email;
      currentUserRol = data['role'] ?? '';

      return true;
    } else {
      print("Credenciales fallidas: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Excepción atrapada: $e");
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
