import 'package:flutter/material.dart';

class BoxInput extends StatefulWidget {
  final String labelText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextEditingController? controller;
  // 1. Agregamos la propiedad keyboardType
  final TextInputType keyboardType; 
  // 2. Agregamos la propiedad onChanged para que puedas detectar cambios en tiempo real
  final Function(String)? onChanged; 
  final Function(String)? onFieldSubmitted;

  const BoxInput({
    super.key,
    required this.labelText,
    this.validator,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text, // Por defecto será texto normal
    this.onChanged, // Es opcional
    this.onFieldSubmitted,
  });

  @override
  State<BoxInput> createState() => _BoxInputState();
}

class _BoxInputState extends State<BoxInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      // 3. Conectamos el keyboardType al TextFormField
      keyboardType: widget.keyboardType, 
      // 4. Conectamos el onChanged
      onChanged: widget.onChanged, 
      onFieldSubmitted: widget.onFieldSubmitted,
      style: const TextStyle(color: Color(0XFF051F20)),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: Color(0XFF051F20)),
        filled: true,
        fillColor: const Color.fromARGB(132, 255, 255, 255),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0XFF051F20),
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
      ),
      validator: widget.validator,
    );
  }
}