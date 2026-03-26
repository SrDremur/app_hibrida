import 'package:flutter/material.dart';

// Colores consistentes con el proyecto
const kGreenDark = Color(0xFF173831);
const kGreenMid = Color(0xFF235347);
const kGreenLight = Color(0xFF8CB79B);
const kGreenBg = Color(0xFFDBF0DD);
const kBlackApp = Color(0xFF051F20);

/// Modelo simple de usuario (reemplaza con tu modelo real cuando tengas la API)
class Usuario {
  final int? idUser;
  final String nombre;
  final String email;
  final String rol; // 'admin' | 'vendedor' | 'cliente'
  final bool activo;

  const Usuario({
    this.idUser,
    required this.nombre,
    required this.email,
    required this.rol,
    this.activo = true,
  });
}

class UsuarioCard extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const UsuarioCard({
    super.key,
    required this.usuario,
    required this.onEditar,
    required this.onEliminar,
  });

  Color _rolColor(String rol) {
    switch (rol.toLowerCase()) {
      case 'admin':
        return const Color(0xFF173831);
      case 'vendedor':
        return const Color(0xFF235347);
      default:
        return const Color(0xFF8CB79B);
    }
  }

  IconData _rolIcon(String rol) {
    switch (rol.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      case 'vendedor':
        return Icons.storefront_outlined;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kGreenBg,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar con inicial
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: kBlackApp.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  usuario.nombre.isNotEmpty
                      ? usuario.nombre[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: kGreenDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info del usuario
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kBlackApp,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 13,
                        color: kGreenMid,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          usuario.email,
                          style: const TextStyle(
                            color: kGreenMid,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Badge de rol
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _rolColor(usuario.rol),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _rolIcon(usuario.rol),
                              size: 11,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              usuario.rol.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Indicador activo/inactivo
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: usuario.activo ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        usuario.activo ? 'Activo' : 'Inactivo',
                        style: TextStyle(
                          fontSize: 11,
                          color: usuario.activo
                              ? Colors.green
                              : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Botones
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: kBlackApp),
                  onPressed: onEditar,
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
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
