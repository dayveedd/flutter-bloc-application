import 'package:flutter/material.dart';
import 'package:learning_bloc/strings.dart' show enterYourPasswordHere;

class PasswordTextField extends StatelessWidget {
  final TextEditingController passwordController;
  const PasswordTextField({required this.passwordController ,super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: passwordController,
      obscureText: true,
      obscuringCharacter: '😂',
      decoration: const InputDecoration(
        hintText: enterYourPasswordHere,
      ),
    );
  }
}
