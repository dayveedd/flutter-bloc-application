import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

import 'bloc/bloc_actions.dart';
import 'bloc/person.dart';
import 'bloc/persons_bloc.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(),
    debugShowCheckedModeBanner: false,
    home: BlocProvider(
      create: (_) => PersonBloc(),
      child: const MyHomePage(),
    ),
  ));
}







Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));





extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('application'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    context.read<PersonBloc>().add(
                          const LoadPersonsAction(url: persons1Url, loader: getPersons),
                        );
                  },
                  child: const Text('Load json #1')),
              TextButton(
                  onPressed: () {
                    context.read<PersonBloc>().add(
                          const LoadPersonsAction(url: persons1Ur2, loader: getPersons),
                        );
                  },
                  child: const Text('Load json #2')),
            ],
          ),
          BlocBuilder<PersonBloc, FetchResult?>(
            buildWhen: (previousResult, currentResult) {
              return previousResult?.persons != currentResult?.persons;
            },
            builder: ((context, fetchResult) {
              fetchResult?.log();
              final persons = fetchResult?.persons;
              if (persons == null) {
                return const SizedBox();
              }
              return Expanded(
                  child: ListView.builder(
                      itemCount: persons.length,
                      itemBuilder: (context, index) {
                        final person = persons[index]!;
                        return ListTile(
                          title: Text(person.name),
                        );
                      }));
            }),
          )
        ],
      ),
    );
  }
}
