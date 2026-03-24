import 'package:flutter/material.dart';

class BoxInput extends StatefulWidget {
  final String labelText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextEditingController? controller;

  const BoxInput({
    super.key,
    required this.labelText,
    this.validator,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<BoxInput> createState() => _BoxInputState();
}

class _BoxInputState extends State<BoxInput> {
  // Esta variable interna controlará si el texto se oculta o no
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // Inicializamos con el valor que viene por parámetro (isPassword)
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText, // Usamos nuestra variable interna
      style: const TextStyle(color: Color(0XFF051F20)),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: Color(0XFF051F20)),
        filled: true,
        fillColor: const Color.fromARGB(132, 255, 255, 255),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),

        // Agregamos el ojito solo si es un campo de password
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0XFF051F20),
                ),
                onPressed: () {
                  // Esto es lo que hace la magia de cambiar el icono y el texto
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null, // Si no es password, no muestra nada
      ),
      validator: widget.validator,
    );
  }
}
