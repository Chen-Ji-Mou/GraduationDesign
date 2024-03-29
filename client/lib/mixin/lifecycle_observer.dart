import 'package:flutter/material.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/route.dart';

mixin LifecycleObserver<T extends StatefulWidget> on State<T>
implements WidgetsBindingObserver, RouteAware {
  bool isResume = false;

  @override
  void didChangeDependencies() {
    ModalRoute.of(context)?.let((ModalRoute<Object?> route) {
      routeObserver.subscribe(this, route);
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    _internalResume();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didPop() {
    _internalPause();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didPopNext() {
    _internalResume();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didPushNext() {
    _internalPause();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) {
      return;
    }
    switch (state) {
      case AppLifecycleState.resumed:
        _internalResume();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _internalPause();
        break;
    }
  }

  void _internalResume() {
    if (isResume) {
      return;
    }
    isResume = true;
    onResume();
  }

  void _internalPause() {
    if (!isResume) {
      return;
    }
    isResume = false;
    onPause();
  }

  void onResume() {}

  void onPause() {}

  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void didChangeLocales(List<Locale>? locales) {}

  @override
  void didChangeMetrics() {}

  @override
  void didChangePlatformBrightness() {}

  @override
  void didChangeTextScaleFactor() {}

  @override
  void didHaveMemoryPressure() {}

  @override
  Future<bool> didPopRoute() {
    return Future<bool>.value(false);
  }

  @override
  Future<bool> didPushRoute(String? route) {
    return Future<bool>.value(false);
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    return didPushRoute(routeInformation.location);
  }
}