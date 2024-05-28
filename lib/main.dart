import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_bloc/api/login_api.dart';
import 'package:learning_bloc/api/notes_api.dart';
import 'package:learning_bloc/bloc/actions.dart';
import 'package:learning_bloc/bloc/app_bloc.dart';
import 'package:learning_bloc/dialogues/generic_dialog.dart';
import 'package:learning_bloc/dialogues/loading_screen.dart';
import 'package:learning_bloc/models.dart';
import 'package:learning_bloc/strings.dart';
import 'package:learning_bloc/views/iterable_list_view.dart';
import 'package:learning_bloc/views/login_view.dart';

import 'bloc/app_state.dart';

void main() {
  runApp(const MyHomePage());
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: HomePage(),);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc(
        loginApi: LoginApi(),
        notesApi: NotesApi(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(homePage),
        ),
        body: BlocConsumer<AppBloc, AppState>(
          listener: (context, appState) {
            // loading screen
            if (appState.isLoading) {
              LoadingScreen.instance().show(context: context, text: pleaseWait);
            } else {
              LoadingScreen.instance().hide();
            }
            // display errors in appstate
            final loginError = appState.loginErrors;
            if (loginError != null) {
              showGenericDialog<bool>(
                context: context,
                title: loginErrorDialogTitle,
                content: loginErrorDialogContent,
                optionsBuilder: () => {ok: true},
              );
            }
            // if we are logged in but have no fetched notes, fetch them
            if (appState.isLoading == false &&
                appState.loginErrors == null &&
                appState.loginHandle == const LoginHandle.fooBar() &&
                appState.fetchedNotes == null) {
              context.read<AppBloc>().add(const LoadNotesAction());
            }
          },
          builder: (context, appState) {
            final notes = appState.fetchedNotes;
            if (notes == null) {
              return LoginView(
                onLogginTapped: ((email, password) {
                  context
                      .read<AppBloc>()
                      .add(LoginAction(email: email, password: password));
                }),
              );
            } else {
              return notes.toListView();
            }
          },
        ),
      ),
    );
  }
}
