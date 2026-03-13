import 'package:app_hibrida/layouts/product_card.dart';
import 'package:app_hibrida/rest_api.dart/auth_products.dart';
import 'package:flutter/material.dart';

class GestionarProductos extends StatefulWidget {
  const GestionarProductos({super.key});

  @override
  State<GestionarProductos> createState() => _GestionarProductosState();
}

class _GestionarProductosState extends State<GestionarProductos> {
  List<Producto> _productos = [];
  bool _cargando = true;
  String? _error;

  // Controllers para el formulario
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await AuthProducts.getProductos();
      setState(() => _productos = lista);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _limpiarForm() {
    _nombreCtrl.clear();
    _precioCtrl.clear();
    _stockCtrl.clear();
    _descCtrl.clear();
  }

  void _llenarForm(Producto p) {
    _nombreCtrl.text = p.product;
    _precioCtrl.text = p.price.toString();
    _stockCtrl.text = p.stock.toString();
    _descCtrl.text = p.description ?? '';
  }

  Future<void> _mostrarFormulario({Producto? productoExistente}) async {
    if (productoExistente != null) {
      _llenarForm(productoExistente);
    } else {
      _limpiarForm();
    }

    final esEdicion = productoExistente != null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esEdicion ? 'Editar Producto' : 'Nuevo Producto',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _campo(
                controller: _nombreCtrl,
                label: 'Nombre',
                validator: (v) =>
                    v!.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 12),
              _campo(
                controller: _precioCtrl,
                label: 'Precio',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'El precio es obligatorio';
                  if (double.tryParse(v) == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _campo(
                controller: _stockCtrl,
                label: 'Stock',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'El stock es obligatorio';
                  if (int.tryParse(v) == null) return 'Número entero inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _campo(controller: _descCtrl, label: 'Descripción (opcional)'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE37EAF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final nuevo = Producto(
                      idProduct: productoExistente?.idProduct,
                      product: _nombreCtrl.text.trim(),
                      price: double.parse(_precioCtrl.text),
                      stock: int.parse(_stockCtrl.text),
                      description: _descCtrl.text.trim(),
                    );

                    try {
                      if (esEdicion) {
                        await AuthProducts.editarProducto(
                          productoExistente!.idProduct!,
                          nuevo,
                        );
                      } else {
                        await AuthProducts.crearProducto(nuevo);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      _cargarProductos();
                      _mostrarSnack(
                        esEdicion ? 'Producto actualizado' : 'Producto creado',
                        esError: false,
                      );
                    } catch (e) {
                      _mostrarSnack('Error: $e');
                    }
                  },
                  child: Text(
                    esEdicion ? 'GUARDAR CAMBIOS' : 'AGREGAR',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar producto'),
        content: Text('¿Seguro que deseas eliminar "${producto.product}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await AuthProducts.eliminarProducto(producto.idProduct!);
        _cargarProductos();
        _mostrarSnack('Producto eliminado', esError: false);
      } catch (e) {
        _mostrarSnack('Error: $e');
      }
    }
  }

  void _mostrarSnack(String msg, {bool esError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: esError ? Colors.redAccent : const Color(0xFFE37EAF),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Gestionar Productos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE37EAF),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarProductos,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE37EAF)),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarProductos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _productos.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No hay productos registrados',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarProductos,
              color: const Color(0xFFE37EAF),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _productos.length,
                itemBuilder: (ctx, i) => ProductoCard(
                  producto: _productos[i],
                  onEditar: () =>
                      _mostrarFormulario(productoExistente: _productos[i]),
                  onEliminar: () => _confirmarEliminar(_productos[i]),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color(0xFF060304),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Agregar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
