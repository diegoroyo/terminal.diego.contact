import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:terminal/include/assets.dart';
import 'package:terminal/include/style.dart';
import 'package:terminal/util/terminal_scroll_view.dart';
import 'package:terminal/util/window_callbacks.dart';
import 'package:terminal/widgets/floating_window.dart';
import 'package:terminal/widgets/html_viewer.dart';
import 'package:terminal/widgets/terminal/terminal.dart';
import 'dart:math';

class LandingScreen extends StatefulWidget {
  final List<WindowData> initialWindows;

  LandingScreen({required this.initialWindows});

  @override
  _LandingScreenState createState() => new _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with WidgetsBindingObserver {
  static const HOME_COLOR = Color(0xFF1D1F28);
  WindowCallbacks? windowCallbacks;

  Random random = Random();

  List<FloatingWindow> windows = [];
  List<int> windowIndex = []; // z-ordering

  @override
  void initState() {
    super.initState();

    windowCallbacks = WindowCallbacks(
      requestFocus: requestFocus,
      openWindow: openWindow,
      closeWindow: closeWindow,
      buildWindow: buildWindowData,
    );

    WidgetsBinding.instance!.addObserver(this);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.initialWindows.isNotEmpty) {
        widget.initialWindows
            .forEach((data) => openWindow(buildWindowData(data)));
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {
      TerminalStyle.IS_VERTICAL = MediaQuery.of(context).size.aspectRatio < 1;
    });
  }

  static const VERTICAL_PADDING = 40.0;

  double getTerminalSizeYMobile() {
    final viewInsets = EdgeInsets.fromWindowPadding(
        WidgetsBinding.instance!.window.viewInsets,
        WidgetsBinding.instance!.window.devicePixelRatio);
    return MediaQuery.of(context).size.height - // full height
        MediaQuery.of(context).padding.top - // top navigator bar
        MediaQuery.of(context).padding.bottom - // bottom navigator bar
        viewInsets.bottom - // keyboard height
        2 * VERTICAL_PADDING; // a bit of spacing
  }

  /// Called when terminal is created or window is resized
  Size getTerminalSize() {
    double width = TerminalStyle.IS_VERTICAL ? 350.0 : 600.0;
    double height = TerminalStyle.IS_MOBILE ? getTerminalSizeYMobile() : 500.0;
    return Size(width, height);
  }

  /// Called when terminal is created or window is resized
  Point<double> getTerminalPosition([Point<double>? original]) {
    if (original != null &&
        !TerminalStyle.IS_MOBILE &&
        !TerminalStyle.IS_VERTICAL) {
      return original;
    }
    double posX = TerminalStyle.IS_VERTICAL || TerminalStyle.IS_MOBILE
        ? 0.0
        : random.nextInt(300) - 150;
    double posY = TerminalStyle.IS_VERTICAL || TerminalStyle.IS_MOBILE
        ? 0.0
        : random.nextInt(300) - 150;
    return Point(posX, posY);
  }

  bool getMovable() => !TerminalStyle.IS_MOBILE;

  FloatingWindow floatingWindow(String title, Widget child) => FloatingWindow(
        key: GlobalKey(),
        title: title,
        getSize: getTerminalSize,
        getPosition: getTerminalPosition,
        movable: getMovable(),
        child: child,
        windowCallbacks: windowCallbacks!,
      );

  FloatingWindow terminal(
          {required String title, required List<String> initialCommands}) =>
      floatingWindow(
          title,
          Terminal(
              initialCommands: initialCommands,
              windowCallbacks: windowCallbacks!));

  FloatingWindow htmlViewer(
          {required String title, required String htmlFilename}) =>
      floatingWindow(
          title,
          TerminalScrollView(
              child: HtmlViewer(
                  color: Color(0xFF333541),
                  data: TerminalAssets.readText(htmlFilename),
                  windowCallbacks: windowCallbacks!)));

  FloatingWindow buildWindowData(WindowData data) {
    switch (data.type) {
      case WindowType.TERMINAL:
        return terminal(title: data.title, initialCommands: data.commands!);
      case WindowType.HTML_VIEWER:
        return htmlViewer(title: data.title, htmlFilename: data.htmlFilename!);
    }
  }

  void requestFocus(FloatingWindow window) {
    var index = windows.indexOf(window);
    if (index < 0) {
      return;
    }
    setState(() {
      windowIndex[index] = windowIndex.reduce(max) + 1;
    });
  }

  void openWindow(FloatingWindow window) {
    setState(() {
      windows.add(window);
      if (windowIndex.length == 0) {
        windowIndex.add(1);
      } else {
        windowIndex.add(windowIndex.reduce(max) + 1);
      }
    });
  }

  void closeWindow(FloatingWindow window) {
    var index = windows.indexOf(window);
    if (index < 0) {
      print('Trying to remove a window that does not exist?');
      return;
    }
    setState(() {
      windows.removeAt(index);
      windowIndex.removeAt(index);
    });
  }

  Widget _buildLaunchButton(
          {required String image,
          required String label,
          required void Function() onTap}) =>
      Container(
          width: 150.0,
          child: TextButton(
            onPressed: onTap,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.black26),
              overlayColor: MaterialStateProperty.all(Colors.black26),
              foregroundColor: MaterialStateProperty.all(Colors.black26),
              padding: MaterialStateProperty.all(EdgeInsets.all(15.0)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0))),
            ),
            child: Column(children: [
              SvgPicture.asset(image, height: 60.0, width: 60.0),
              Container(width: 0.0, height: 5.0),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TerminalStyle.monospaced(
                      fontSize: 16.0, fontWeight: FontWeight.bold))
            ]),
          ));

  Widget _buildCenter() => Material(
      color: Colors.transparent,
      elevation: 15.0,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
          width: TerminalStyle.IS_VERTICAL ? 360 : 550,
          height: TerminalStyle.IS_VERTICAL ? 570 : 440,
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
              color: HOME_COLOR, borderRadius: BorderRadius.circular(20.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder(
                  stream: Stream.periodic(Duration(seconds: 1)),
                  builder: (context, snapshot) => Text(
                      DateFormat('HH:mm:ss').format(DateTime.now()),
                      style: TerminalStyle.monospaced(fontSize: 54.0))),
              Container(height: 10.0),
              Text('Welcome!', style: TerminalStyle.monospaced(fontSize: 36.0)),
              Container(height: 20.0),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 15.0,
                runSpacing: 15.0,
                children: [
                  _buildLaunchButton(
                      image: TerminalAssets.ICON_PROJECTS,
                      label: 'Personal projects',
                      onTap: () => setState(() => openWindow(terminal(
                          title: 'Projects',
                          initialCommands: ['cat projects.txt'])))),
                  // _buildLaunchButton(
                  //     image: TerminalAssets.ICON_CV,
                  //     label: 'Curriculum Vitae',
                  //     onTap: () => setState(() => openWindow(terminal(
                  //         title: 'Curriculum Vitae',
                  //         initialCommands: ['cat cv.pdf'])))), // TODO
                  _buildLaunchButton(
                      image: TerminalAssets.ICON_PUBLICATIONS,
                      label: 'Publications',
                      onTap: () => setState(() => openWindow(terminal(
                          title: 'Publications',
                          initialCommands: ['cat publications.txt'])))),
                  _buildLaunchButton(
                      image: TerminalAssets.ICON_NEWS,
                      label: 'Recent news',
                      onTap: () => setState(() => openWindow(terminal(
                          title: 'News', initialCommands: ['cat news.txt'])))),
                  _buildLaunchButton(
                      image: TerminalAssets.ICON_TERMINAL,
                      label: 'Terminal',
                      onTap: () => setState(() => openWindow(terminal(
                          title: 'Terminal', initialCommands: ['help'])))),
                  _buildLaunchButton(
                      image: TerminalAssets.ICON_CONTACT,
                      label: 'Contact',
                      onTap: () => setState(() => openWindow(terminal(
                          title: 'Contact', initialCommands: ['neofetch'])))),
                ],
              )
            ],
          )));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage(TerminalAssets.BACKGROUND_IMAGE),
            fit: BoxFit.cover,
          )),
          child: SafeArea(
              child: Indexer(
            clipBehavior: Clip.none,
            children: [Indexed(index: 0, child: Center(child: _buildCenter()))]
              ..addAll(windows
                  .asMap()
                  .entries
                  .map<Widget>((entry) => Indexed(
                      index: windowIndex[entry.key],
                      child: Positioned.fill(child: entry.value)))
                  .toList()),
          )),
        ));
  }
}
