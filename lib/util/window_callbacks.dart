import 'package:terminal/widgets/floating_window.dart';

enum WindowType { TERMINAL, HTML_VIEWER }

class WindowData {
  final WindowType type;
  final String title;

  final List<String>? commands;
  final String? htmlFilename;

  WindowData.terminal({required this.title, required this.commands})
      : type = WindowType.TERMINAL,
        htmlFilename = null;

  WindowData.html({required this.title, required this.htmlFilename})
      : type = WindowType.HTML_VIEWER,
        commands = null;
}

class WindowCallbacks {
  final void Function(FloatingWindow) requestFocus, openWindow, closeWindow;
  final FloatingWindow Function(WindowData) buildWindow;

  const WindowCallbacks(
      {required this.requestFocus,
      required this.openWindow,
      required this.closeWindow,
      required this.buildWindow});
}
