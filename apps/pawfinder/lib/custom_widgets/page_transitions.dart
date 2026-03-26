import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Slide transition from right
class SlideRightTransitionPage extends CustomTransitionPage {
  SlideRightTransitionPage({
    super.key,
    required super.child,
    super.name,
    super.arguments,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}

/// Slide transition from left
class SlideLeftTransitionPage extends CustomTransitionPage {
  SlideLeftTransitionPage({
    super.key,
    required super.child,
    super.name,
    super.arguments,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}

/// Fade transition
class FadeTransitionPage extends CustomTransitionPage {
  FadeTransitionPage({
    super.key,
    required super.child,
    super.name,
    super.arguments,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}

/// Scale with fade transition
class ScaleFadeTransitionPage extends CustomTransitionPage {
  ScaleFadeTransitionPage({
    super.key,
    required super.child,
    super.name,
    super.arguments,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}

/// Opaque transition for Auto/Tele/Post-Match section switches.
/// Prevents previous section widgets from showing through while animating.
class MatchSectionTransitionPage extends CustomTransitionPage {
  MatchSectionTransitionPage({
    super.key,
    required super.child,
    super.name,
    super.arguments,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.12, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 240),
          reverseTransitionDuration: const Duration(milliseconds: 220),
        );
}
