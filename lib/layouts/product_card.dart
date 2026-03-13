import 'package:flutter/material.dart';
import 'package:app_hibrida/rest_api.dart/auth_products.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Icono del producto
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFE37EAF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2,
                color: Color(0xFFE37EAF),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            // Info del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.product,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${producto.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFE37EAF),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (producto.description != null &&
                      producto.description!.isNotEmpty)
                    Text(
                      producto.description!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    'Stock: ${producto.stock}',
                    style: TextStyle(
                      fontSize: 12,
                      color: producto.stock > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            // Botones
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF060304)),
                  onPressed: onEditar,
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: onEliminar,
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
