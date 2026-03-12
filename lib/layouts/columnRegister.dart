import 'package:app_hibrida/layouts/box_input.dart';
import 'package:flutter/material.dart';

class ColumnRegister extends StatefulWidget {
  const ColumnRegister({super.key});

  @override
  State<ColumnRegister> createState() => _ColumnRegisterState();
}

class _ColumnRegisterState extends State<ColumnRegister> {
  final _formKey = GlobalKey<FormState>();
  // Controladores opcionales para capturar los datos
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _roleController = TextEditingController();

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
              color: const Color(0xFFE37EAF), // Mismo rosa que el login
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
                  labelText: "Rol",
                  controller: _roleController,
                  validator: (value) => value!.isEmpty ? "Falta el rol" : null,
                ),

                const SizedBox(height: 30),

                // BOTÓN DE REGISTRO
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF060304), // Negro/Oscuro
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Aquí llamarás a tu rest_api.dart después
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Registrando usuario..."),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "REGISTRARSE",
                      style: TextStyle(color: Colors.white),
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
              backgroundColor: Color(0xFF060304),
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
