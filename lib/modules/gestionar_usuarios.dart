import 'package:flutter/material.dart';
import 'package:app_hibrida/layouts/user_card.dart';
import 'package:app_hibrida/layouts/user_form_dialog.dart';
import 'package:app_hibrida/rest_api.dart/auth_users.dart';

class GestionarUsuarios extends StatefulWidget {
  const GestionarUsuarios({super.key});

  @override
  State<GestionarUsuarios> createState() => _GestionarUsuariosState();
}

class _GestionarUsuariosState extends State<GestionarUsuarios> {
  // ─── Estado ────────────────────────────────────────────────────────────────
  List<Usuario> _usuarios = [];
  List<Usuario> _usuariosFiltrados = [];
  bool _cargando = true;
  String? _error;
  String _busqueda = '';
  String _filtroRol = 'todos';

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
    _searchCtrl.addListener(_aplicarFiltros);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Carga de usuarios desde la API ───────────────────────────────────────
  Future<void> _cargarUsuarios() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await AuthUsers.getUsuarios();
      setState(() => _usuarios = lista);
      _aplicarFiltros();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _cargando = false);
    }
  }

  // ─── Filtros: búsqueda + rol ───────────────────────────────────────────────
  void _aplicarFiltros() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _busqueda = query;
      _usuariosFiltrados = _usuarios.where((u) {
        final coincideBusqueda =
            u.nombre.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query);
        final coincideRol = _filtroRol == 'todos' || u.rol == _filtroRol;
        return coincideBusqueda && coincideRol;
      }).toList();
    });
  }

  // ─── Crear / Editar usuario ────────────────────────────────────────────────
  Future<void> _abrirFormulario({
    Usuario? usuarioExistente,
  }) async {
    final resultado = await mostrarFormularioUsuario(
      context,
      usuario: usuarioExistente,
    );

    if (resultado == null) return;

    try {
      if (usuarioExistente != null) {
        // ── Editar ──────────────────────────────────────────────────────────
        final actualizado = await AuthUsers.editarUsuario(
          usuarioExistente.idUser,
          resultado,
        );
        setState(() {
          final idx = _usuarios.indexWhere(
            (u) => u.idUser == usuarioExistente.idUser,
          );
          if (idx != -1) _usuarios[idx] = actualizado;
        });
        _mostrarSnack('Usuario actualizado', esError: false);
      } else {
        // ── Crear — pedimos contraseña antes de llamar a la API ─────────────
        final pass = await _pedirContrasena();
        if (pass == null || pass.isEmpty) return;

        final creado = await AuthUsers.crearUsuario(resultado, password: pass);
        setState(() => _usuarios.add(creado));
        _mostrarSnack('Usuario creado', esError: false);
      }
      _aplicarFiltros();
    } catch (e) {
      _mostrarSnack(e.toString(), esError: true);
    }
  }

  // ─── Diálogo para pedir contraseña al crear ────────────────────────────────
  Future<String?> _pedirContrasena() async {
    final ctrl = TextEditingController();
    bool ver = false;

    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Contraseña del nuevo usuario'),
          content: TextField(
            controller: ctrl,
            obscureText: !ver,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              suffixIcon: IconButton(
                icon: Icon(ver ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setSt(() => ver = !ver),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF051F20),
              ),
              onPressed: () {
                if (ctrl.text.length >= 6) {
                  Navigator.pop(ctx, ctrl.text);
                }
              },
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Confirmar eliminar ────────────────────────────────────────────────────
  Future<void> _confirmarEliminar(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar usuario'),
        content: Text(
          '¿Seguro que deseas eliminar a "${usuario.nombre}"?\nEsta acción no se puede deshacer.',
        ),
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
        await AuthUsers.eliminarUsuario(usuario.idUser);
        setState(
          () => _usuarios.removeWhere((u) => u.idUser == usuario.idUser),
        );
        _aplicarFiltros();
        _mostrarSnack('Usuario eliminado', esError: false);
      } catch (e) {
        _mostrarSnack(e.toString(), esError: true);
      }
    }
  }

  void _mostrarSnack(String msg, {bool esError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: esError ? Colors.redAccent : const Color(0xFF173831),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8CB79B),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF173831),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: const Icon(
          Icons.manage_accounts_outlined,
          color: Colors.white,
        ),
        title: const Text(
          'GESTOR DE USUARIOS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarUsuarios,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Barra de búsqueda ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o correo…',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF235347)),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF235347)),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _busqueda = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFDBF0DD),
                hintStyle: const TextStyle(color: Color(0xFF235347)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Chips de filtro por rol ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['todos', 'admin', 'vendedor', 'cliente'].map((rol) {
                  final seleccionado = _filtroRol == rol;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        rol[0].toUpperCase() + rol.substring(1),
                        style: TextStyle(
                          color: seleccionado
                              ? Colors.white
                              : const Color(0xFF235347),
                          fontWeight: seleccionado
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      selected: seleccionado,
                      onSelected: (_) {
                        setState(() => _filtroRol = rol);
                        _aplicarFiltros();
                      },
                      backgroundColor: const Color(0xFFDBF0DD),
                      selectedColor: const Color(0xFF173831),
                      checkmarkColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF235347)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Lista ──────────────────────────────────────────────────────────
          Expanded(
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF173831)),
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
                          onPressed: _cargarUsuarios,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : _usuariosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.group_off_outlined,
                          size: 70,
                          color: Color(0xFF235347),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _busqueda.isEmpty
                              ? 'No hay usuarios registrados'
                              : 'Sin resultados para "$_busqueda"',
                          style: const TextStyle(
                            color: Color(0xFF235347),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarUsuarios,
                    color: const Color(0xFF173831),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 90),
                      itemCount: _usuariosFiltrados.length,
                      itemBuilder: (ctx, i) => UsuarioCard(
                        usuario: _usuariosFiltrados[i],
                        onEditar: () => _abrirFormulario(
                          usuarioExistente: _usuariosFiltrados[i],
                        ),
                        onEliminar: () =>
                            _confirmarEliminar(_usuariosFiltrados[i]),
                      ),
                    ),
                  ),
          ),
        ],
      ),

      // ── FAB ────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: const Color(0xFF051F20),
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text(
          'Agregar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
