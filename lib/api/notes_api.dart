import 'package:flutter/foundation.dart' show immutable;
import 'package:learning_bloc/models.dart';

@immutable
abstract class NotesAPIProtocol {
  const NotesAPIProtocol();

  Future<Iterable<Note>?> getNotes({
    required LoginHandle loginHandle,
  });
}

@immutable
class NotesApi implements NotesAPIProtocol {
  // singleton pattern 
  @override
  Future<Iterable<Note>?> getNotes({
   required LoginHandle loginHandle,
  }) =>
      Future.delayed(
        const Duration(seconds: 2),
        () => loginHandle == const LoginHandle.fooBar() ? mockedNotes : null,
      );
}
