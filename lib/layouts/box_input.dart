import 'package:flutter/material.dart';

class BoxInput extends StatelessWidget {
  final String labelText;
  final String? Function(String?)? validator; // Pasamos la lógica de validación
  final bool isPassword;
  final TextEditingController? controller; // Para recuperar el texto después

  const BoxInput({
    super.key,
    required this.labelText,
    this.validator,
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color.fromARGB(76, 255, 255, 255), // Color sutil
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      validator: validator, // Usa la función que le mandemos
    );
  }
}
