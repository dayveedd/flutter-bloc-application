import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:learning_bloc/bloc/bloc_actions.dart';
import 'package:learning_bloc/bloc/person.dart';
import 'package:learning_bloc/bloc/persons_bloc.dart';

const mockedPerson1 = [
  Person(name: 'foo', age: 20),
  Person(name: 'bar', age: 30)
];

const mockedPerson2 = [
  Person(name: 'foo', age: 20),
  Person(name: 'bar', age: 30)
];

Future<Iterable<Person>> mockGetPerson1(String _) =>
    Future.value(mockedPerson1);

Future<Iterable<Person>> mockGetPerson2(String _) =>
    Future.value(mockedPerson2);

void main() {
  group('Testing bloc', () {
    // write our tests

    late PersonBloc bloc;

    setUp(() => bloc = PersonBloc());

    blocTest<PersonBloc, FetchResult?>('initial testing',
        build: () => bloc, verify: (bloc) => expect(bloc.state ,null));

    // fetch mock data (persons1) and compare it with fetchResult

    blocTest(
      'mock retrieving persons from first iterable',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const LoadPersonsAction(url: 'dummy_url_1', loader: mockGetPerson1));
         bloc.add(const LoadPersonsAction(url: 'dummy_url_1', loader: mockGetPerson1));
      },
      expect: () => [
        const FetchResult(persons: mockedPerson1, isRetrievedFromCache: false),
        const FetchResult(persons: mockedPerson1, isRetrievedFromCache: true),
      ]
    );

     // fetch mock data (persons2) and compare it with fetchResult

    blocTest(
      'mock retrieving persons from second iterable',
      build: () => bloc,
      act: (bloc) {
        bloc.add(const LoadPersonsAction(url: 'dummy_url_2', loader: mockGetPerson2));
         bloc.add(const LoadPersonsAction(url: 'dummy_url_2', loader: mockGetPerson2));
      },
      expect: () => [
        const FetchResult(persons: mockedPerson2, isRetrievedFromCache: false),
        const FetchResult(persons: mockedPerson2, isRetrievedFromCache: true),
      ]
    );
  });
}
