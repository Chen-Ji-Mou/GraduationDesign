import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

void afterRender(VoidCallback callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) => callback);
}

Future<void> waitRender() {
  final Completer<void> completer = Completer<void>();
  afterRender(() => completer.complete());
  return completer.future;
}

class C extends StatelessWidget {
  const C(this.size, {Key? key}) : super(key: key);

  final double? size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size);
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

String mapToJsonString(Map<String, dynamic> map) => json.encode(map);
