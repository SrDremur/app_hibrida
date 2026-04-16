import 'package:flutter/material.dart';
import 'package:app_hibrida/modules/gestionar_ventas.dart';
import 'package:app_hibrida/modules/gestionar_productos.dart';
import 'package:app_hibrida/modules/gestionar_usuarios.dart'; // ← Tu módulo de usuarios
import 'package:app_hibrida/modules/consultar_reportes.dart';

class MainNavigation extends StatefulWidget {
  final String rol; // Recibimos el rol desde el login

  const MainNavigation({super.key, required this.rol});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _menuOptions = [];

  @override
  void initState() {
    super.initState();
    _configurarMenu();
  }

  void _configurarMenu() {
    // Definimos todas las secciones y sus permisos
    final todasLasOpciones = [
      {
        'pagina': const GestionarVentas(),
        'icono': Icons.add_business,
        'etiqueta': 'Ventas',
        'permisos': ['admin', 'vendedor'],
      },
      {
        'pagina': const GestionarProductos(),
        'icono': Icons.shopping_cart,
        'etiqueta': 'Productos',
        'permisos': ['admin', 'vendedor'],
      },
      {
        'pagina': const GestionarUsuarios(),
        'icono': Icons.people_alt,
        'etiqueta': 'Usuarios',
        'permisos': ['admin'],
      },
      {
        'pagina': const ConsultarReportes(),
        'icono': Icons.description,
        'etiqueta': 'Reportes',
        'permisos': ['admin', 'consultor'],
      },
    ];

    // Filtramos según el rol que llegó al constructor
    setState(() {
      _menuOptions = todasLasOpciones
          .where((opcion) => (opcion['permisos'] as List).contains(widget.rol.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_menuOptions.isEmpty) {
      return const Scaffold(body: Center(child: Text("Sin acceso")));
    }

    return Scaffold(
      body: _menuOptions[_selectedIndex]['pagina'],
      bottomNavigationBar: _menuOptions.length >= 2 
    ? BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFDBF0DD),
        selectedItemColor: const Color(0xFF173831),
        unselectedItemColor: Colors.grey[600],
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: _menuOptions.map((opt) {
          return BottomNavigationBarItem(
            icon: Icon(opt['icono'] as IconData),
            label: opt['etiqueta'] as String,
          );
        }).toList(),
      ) : null,
    );
  }
}