import 'package:flutter/foundation.dart' show immutable;

typedef closeLoadingScreen = bool Function();
typedef updateLoadingScreen = bool Function(String text);

@immutable
class LoadingScreenController {
  final closeLoadingScreen close;
  final updateLoadingScreen update;

  const LoadingScreenController({required this.close, required this.update});
}
