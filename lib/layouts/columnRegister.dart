import 'package:app_hibrida/layouts/box_input.dart';
import 'package:app_hibrida/modules/login.dart';
import 'package:app_hibrida/rest_api.dart/auth.dart';
import 'package:flutter/material.dart';

class ColumnRegister extends StatefulWidget {
  const ColumnRegister({super.key});

  @override
  State<ColumnRegister> createState() => _ColumnRegisterState();
}

class _ColumnRegisterState extends State<ColumnRegister> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores opcionales para capturar los datos
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _passController2 = TextEditingController();

  String? _opcionSeleccionada; // Aquí se guarda lo que el usuario elija
  List<String> _roles = ['adminin', 'vendedor', 'consultor'];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 50),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF8CB79B), // Mismo rosa que el login
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 50),

                BoxInput(
                  labelText: "Nombre",
                  controller: _nameController,
                  validator: (value) =>
                      value!.isEmpty ? "Falta el nombre" : null,
                ),
                const SizedBox(height: 15),

                BoxInput(
                  labelText: "Email",
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Falta el email";
                    bool esValido =
                        value.endsWith('@gmail.com') ||
                        value.endsWith('@outlook.com') ||
                        value.endsWith('@hotmail.com');
                    return esValido ? null : "Solo gmail, outlook o hotmail";
                  },
                ),
                const SizedBox(height: 15),

                BoxInput(
                  labelText: "Password",
                  isPassword: true,
                  controller: _passController,
                  validator: (value) =>
                      value!.length < 6 ? "Mínimo 6 caracteres" : null,
                ),

                const SizedBox(height: 15),

                BoxInput(
                  labelText: "Confirm Password",
                  isPassword: true,
                  controller: _passController2,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Falta confirmar la contraseña";
                    if (value != _passController.text)
                      return "Las contraseñas no coinciden";
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                DropdownButtonFormField<String>(
                  value: _opcionSeleccionada,
                  hint: const Text(
                    "Selecciona un rol",
                    style: TextStyle(color: Color.fromARGB(232, 255, 255, 255)),
                  ),
                  dropdownColor: const Color(0XFF235347),
                  // Color del fondo del menú al abrirse
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(122, 35, 83, 71),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  // Mapeamos la lista de strings a elementos del menú
                  items: _roles.map((String rol) {
                    return DropdownMenuItem<String>(
                      value: rol,
                      child: Text(rol),
                    );
                  }).toList(),
                  onChanged: (nuevoValor) {
                    setState(() {
                      _opcionSeleccionada = nuevoValor;
                    });
                  },
                  validator: (value) => value == null ? "Rol" : null,
                ),

                const SizedBox(height: 30),

                // BOTÓN DE REGISTRO
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF173831),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              // Aquí iría la lógica para enviar los datos al backend
                              bool succes = await AuthService.register(
                                _nameController.text,
                                _emailController.text,
                                _passController.text,
                                _opcionSeleccionada!,
                              );

                              if (mounted) setState(() => _isLoading = false);

                              if (succes) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("¡Registro exitoso!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                // Aquí podrías redirigir al usuario a otra pantalla, por ejemplo:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Login(),
                                  ),
                                );
                                // Navigator.pushReplacementNamed(context, '/home');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Error en el registro"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            "REGISTRATE",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          // Mismo Avatar que el Login para mantener estética
          const Positioned(
            top: 0,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF051F20),
              child: Icon(
                Icons.app_registration,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
