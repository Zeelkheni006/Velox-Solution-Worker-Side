import 'package:flutter/material.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {

  bool hideScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      setState(() {
        hideScreen = true;
      });
    }

    if (state == AppLifecycleState.resumed) {
      setState(() {
        hideScreen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (hideScreen)
          Container(color: Colors.black),
      ],
    );
  }
}