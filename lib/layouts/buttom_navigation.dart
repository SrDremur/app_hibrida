import 'package:app_hibrida/modules/gestionar_productos.dart';
import 'package:app_hibrida/modules/gestionar_ventas.dart';
import 'package:app_hibrida/modules/gestionar_usuarios.dart';
import 'package:flutter/material.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    GestionarVentas(),
    GestionarProductos(),
    GestionarUsuarios(), // ← nueva pestaña
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
        backgroundColor: const Color(0xFFDBF0DD),
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
            icon: Icon(Icons.manage_accounts_outlined),
            label: 'Usuarios', // ← antes era "Perfil"
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF173831),
        onTap: _onItemTapped,
      ),
    );
  }
}
