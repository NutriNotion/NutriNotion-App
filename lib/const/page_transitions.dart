import 'package:flutter/material.dart';

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final int durationMs;

  FadePageRoute({
    required this.child,
    this.durationMs = 300,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: Duration(milliseconds: durationMs),
          reverseTransitionDuration: Duration(milliseconds: durationMs),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
              ),
              child: child,
            );
          },
        );
}

// Extension method to make navigation easier
extension NavigationExtension on BuildContext {
  Future<T?> pushFade<T extends Object?>(Widget page, {int duration = 300}) {
    return Navigator.of(this).push<T>(
      FadePageRoute<T>(child: page, durationMs: duration),
    );
  }

  Future<T?> pushReplacementFade<T extends Object?, TO extends Object?>(
    Widget page, {
    int duration = 300,
    TO? result,
  }) {
    return Navigator.of(this).pushReplacement<T, TO>(
      FadePageRoute<T>(child: page, durationMs: duration),
      result: result,
    );
  }
}
