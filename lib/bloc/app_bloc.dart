import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:learning_bloc/auth/auth_errors.dart';
import 'package:learning_bloc/bloc/app_event.dart';
import 'package:learning_bloc/bloc/app_state.dart';
import 'package:learning_bloc/utils/upload_image.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppStateLoggedOut(isLoading: false)) {
    on<AppEventGoToLogin>(
      (event, emit) {
        emit(
          const AppStateLoggedOut(isLoading: false),
        );
      },
    );
    on<AppEventGoToRegistration>(
      (event, emit) {
        emit(
          const AppStateIsInRegistrationView(isLoading: false),
        );
      },
    );
    // login event handler
    on<AppEventLogin>(
      (event, emit) async {
        emit(
          const AppStateLoggedOut(isLoading: false),
        );
        // log the user in
        try {
          final email = event.email;
          final password = event.password;
          final credentials = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);
          // get images for user after logging in
          final user = credentials.user!;
          final images = await _getImages(user.uid);
          emit(
            AppStateLoggedIn(isLoading: false, user: user, images: images),
          );
        } on FirebaseAuthException catch (e) {
          // catching any error that occured during login
          emit(
            AppStateLoggedOut(isLoading: false, authError: AuthError.from(e)),
          );
        }
      },
    );
    // register user event
    on<AppEventRegister>(
      (event, emit) async {
        // start loading
        emit(
          const AppStateIsInRegistrationView(isLoading: true),
        );
        final email = event.email;
        final password = event.password;
        try {
          // register the user
          final credentials = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);
          emit(
            AppStateLoggedIn(
              isLoading: false,
              user: credentials.user!,
              images: const [],
            ),
          );
        } on FirebaseAuthException catch (e) {
          // catch any error that happens
          emit(
            AppStateIsInRegistrationView(
              isLoading: false,
              authError: AuthError.from(e),
            ),
          );
        }
      },
    );
    on<AppEventInitialise>(
      (event, emit) async {
        // get the current user
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(
            const AppStateLoggedOut(isLoading: false),
          );
        } else {
          // go grab the images
          final images = await _getImages(user.uid);
          emit(
            AppStateLoggedIn(isLoading: false, user: user, images: images),
          );
        }
      },
    );
    // log user out
    on<AppEventLogOut>(
      (event, emit) async {
        // start loading
        emit(
          const AppStateLoggedOut(isLoading: true),
        );
        // log the user out
        await FirebaseAuth.instance.signOut();
        // log the user out in the UI as well
        emit(
          const AppStateLoggedOut(isLoading: false),
        );
      },
    );
    // handle deleting user account
    on<AppEventDeleteAccount>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        // log the user out if we dont have a current user
        if (user == null) {
          emit(
            const AppStateLoggedOut(isLoading: false),
          );
          return;
        }
        // start the loading process
        emit(
          AppStateLoggedIn(
            isLoading: true,
            user: user,
            images: state.images ?? [],
          ),
        );
        // delete the user folder
        try {
          // delete user folder
          final folderContent =
              await FirebaseStorage.instance.ref(user.uid).listAll();
          for (final item in folderContent.items) {
            await item.delete().catchError((_) => {});
          }
          // delete the folder itself
          await FirebaseStorage.instance
              .ref(user.uid)
              .delete()
              .catchError((_) {});
          // delete the user
          await user.delete();
          // log the user out
          await FirebaseAuth.instance.signOut();
          // log the user out in the UI as well
          emit(
            const AppStateLoggedOut(isLoading: false),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateLoggedIn(
              isLoading: false,
              user: user,
              images: state.images ?? [],
              authError: AuthError.from(e),
            ),
          );
        } on FirebaseException {
          // we might not be able to delete the user account
          // log the user out
          emit(
            const AppStateLoggedOut(isLoading: false),
          );
        }
      },
    );

    // handle uploading images
    on<AppEventUploadImage>(
      (event, emit) async {
        final user = state.user;
        // log user out if we dont have valid user
        if (user == null) {
          emit(
            const AppStateLoggedOut(isLoading: false),
          );
          return;
        }

        // start the loading process
        emit(
          AppStateLoggedIn(
            isLoading: true,
            user: user,
            images: state.images ?? [],
          ),
        );

        // upload the file
        final file = File(event.filePathToUpload);
        await uploadImage(file: file, userId: user.uid);
        // after upload is complete, grab the latest file references
        final images = await _getImages(user.uid);
        emit(AppStateLoggedIn(isLoading: false, user: user, images: images));
      },
    );
  }
  Future<Iterable<Reference>> _getImages(String userId) =>
      FirebaseStorage.instance
          .ref(userId)
          .list()
          .then((listResult) => listResult.items);
}
