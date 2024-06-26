import 'package:flutter/material.dart' show BuildContext;
import 'package:learning_bloc/dialogs/generic_dialog.dart';

Future<bool> showDeleteAccountDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete account',
    content:
        'Are you sure you want to delete your account? you can\'t undo this operation',
    optionsBuilder: () => {'Cancel': false, 'Delete Account': true},
  ).then((value) => value ?? false);
}
