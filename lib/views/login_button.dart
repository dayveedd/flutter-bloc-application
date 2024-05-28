import 'package:flutter/material.dart';
import 'package:learning_bloc/dialogues/generic_dialog.dart';
import 'package:learning_bloc/strings.dart';

typedef OnLogginTapped = void Function(
  String email,
  String password,
);

class LoginButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final OnLogginTapped onLogginTapped;

  const LoginButton(
      {super.key,
      required this.emailController,
      required this.passwordController,
      required this.onLogginTapped});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        final email = emailController.text;
        final password = passwordController.text;
        if (email.isEmpty || password.isEmpty) {
          showGenericDialog<bool>(
            context: context,
            title: emailOrPasswordEmptyDialogTitle,
            content: emailOrPasswordEmptyDescription,
            optionsBuilder: () => {ok: true},
          );
        } else {
          onLogginTapped(email, password);
        }
      },
      child: const Text(login),
    );
  }
}
