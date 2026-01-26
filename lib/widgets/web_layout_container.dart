import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class WebLayoutContainer extends StatelessWidget {
  final Widget child;

  const WebLayoutContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: child,
        ),
      );
    }
    return child;
  }
}
