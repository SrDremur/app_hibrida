import 'package:flutter/material.dart';
import 'package:app_hibrida/layouts/user_card.dart';

// ─── Colores del proyecto ────────────────────────────────────────────────────
const _kGreenDark = Color(0xFF173831);
const _kGreenMid = Color(0xFF235347);
const _kGreenLight = Color(0xFF8CB79B);
const _kGreenBg = Color(0xFFDBF0DD);
const _kBlackApp = Color(0xFF051F20);

/// Muestra el bottom sheet para crear o editar un usuario.
/// Llámalo con:
///   await mostrarFormularioUsuario(context);               // nuevo
///   await mostrarFormularioUsuario(context, usuario: u);   // editar
Future<Usuario?> mostrarFormularioUsuario(
  BuildContext context, {
  Usuario? usuario,
}) {
  return showModalBottomSheet<Usuario>(
    context: context,
    backgroundColor: _kGreenBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _UserFormContent(usuarioExistente: usuario),
  );
}

// ─── Widget interno del formulario ──────────────────────────────────────────
class _UserFormContent extends StatefulWidget {
  final Usuario? usuarioExistente;
  const _UserFormContent({this.usuarioExistente});

  @override
  State<_UserFormContent> createState() => _UserFormContentState();
}

class _UserFormContentState extends State<_UserFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String _rolSeleccionado = 'cliente';
  bool _activo = true;
  bool _verPass = false;

  final List<String> _roles = ['admin', 'vendedor', 'consultor'];

  bool get _esEdicion => widget.usuarioExistente != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final u = widget.usuarioExistente!;
      _nombreCtrl.text = u.nombre;
      _emailCtrl.text = u.email;
      _rolSeleccionado = u.rol;
      _activo = u.activo;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final resultado = Usuario(
      idUser: widget.usuarioExistente?.idUser,
      nombre: _nombreCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      rol: _rolSeleccionado,
      activo: _activo,
    );

    Navigator.pop(context, resultado);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Título ──────────────────────────────────────────────────────
            Row(
              children: [
                Icon(
                  _esEdicion
                      ? Icons.edit_outlined
                      : Icons.person_add_alt_1_outlined,
                  color: _kGreenDark,
                ),
                const SizedBox(width: 10),
                Text(
                  _esEdicion ? 'Editar Usuario' : 'Nuevo Usuario',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _kBlackApp,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── Nombre ──────────────────────────────────────────────────────
            _Campo(
              controller: _nombreCtrl,
              label: 'Nombre completo',
              icon: Icons.badge_outlined,
              validator: (v) =>
                  v!.trim().isEmpty ? 'El nombre es obligatorio' : null,
            ),
            const SizedBox(height: 12),

            // ── Email ───────────────────────────────────────────────────────
            _Campo(
              controller: _emailCtrl,
              label: 'Correo electrónico',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v!.trim().isEmpty) return 'El correo es obligatorio';
                if (!v.contains('@')) return 'Correo inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ── Contraseña (solo en nuevo usuario) ──────────────────────────
            if (!_esEdicion) ...[
              TextFormField(
                controller: _passCtrl,
                obscureText: !_verPass,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline, color: _kGreenMid),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _verPass ? Icons.visibility_off : Icons.visibility,
                      color: _kGreenMid,
                    ),
                    onPressed: () => setState(() => _verPass = !_verPass),
                  ),
                  filled: true,
                  fillColor: _kGreenLight.withOpacity(0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  labelStyle: const TextStyle(color: _kGreenMid),
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'La contraseña es obligatoria';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 12),
            ],

            // ── Rol ─────────────────────────────────────────────────────────
            DropdownButtonFormField<String>(
              value: _roles.contains(_rolSeleccionado) ? _rolSeleccionado : null,
              dropdownColor: _kGreenDark,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Rol',
                labelStyle: const TextStyle(color: _kGreenMid),
                prefixIcon: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: _kGreenMid,
                ),
                filled: true,
                fillColor: _kGreenLight.withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _roles.map((rol) {
                return DropdownMenuItem(
                  value: rol,
                  child: Text(
                    rol[0].toUpperCase() + rol.substring(1),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _rolSeleccionado = v!),
            ),
            const SizedBox(height: 12),

            // ── Estado activo/inactivo ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: _kGreenLight.withOpacity(0.4),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.toggle_on_outlined,
                    color: _kGreenMid,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Usuario activo',
                    style: TextStyle(color: _kGreenMid, fontSize: 15),
                  ),
                  const Spacer(),
                  Switch(
                    value: _activo,
                    activeColor: _kGreenDark,
                    onChanged: (v) => setState(() => _activo = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── Botón guardar ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlackApp,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _guardar,
                child: Text(
                  _esEdicion ? 'GUARDAR CAMBIOS' : 'CREAR USUARIO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Campo de texto reutilizable ─────────────────────────────────────────────
class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Campo({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _kGreenMid),
        prefixIcon: Icon(icon, color: _kGreenMid),
        filled: true,
        fillColor: _kGreenLight.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
