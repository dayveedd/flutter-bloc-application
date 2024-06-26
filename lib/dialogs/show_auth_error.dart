import 'package:flutter/material.dart' show BuildContext;
import 'package:learning_bloc/auth/auth_errors.dart';
import 'package:learning_bloc/dialogs/generic_dialog.dart';

Future<void> showAuthError({
  required AuthError authError,
  required BuildContext context,
}) {
  return showGenericDialog<void>(
    context: context,
    title: authError.dialogTitle,
    content:
        authError.dialogText,
    optionsBuilder: () => {'OK': true},
  );
}
