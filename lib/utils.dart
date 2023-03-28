import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void afterRender(VoidCallback callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) => callback);
}

Future<void> waitRender() {
  final Completer<void> completer = Completer<void>();
  afterRender(() => completer.complete());
  return completer.future;
}

class BlankPlaceholder extends StatelessWidget {
  const BlankPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

RouteObserver<Route<void>> routeObserver = RouteObserver<Route<void>>();

mixin LifecycleObserver<T extends StatefulWidget> on State<T>
    implements WidgetsBindingObserver, RouteAware {
  bool isResume = false;

  bool get isCurrentPage => true == ModalRoute.of(context)?.isCurrent;

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
    if (isCurrentPage) {
      _internalResume();
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void didPushNext() {
    if (isCurrentPage) {
      _internalPause();
      WidgetsBinding.instance.removeObserver(this);
    }
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

extension StandardExt<T> on T {
  R let<R>(R Function(T) block) {
    return block(this);
  }

  T also<R>(Function(T) block) {
    block(this);
    return this;
  }
}
