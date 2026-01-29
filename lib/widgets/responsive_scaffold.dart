import 'package:flutter/material.dart';
import 'web_app_bar.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? mobileDrawer;
  final PreferredSizeWidget? mobileAppBar;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.mobileDrawer,
    this.mobileAppBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Web / Desktop Layout
          return Scaffold(
            body: Column(
              children: [
                const WebAppBar(),
                Expanded(
                  child:
                      body, // Body takes remaining space. Body MUST handle Footer if it scrolls.
                ),
              ],
            ),
            floatingActionButton: floatingActionButton,
          );
        } else {
          // Mobile Layout
          return Scaffold(
            appBar: mobileAppBar,
            drawer: mobileDrawer,
            body: body,
            floatingActionButton: floatingActionButton,
          );
        }
      },
    );
  }
}
