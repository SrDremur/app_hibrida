import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_hibrida/layouts/user_card.dart';

class AuthUsers {
  static const String _baseUrl = "https://tiendita-caballerito.onrender.com";

  // ─── Mapeo JSON → Usuario ──────────────────────────────────────────────────
  // La API usa: _id, name, email, role, activo
  // El modelo usa: idUser, nombre, email, rol, activo
  static Usuario _fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUser: json['_id']?.toString() ?? json['id']?.toString(),
      nombre: json['name'] ?? json['nombre'] ?? '',
      email: json['email'] ?? '',
      rol: json['role'] ?? json['rol'] ?? 'cliente', // ← "role" en API
      activo: json['activo'] ?? true,
    );
  }

  // ─── Mapeo Usuario → JSON ──────────────────────────────────────────────────
  static Map<String, dynamic> _toJson(Usuario u, {String? password}) {
    final map = <String, dynamic>{
      'name': u.nombre,
      'email': u.email,
      'role': u.rol, // ← "role" en API
      'activo': u.activo,
    };
    if (password != null && password.isNotEmpty) {
      map['password'] = password;
    }
    return map;
  }

  // ─── Helper: evita crash si el servidor devuelve HTML en vez de JSON ───────
  static dynamic _parseBody(http.Response res) {
    final ct = res.headers['content-type'] ?? '';
    if (!ct.contains('application/json')) {
      throw Exception(
        'El servidor respondió ${res.statusCode} sin JSON. '
        'Verifica que el endpoint exista.',
      );
    }
    return jsonDecode(res.body);
  }

  // ─── GET /User ─────────────────────────────────────────────────────────────
  static Future<List<Usuario>> getUsuarios() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/User'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = _parseBody(response);
      final List<dynamic> lista = data is List ? data : data['users'] ?? [];
      return lista.map((j) => _fromJson(j as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Error al obtener usuarios (${response.statusCode})');
    }
  }

  // ─── POST /User ────────────────────────────────────────────────────────────
  static Future<Usuario> crearUsuario(
    Usuario usuario, {
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/User'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(_toJson(usuario, password: password)),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = _parseBody(response);
      return data is Map<String, dynamic> ? _fromJson(data) : usuario;
    } else {
      final data = _parseBody(response);
      throw Exception(
        data['mensaje'] ?? data['message'] ?? 'Error al crear usuario',
      );
    }
  }

  // ─── PUT /User/:id ─────────────────────────────────────────────────────────
  static Future<Usuario> editarUsuario(dynamic id, Usuario usuario) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/User/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(_toJson(usuario)),
    );

    if (response.statusCode == 200) {
      final data = _parseBody(response);
      return data is Map<String, dynamic> ? _fromJson(data) : usuario;
    } else {
      final data = _parseBody(response);
      throw Exception(
        data['mensaje'] ?? data['message'] ?? 'Error al editar usuario',
      );
    }
  }

  // ─── DELETE /User/:id ──────────────────────────────────────────────────────
  static Future<void> eliminarUsuario(dynamic id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/User/$id'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      final data = _parseBody(response);
      throw Exception(
        data['mensaje'] ?? data['message'] ?? 'Error al eliminar usuario',
      );
    }
  }
}
