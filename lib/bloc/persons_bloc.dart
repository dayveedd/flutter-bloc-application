import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_bloc/bloc/person.dart';

import 'bloc_actions.dart';

extension IsEqualToIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == length;
}

@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;

  const FetchResult(
      {required this.persons, required this.isRetrievedFromCache});

  @override
  String toString() =>
      'FetchResult (isRetrievedFromCache = $isRetrievedFromCache, persons = $persons)';

  @override
  bool operator ==(covariant FetchResult other) =>
      persons.isEqualToIgnoringOrdering(other.persons) &&
      isRetrievedFromCache == other.isRetrievedFromCache;

  @override
  int get hashCode => Object.hash(persons, isRetrievedFromCache);
}

class PersonBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<String, Iterable<Person>> _cache = {};
  PersonBloc() : super(null) {
    on<LoadPersonsAction>((event, emit) async {
      //todo
      final url = event.url;
      if (_cache.containsKey(url)) {
        //we have the value in the cache
        final cachedPersons = _cache[url]!;
        final results =
            FetchResult(persons: cachedPersons, isRetrievedFromCache: true);
        emit(results);
      } else {
        final loader = event.loader;
        final persons = await loader(url);
        _cache[url] = persons;
        final results =
            FetchResult(persons: persons, isRetrievedFromCache: false);
        emit(results);
      }
    });
  }
}
