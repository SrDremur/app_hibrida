import 'dart:convert';
import 'package:http/http.dart' as http;

class Producto {
  final int? idProduct;
  final String product;
  final int stock;
  final double price;
  final String? description;
  final String? image;
  final int? id_Category;
  final String? date_exp;

  Producto({
    this.idProduct,
    required this.product,
    required this.stock,
    required this.price,
    this.description,
    this.image,
    this.id_Category,
    this.date_exp,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProduct: json['id_product'],
      product: json['product'] ?? '',
      stock: json['stock'] ?? 0,
      price: double.parse(json['price'].toString()),
      description: json['description'],
      image: json['image'],
      id_Category: json['id_category'],
      date_exp: json['date_exp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'stock': stock,
      'price': price,
      'description': description,
      'image': image,
      'id_category': id_Category,
      'date_exp': date_exp,
    };
  }
}

class Categoria {
  final int? id_Category;
  final String category;

  Categoria({this.id_Category, required this.category});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id_Category: json['id_category'],
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'category': category};
  }
}

class AuthProducts {
  static const String baseUrl = "https://api-python-app.onrender.com";

  // GET /products
  static Future<List<Producto>> getProductos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Producto.fromJson(item)).toList();
      }
      throw Exception('Error al obtener productos: ${response.statusCode}');
    } catch (e) {
      print('Error de conexión: $e');
      rethrow;
    }
  }

  static Future<Producto?> idProductGet(int idPro) async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/products/$idPro'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return Producto.fromJson(jsonData);
      }else{
        print('Error: ${response.statusCode}');
        return null;
      }
    }catch (e) {
      print('Error: $e');
    }
  }

  // POST /products
  static Future<Producto> crearProducto(Producto producto) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(producto.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Producto.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error al crear producto: ${response.statusCode}');
    } catch (e) {
      print('Error de conexión: $e');
      rethrow;
    }
  }

  // PUT /products/:id
  static Future<Producto> editarProducto(int id, Producto producto) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(producto.toJson()),
      );
      if (response.statusCode == 200) {
        return Producto.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 422) {
        // Esto te dirá exactamente qué campo falta o está mal escrito
        print("Error detallado del servidor: ${response.body}");
      }
      throw Exception('Error al editar producto: ${response.statusCode}');
    } catch (e) {
      print('Error de conexión: $e');
      rethrow;
    }
  }

  // DELETE /products/:id
  static Future<void> eliminarProducto(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar producto: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
      rethrow;
    }
  }

  //GET /categories
  static Future<List<Categoria>> getCategorias() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Categoria.fromJson(item)).toList();
      }
      throw Exception('Error al obtener categorías: ${response.statusCode}');
    } catch (e) {
      print('Error de conexión: $e');
      rethrow;
    }
  }

  static Future<Categoria> crearCategoria(Categoria categoria) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(categoria.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Categoria.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error al crear categoría: ${response.statusCode}');
    } catch (e) {
      print('Error de conexión: $e');
      rethrow;
    }
  }
}
