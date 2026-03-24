import 'package:app_hibrida/layouts/columnLogin.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Color(0xFFDBF0DD),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: SizedBox(width: 400, child: ColumnLogin()),
        ),
      ),
    );
  }
}
