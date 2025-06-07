import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {

  const LoadingOverlay({
    required this.isLoading, required this.child, super.key,
    this.color,
  });
  final bool isLoading;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          ColoredBox(
            color: color ?? Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
