import 'package:app_hibrida/modules/gestionar_productos.dart';
import 'package:app_hibrida/modules/gestionar_ventas.dart';
import 'package:flutter/material.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0; // Índice de la pestaña actual

  // Lista de tus pantallas (puedes reemplazarlas por tus propios widgets)
  static const List<Widget> _pages = <Widget>[
    GestionarVentas(),
    GestionarProductos(),
    Center(child: Text('👤 Perfil', style: TextStyle(fontSize: 25))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cambia el estado al tocar un ícono
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Muestra la página según el índice
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFDBF0DD), // Color de fondo de la barra
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business),
            label: 'Ventas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Productos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF173831), // Color del ícono activo
        onTap: _onItemTapped, // Llama a la función al presionar
      ),
    );
  }
}
