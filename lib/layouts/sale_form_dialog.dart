import 'package:app_hibrida/layouts/box_input.dart';
import 'package:app_hibrida/rest_api.dart/auth.dart';
import 'package:flutter/material.dart';
import 'package:app_hibrida/models/sale_model.dart';
import 'package:app_hibrida/rest_api.dart/auth_products.dart';

const kPink = Color(0xFFE37EAF);
const kBlack = Color(0xFF060304);
const kWhite = Color(0xFFFFFFFF);
const kPinkLight = Color(0xFF8CB79B);
const kPinkDark = Color(0xFF173831);

class SaleFormDialog extends StatefulWidget {
  final Sale? existingSale;
  const SaleFormDialog({super.key, this.existingSale});

  @override
  State<SaleFormDialog> createState() => _SaleFormDialogState();
}

class _SaleFormDialogState extends State<SaleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _totalController = TextEditingController();

  final user = AuthService.currentUserId;
  final name = AuthService.currentUserName;
  List<Producto> _productos = [];

 List<Map<String, TextEditingController>> _productControllers = [];

  bool get _isEditing => widget.existingSale != null;

  @override
  void initState() {
    _cargarProductos();
    super.initState();
    if (_isEditing) {
      _userController.text = widget.existingSale!.idUser;
      _totalController.text = widget.existingSale!.totalPrice.toString();
      for (final p in widget.existingSale!.products) {
        _addProductRow(
          idProduct: p.idProduct,
          quantity: p.quantity.toString(),
          price: p.price.toString(),
        );
      }
    } else {
      _addProductRow();
    }
  }

  void _addProductRow({
    String idProduct = '',
    String quantity = '',
    String price = '',
  }) {
    setState(() {
      _productControllers.add({
        'id': TextEditingController(text: idProduct),
        'qty': TextEditingController(text: quantity),
        'price': TextEditingController(text: price),
        'subtotal': TextEditingController(text: '0.00'),
      });
    });
  }

  void _removeProductRow(int index) =>
      setState(() => _productControllers.removeAt(index));

  @override
  void dispose() {
    _userController.dispose();
    _totalController.dispose();
    for (final row in _productControllers) {
      row.values.forEach((c) => c.dispose());
    }
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    try{
      final lista = await AuthProducts.getProductos();
      if(!mounted) return;
      setState(() => _productos = lista);
    }catch (e) {
      print('error al cargar productos: $e');
    }
  }

  Future<void> _Subtotal(int index) async {
    final row = _productControllers[index];
    final idString = row['id']?.text ?? ''; 
    final qtyString = row['qty']?.text ?? '';

    if (idString.isNotEmpty && qtyString.isNotEmpty) {
      int? id = int.tryParse(idString);
      int cant = int.tryParse(qtyString) ?? 0;

      if (id != null) {
      // 1. Aquí llamas a tu API de Render
        final producto = await AuthProducts.idProductGet(id);
      
        if (!mounted) return; // Seguridad por si cierran el diálogo

        if (producto != null) {
          setState(() {
          // 2. Calculamos el subtotal real
            double sub = producto.price * cant;
            row['subtotal']!.text = sub.toStringAsFixed(2);
            row['price']!.text = producto.price.toString();
          
          // 3. Actualizamos el total de abajo automáticamente
            _calcularTotalGeneral(); 
          });
        }
      }
    }
  }
  void _calcularTotalGeneral() {
  double total = 0.0;
  for (var row in _productControllers) {
    total += double.tryParse(row['subtotal']!.text) ?? 0.0;
  }
  _totalController.text = total.toStringAsFixed(2);
}

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: kPinkDark, fontSize: 13),
    filled: true,
    fillColor: kPinkLight.withOpacity(0.2),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kPinkLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kPinkLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kPink, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final products = _productControllers
          .map(
            (row) => SaleProduct(
              idProduct: row['id']!.text.trim(),
              quantity: int.tryParse(row['qty']!.text.trim()) ?? 0,
              price: double.tryParse(row['price']!.text.trim()) ?? 0.0,
              subtotal: double.tryParse(row['subtotal']!.text.trim()) ?? 0.0,
            ),
          )
          .toList();

      final sale = Sale(
        id: widget.existingSale?.id,
        idUser: AuthService.currentUserId ?? '',
        products: products,
        totalPrice: double.tryParse(_totalController.text.trim()) ?? 0.0,
        saleDate: DateTime.now(),
      );
      print("Objeto Sale en JSON: ${sale.toJson()}");
      Navigator.pop(context, sale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: kPink,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isEditing ? Icons.edit : Icons.add_shopping_cart,
                      color: kBlack,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isEditing ? 'Editar Venta' : 'Nueva Venta',
                    style: const TextStyle(
                      color: kBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              //Usuario
              Text(
                'Vendedor: $name',
                style: TextStyle(
                  color: kBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              // Productos
              const Text(
                'Productos',
                style: TextStyle(
                  color: kBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              ..._productControllers.asMap().entries.map((entry) {
                final i = entry.key;
                final row = entry.value;
                final int? currentId = int.tryParse(row['id']!.text);
                return Container(
                  key: UniqueKey(),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: kPinkLight),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Producto ${i + 1}',
                            style: const TextStyle(
                              color: kPinkDark,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_productControllers.length > 1)
                            GestureDetector(
                              onTap: () => _removeProductRow(i),
                              child: const Icon(
                                Icons.close,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      DropdownButtonFormField<int>(
                        value: _productos.any((p) => p.idProduct == currentId) ? currentId : null,
                        hint: const Text(
                          'Producto',
                          style: TextStyle(color: Colors.black),
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
                        items: _productos.map((p) => DropdownMenuItem<int>(
                            value: p.idProduct,
                            child: Text(p.product),
                          )).toList(),

                        onChanged:  (int? nuevoId) {
                          setState(() {
                            row['id']!.text = nuevoId.toString();
                          });
                          _Subtotal(i);
                        },
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: 
                            BoxInput(
                              labelText: 'Cantidad',
                              controller: row['qty'],
                              keyboardType: TextInputType.number,
                              onChanged:(v) {
                                _Subtotal(i);
                              },
                              validator: (v){
                                if(v!.isEmpty) return 'Agregue una cantidad';
                                if(int.tryParse(v) == null) return 'Solo permite numeros';
                                return null;
                              },
                              )
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: 
                            Text('Subtotal: ${row['subtotal']!.text}')
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              TextButton.icon(
                onPressed: () => _addProductRow(),
                icon: const Icon(Icons.add_circle_outline, color: kPink),
                label: const Text(
                  'Agregar producto',
                  style: TextStyle(color: kPink, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              // Total
              TextFormField(
                controller: _totalController,
                decoration: _inputDecoration('Total de la Venta'),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: kBlack, fontSize: 14),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kPink),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: kPinkDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _submit,
                      child: Text(
                        _isEditing ? 'GUARDAR' : 'CREAR',
                        style: const TextStyle(
                          color: kPink,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
