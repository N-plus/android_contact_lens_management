import 'package:flutter/material.dart';

class BootstrapPage extends StatelessWidget {
  const BootstrapPage({
    super.key,
    required this.isReady,
    required this.error,
    required this.readyChild,
  });

  final bool isReady;
  final Object? error;
  final Widget readyChild;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        body: Center(
          child: Text('起動時にエラーが発生しました:\n${error.toString()}'),
        ),
      );
    }

    if (!isReady) {
      return const SplashPage();
    }

    return readyChild;
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
