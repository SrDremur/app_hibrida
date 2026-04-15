import 'package:app_hibrida/layouts/box_input.dart';
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
  int? _categoriaSeleccionada;
  List<Categoria> _categorias = [];

  // Controllers para el formulario
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dateExpCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _cargarCategorias();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    _dateExpCtrl.dispose();
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

  Future<void> _cargarCategorias() async {
    try {
      final lista = await AuthProducts.getCategorias();
      setState(() => _categorias = lista);
    } catch (e) {
      print('Error al cargar categorías: $e');
      // Manejar error si es necesario
    }
  }

  void _limpiarForm() {
    _nombreCtrl.clear();
    _precioCtrl.clear();
    _stockCtrl.clear();
    _descCtrl.clear();
    _dateExpCtrl.clear();
    _categoriaSeleccionada = null;
  }

  void _llenarForm(Producto p) {
    _nombreCtrl.text = p.product;
    _precioCtrl.text = p.price.toString();
    _stockCtrl.text = p.stock.toString();
    _descCtrl.text = p.description ?? '';
    _dateExpCtrl.text = p.date_exp ?? '';
    _categoriaSeleccionada = p.id_Category;
  }

  Future <void> _mostrarDialogoNuevaCategoria() async{
    final TextEditingController _nuevaCatController = TextEditingController();
    // Guardamos el context de la pantalla principal antes de entrar al builder
    final mainContext = context; 

    showDialog(
      context: context,
      builder: (dialogContext) { // Renombramos para no confundirlos
        return AlertDialog(
          title: const Text("Nueva Categoría"),
          content: TextField(
            controller: _nuevaCatController,
            decoration: const InputDecoration(hintText: "Ej. Electrónica"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nuevaCatController.text.isNotEmpty) {
                  final nueva = Categoria(
                    category: _nuevaCatController.text.trim(),
                  );
                  
                  await AuthProducts.crearCategoria(nueva);
                  
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext); // Cerramos usando el context del diálogo
                  
                  // Ahora usamos el contexto de la pantalla principal (mainContext)
                  // para recargar y mostrar el SnackBar
                  if (mainContext.mounted) {
                    await _cargarCategorias(); 
                    
                    ScaffoldMessenger.of(mainContext).showSnackBar(
                      const SnackBar(
                        content: Text("Categoría creada"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarFormulario({Producto? productoExistente}) async {
    if (productoExistente != null) {
      _llenarForm(productoExistente);
    } else {
      _limpiarForm();
    }

    final esEdicion = productoExistente != null;

    await showModalBottomSheet(
      backgroundColor: Color(0xFFDBF0DD),
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter updateSheet) {
          return Padding(
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
              const SizedBox(height: 15),
              BoxInput(
                labelText: 'Nombre',
                controller: _nombreCtrl,
                validator: (v) =>
                    v!.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 12),
              BoxInput(
                labelText: 'Precio',
                controller: _precioCtrl,
                validator: (v) {
                  if (v!.isEmpty) return 'El precio es obligatorio';
                  if (double.tryParse(v) == null) return 'Número inválido';
                  return null;
                },
              ),

              const SizedBox(height: 12),
              BoxInput(
                labelText: 'Stock',
                controller: _stockCtrl,
                validator: (v) {
                  if (v!.isEmpty) return 'El stock es obligatorio';
                  if (int.tryParse(v) == null) return 'Número entero inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              BoxInput(
                labelText: 'Descripción (opcional)',
                controller: _descCtrl,
              ),
              const SizedBox(height: 12),
              BoxInput(
                labelText: 'Fecha de expiración (opcional)',
                controller: _dateExpCtrl,
                validator: (v) {
                  if (v!.isEmpty) return null; // No es obligatorio
                  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  if (!regex.hasMatch(v)) return 'Formato debe ser YYYY-MM-DD';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                // <--- Especificamos que el valor es int
                value: _categoriaSeleccionada,
                hint: const Text(
                  'Categoría',
                  style: TextStyle(color: Colors.white),
                ),
                dropdownColor: const Color(0xFF235347),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF8CB79B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                // Mapeamos la lista de categorías
                items: [
                  ..._categorias.map((categoria) {
                    return DropdownMenuItem<int>(
                      // <--- También aquí ponemos int
                      value: categoria
                          .id_Category, // <--- Este debe ser un número entero
                      child: Text(categoria.category), // Lo que el usuario lee
                    );
                  }).toList(),
                  const DropdownMenuItem<int>(
                    value: -1,
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.green),
                        SizedBox(width: 10),
                        Text(
                          "Agregar nueva categoría...",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                onChanged: (int? nuevoId) async{
                  if (nuevoId == -1) {
                    await _mostrarDialogoNuevaCategoria();
                    updateSheet((){});
                  } else {
                    setState(() {
                      updateSheet(() {
                        _categoriaSeleccionada = nuevoId;
                      });
                      setState(() {
                        _categoriaSeleccionada = nuevoId;
                      });
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF051F20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final nuevo = Producto(
                      idProduct: productoExistente?.idProduct,
                      product: _nombreCtrl.text.trim(),
                      price: double.tryParse(_precioCtrl.text) ?? 0.0,
                      id_Category: _categoriaSeleccionada,
                      stock: int.tryParse(_stockCtrl.text) ?? 0,
                      description: _descCtrl.text.trim(),
                      date_exp: _dateExpCtrl.text.trim().isEmpty
                          ? null
                          : _dateExpCtrl.text.trim(),
                    );

                    try {
                      if (esEdicion) {
                        await AuthProducts.editarProducto(
                          productoExistente.idProduct!,
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
      );
      }
    ));
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
/*
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
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8CB79B),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'GESTOR DE PRODUCTOS',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 2,
          ),
        ),
        leading: const Icon(Icons.inventory_2_outlined, color: Colors.white),
        backgroundColor: const Color(0xFF173831),
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
                  const Icon(
                    Icons.wifi_off,
                    size: 60,
                    color: Color(0xFF235347),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF235347)),
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
                    color: Color(0xFF235347),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No hay productos registrados',
                    style: TextStyle(color: Color(0xFF235347), fontSize: 16),
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
        backgroundColor: const Color(0xFF051F20),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Agregar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
