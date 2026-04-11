// lib/modules/gestionar_ventas.dart

import 'package:app_hibrida/rest_api.dart/auth_products.dart';
import 'package:flutter/material.dart';
import 'package:app_hibrida/models/sale_model.dart';
import 'package:app_hibrida/layouts/sale_card.dart';
import 'package:app_hibrida/layouts/sale_form_dialog.dart';
import 'package:app_hibrida/rest_api.dart/auth_sales.dart';

const kPink = Color(0xFFFFFFFF);
const kBlack = Color(0xFF173831);
const kWhite = Color(0xFFFFFFFF);

class GestionarVentas extends StatefulWidget {
  const GestionarVentas({super.key});

  @override
  State<GestionarVentas> createState() => _GestionarVentasState();
}

class _GestionarVentasState extends State<GestionarVentas> {
  List<Sale> _sales = [];
  List<Producto> _productos = [];
  bool _isLoading = true;
  String? _error;
  int? id_producto_selec;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final sales = await SalesService.getSales();
      if (!mounted) return;
      setState(() => _sales = sales);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openCreate() async {
    final result = await showDialog<Sale>(
      context: context,
      builder: (_) => const SaleFormDialog(),
    );
    if (result != null) {
      final success = await SalesService.createSale(result);
      if (success) {
        _loadSales();
        _showSnack('Venta creada exitosamente', Colors.green);
      } else {
        _showSnack('Error al crear la venta', Colors.redAccent);
      }
    }
  }

  Future<void> _openEdit(int index) async {
    final result = await showDialog<Sale>(
      context: context,
      builder: (_) => SaleFormDialog(existingSale: _sales[index]),
    );
    if (result != null && result.id != null) {
      final success = await SalesService.updateSale(result.id!, result);
      if (success) {
        _loadSales();
        _showSnack('Venta actualizada', Colors.green);
      } else {
        _showSnack('Error al actualizar', Colors.redAccent);
      }
    }
  }

  Future<void> _delete(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Eliminar venta',
          style: TextStyle(
            color: kBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta venta?',
          style: TextStyle(color: kBlack),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFFB8527E)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kBlack,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: kWhite, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && _sales[index].id != null) {
      final success = await SalesService.deleteSale(_sales[index].id!);
      if (success) {
        _loadSales();
        _showSnack('Venta eliminada', Colors.green);
      } else {
        _showSnack('Error al eliminar', Colors.redAccent);
      }
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kBlack,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'GESTOR DE VENTAS',
          style: TextStyle(
            color: kPink,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 18,
          ),
        ),
        leading: const Icon(Icons.point_of_sale, color: kPink),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: kPink),
            onPressed: _loadSales,
          ),
          const SizedBox(height: 12),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF051f20)),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off,
                    size: 60,
                    color: Color(0xFF235347),
                  ),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF235347)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSales,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _sales.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: kPink.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay ventas registradas',
                    style: TextStyle(
                      color: kBlack.withOpacity(0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sales.length,
              itemBuilder: (context, index) => SaleCard(
                sale: _sales[index],
                onEdit: () => _openEdit(index),
                onDelete: () => _delete(index),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPink,
        onPressed: _openCreate,
        icon: const Icon(Icons.add, color: kBlack),
        label: const Text(
          'Nueva Venta',
          style: TextStyle(
            color: kBlack,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
