import 'package:flutter/material.dart';
import 'package:app_hibrida/modules/gestionar_ventas.dart';
import 'package:app_hibrida/modules/gestionar_productos.dart';
import 'package:app_hibrida/modules/gestionar_usuarios.dart'; // ← Tu módulo de usuarios
import 'package:app_hibrida/modules/consultar_reportes.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const GestionarVentas(),
    const GestionarProductos(),
    const GestionarUsuarios(), // ← Reintegrado aquí
    const ConsultarReportes(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Necesario para 4 iconos
        backgroundColor: const Color(0xFFDBF0DD),
        selectedItemColor: const Color(0xFF173831),
        unselectedItemColor: Colors.grey[600],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business),
            label: 'Ventas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Usuarios',
          ), // ← Nuevo icono
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Reportes',
          ),
        ],
      ),
    );
  }
}
