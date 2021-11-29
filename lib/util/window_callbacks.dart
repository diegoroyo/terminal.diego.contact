import 'package:terminal/widgets/floating_window.dart';
import 'package:flutter/material.dart';

class WindowCallbacks {
  final void Function(FloatingWindow) requestFocus, openWindow, closeWindow;
  final FloatingWindow Function(String, Widget) buildWindow;

  const WindowCallbacks(
      {required this.requestFocus,
      required this.openWindow,
      required this.closeWindow,
      required this.buildWindow});
}
