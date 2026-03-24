import 'package:flutter/material.dart';
import 'package:app_hibrida/models/sale_model.dart';

const kPink = Color(0xFFE37EAF);
const kBlack = Color(0xFF060304);
const kWhite = Color(0xFFFFFFFF);
const kPinkLight = Color(0xFFF2B8D5);
const kPinkDark = Color(0xFFB8527E);

class SaleCard extends StatelessWidget {
  final Sale sale;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SaleCard({
    super.key,
    required this.sale,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPinkLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kPink.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: kPink,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt, color: kBlack, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Venta #${sale.id ?? "—"}',
                    style: const TextStyle(
                      color: kBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: kBlack.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      color: kPinkDark,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Usuario: ${sale.idUser}',
                      style: const TextStyle(
                        color: kBlack,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: kPinkDark,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${sale.products.length} producto(s)',
                      style: const TextStyle(color: kBlack, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: kBlack,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '\$${sale.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: kPink,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: kPinkDark),
                      tooltip: 'Editar',
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Eliminar',
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
