// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_bloc/api/login_api.dart';
import 'package:learning_bloc/api/notes_api.dart';
import 'package:learning_bloc/bloc/actions.dart';
import 'package:learning_bloc/bloc/app_state.dart';
import 'package:learning_bloc/models.dart';

class AppBloc extends Bloc<AppAction, AppState> {
  final LoginApiProtocol loginApi;
  final NotesAPIProtocol notesApi;

  AppBloc({
    required this.loginApi,
    required this.notesApi,
  }) : super(const AppState.empty()) {
    on<LoginAction>((event, emmit) async {
      // start loading
      emit(
        const AppState(
          isLoading: true,
          loginErrors: null,
          loginHandle: null,
          fetchedNotes: null,
        ),
      );
      // log the user in
      final loginHandle =
          await loginApi.login(email: event.email, password: event.password);
      emit(
        AppState(
          isLoading: false,
          loginErrors: loginHandle == null ? LoginErrors.invalidHandles : null,
          loginHandle: loginHandle,
          fetchedNotes: null,
        ),
      );
    });
    on<LoadNotesAction>((event, emit) async {
      // start loading
      emit(
        AppState(
          isLoading: true,
          loginErrors: null,
          loginHandle: state.loginHandle,
          fetchedNotes: null,
        ),
      );
      //invalid login handle cannot fetch notes
      final loginHandle = state.loginHandle;
      if (loginHandle != const LoginHandle.fooBar()) {
        emit(
          AppState(
            isLoading: false,
            loginErrors: LoginErrors.invalidHandles,
            loginHandle: loginHandle,
            fetchedNotes: null,
          ),
        );
        return;
      }
      // whe have a valid login handle and want to fetch notes
      final notes = await notesApi.getNotes(loginHandle: loginHandle!);
       emit(
          AppState(
            isLoading: false,
            loginErrors: null,
            loginHandle: loginHandle,
            fetchedNotes: null,
          ),
        );
    });
  }
}
