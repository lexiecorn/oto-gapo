import 'package:flutter/material.dart';

/// Custom page transitions for smooth navigation
class PageTransitions {
  /// Slide transition from right
  static Widget slideFromRight(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1, 0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  /// Slide transition from left
  static Widget slideFromLeft(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(-1, 0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  /// Slide transition from bottom
  static Widget slideFromBottom(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0, 1);
    const end = Offset.zero;
    const curve = Curves.easeOut;

    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  /// Fade transition
  static Widget fade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Scale transition
  static Widget scale(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.easeInOut;

    final tween = Tween(begin: 0, end: 1).chain(
      CurveTween(curve: curve),
    );

    return ScaleTransition(
      scale: animation.drive(
        tween as Animatable<double>,
      ),
      child: child,
    );
  }

  /// Fade + Scale transition
  static Widget fadeScale(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
        ),
        child: child,
      ),
    );
  }

  /// Slide + Fade transition
  static Widget slideFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0, 0.1);
    const end = Offset.zero;
    const curve = Curves.easeOut;

    final slideTween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(slideTween),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Create a custom PageRouteBuilder with the specified transition
  static PageRouteBuilder<T> createRoute<T>({
    required Widget page,
    Widget Function(
      BuildContext,
      Animation<double>,
      Animation<double>,
      Widget,
    )? transitionBuilder,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: transitionBuilder ?? slideFromRight,
    );
  }
}

/// Hero animation helpers
class HeroHelpers {
  /// Create a hero for image transitions
  static Widget imageHero({
    required String tag,
    required ImageProvider image,
    BoxFit fit = BoxFit.cover,
  }) {
    return Hero(
      tag: tag,
      child: Image(
        image: image,
        fit: fit,
      ),
    );
  }

  /// Create a hero for text transitions
  static Widget textHero({
    required String tag,
    required String text,
    TextStyle? style,
  }) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: Text(
          text,
          style: style,
        ),
      ),
    );
  }

  /// Create a hero for icon transitions
  static Widget iconHero({
    required String tag,
    required IconData icon,
    Color? color,
    double? size,
  }) {
    return Hero(
      tag: tag,
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}
