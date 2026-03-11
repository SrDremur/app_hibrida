import 'package:app_hibrida/layouts/box_input.dart';
import 'package:flutter/material.dart';

class ColumnLogin extends StatefulWidget {
  const ColumnLogin({super.key});

  @override
  State<ColumnLogin> createState() => _ColumnLoginState();
}

class _ColumnLoginState extends State<ColumnLogin> {
  // 1. Creamos la llave para validar todo el grupo
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // <--- El Form envuelve TODO
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 50),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE37EAF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 50),

                // --- Llamamos los inputs sin botón interno ---
                BoxInput(
                  labelText: "Email",
                  validator: (value) =>
                      value!.isEmpty ? "Falta el email" : null,
                ),
                const SizedBox(height: 15),
                BoxInput(
                  labelText: "Password",
                  isPassword: true,
                  validator: (value) =>
                      value!.length < 6 ? "Mínimo 6 caracteres" : null,
                ),

                const SizedBox(height: 30),

                // --- EL BOTÓN APARTE ---
                SizedBox(
                  width: double.infinity, // Ancho completo
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF060304),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Si entra aquí, todos los BoxInput son válidos
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("¡Todo listo para entrar!"),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "ENVIAR",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ... (aquí va tu Positioned del CircleAvatar que ya tenías)
          const Positioned(
            top: 0,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF060304),
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
          ),
        ],
      ),
    );
  }
}
