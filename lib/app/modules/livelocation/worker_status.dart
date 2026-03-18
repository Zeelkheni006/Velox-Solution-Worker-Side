import 'package:flutter/material.dart';
import '../../../core/api/Api_Service/Live_Location/live_location.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // App open thai tyare
    LiveLocationService.workerStatus(isOnline: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // App destroy thai tyare
    LiveLocationService.workerStatus(isOnline: false);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("APP STATE: $state");

    if (state == AppLifecycleState.resumed) {
      // App foreground ma aave
      LiveLocationService.workerStatus(isOnline: true);
    }

    if (state == AppLifecycleState.paused) {
      // App background ma jai
      LiveLocationService.workerStatus(isOnline: "background");
    }

    if (state == AppLifecycleState.detached) {
      // App kill / remove from recent
      LiveLocationService.workerStatus(isOnline: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}