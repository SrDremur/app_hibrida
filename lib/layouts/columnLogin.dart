import 'package:app_hibrida/layouts/box_input.dart';
import 'package:app_hibrida/layouts/buttom_navigation.dart';
import 'package:app_hibrida/modules/gestionar_productos.dart';
import 'package:app_hibrida/rest_api.dart/auth.dart';
import 'package:flutter/material.dart';
import 'package:app_hibrida/modules/register.dart';

class ColumnLogin extends StatefulWidget {
  const ColumnLogin({super.key});

  @override
  State<ColumnLogin> createState() => _ColumnLoginState();
}

class _ColumnLoginState extends State<ColumnLogin> {
  // 1. Creamos la llave para validar todo el grupo
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false; // Para mostrar un círculo de carga

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
              color: const Color(0xFF8CB79B),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 50),

                // --- Llamamos los inputs sin botón interno ---
                BoxInput(
                  labelText: "Email",
                  controller: _emailController, // <--- ESTO CONECTA EL TEXTO
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Falta el email";
                    bool esValido =
                        value.endsWith('@gmail.com') ||
                        value.endsWith('@outlook.com') ||
                        value.endsWith('@hotmail.com');
                    return esValido ? null : "Solo @gmail, @outlook o @hotmail";
                  },
                ),
                const SizedBox(height: 15),
                BoxInput(
                  labelText: "Password",
                  isPassword: true,
                  controller: _passController, // <--- ESTO CONECTA LA CLAVE
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Falta la contraseña";
                    return value.length < 6 ? "Mínimo 6 caracteres" : null;
                  },
                ),

                const SizedBox(height: 30),

                // --- EL BOTÓN APARTE ---
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFDBF0DD),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF173831,
                            ), // Tu color negro
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () async {
                            // 1. Validamos los campos localmente
                            if (_formKey.currentState!.validate()) {
                              setState(
                                () => _isLoading = true,
                              ); // Mostramos carga

                              // 2. Intentamos el Login con la API
                              // Usamos .trim() para evitar errores por espacios accidentales
                              bool success = await AuthService.login(
                                _emailController.text.trim(),
                                _passController.text.trim(),
                              );

                              if (mounted)
                                setState(
                                  () => _isLoading = false,
                                ); // Quitamos carga

                              // 3. Respuesta según el resultado de la API
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "¡Bienvenido! Inicio de sesión exitoso",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                //AppConstants.id_user = ;
                                // Aquí podrías usar Navigator.push para cambiar de pestaña
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainNavigation(),
                                  ),
                                );
                              } else {
                                // El error específico ya lo imprime tu AuthService en consola
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Error: al iniciar secion"),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            "ENVIAR",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 15), // Espacio entre botones
                // --- BOTÓN PARA IR A REGISTRO ---
                TextButton(
                  onPressed: () {
                    // Navegamos a la pantalla de Registro
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Register()),
                    ); //ta tiste
                  },
                  child: const Text(
                    "¿No tienes cuenta? Regístrate aquí",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration
                          .underline, // Subrayado para que parezca link
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
              backgroundColor: Color(0xFF051f20),
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
          ),
        ],
      ),
    );
  }
}
