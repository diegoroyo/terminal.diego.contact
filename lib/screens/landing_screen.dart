import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:indexed/indexed.dart';
import 'package:terminal/include/assets.dart';
import 'package:terminal/include/style.dart';
import 'package:terminal/util/html.dart';
import 'package:terminal/util/terminal_scroll_view.dart';
import 'package:terminal/util/window_callbacks.dart';
import 'package:terminal/widgets/floating_window.dart';
import 'package:terminal/widgets/html_viewer.dart';
import 'package:terminal/widgets/terminal/terminal.dart';
import 'package:defer_pointer/defer_pointer.dart';
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

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      didChangeMetrics();
      if (widget.initialWindows.isNotEmpty) {
        if (TerminalStyle.TERMINAL_WIDTH != TerminalWidth.LARGE_2X) {
          // if only one window fits, only open the first terminal
          openWindow(buildWindowData(widget.initialWindows[0]));
        } else {
          // if more than one window fits, open all
          widget.initialWindows
              .forEach((data) => openWindow(buildWindowData(data)));
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    Size screenSize = MediaQuery.of(context).size;
    setState(() {
      // Ad-hoc for top menu
      TerminalStyle.IS_WIDE = MediaQuery.of(context).size.width < 1700;
      TerminalStyle.IS_VERTICAL = MediaQuery.of(context).size.aspectRatio < 1;
      if (screenSize.width > 1640) {
        TerminalStyle.TERMINAL_WIDTH = TerminalWidth.LARGE_2X;
      } else if (screenSize.width > 820) {
        TerminalStyle.TERMINAL_WIDTH = TerminalWidth.LARGE;
      } else {
        TerminalStyle.TERMINAL_WIDTH = TerminalWidth.SMALL;
      }
      if (screenSize.height > 900) {
        TerminalStyle.TERMINAL_HEIGHT = TerminalHeight.LARGE;
      } else {
        TerminalStyle.TERMINAL_HEIGHT = TerminalHeight.SMALL;
      }
    });
  }

  static const TOP_BAR_HEIGHT = 100.0;
  static const VERTICAL_PADDING = 40.0;

  double getTerminalSizeYMobile() {
    final viewInsets = EdgeInsets.fromWindowPadding(
        WidgetsBinding.instance.window.viewInsets,
        WidgetsBinding.instance.window.devicePixelRatio);
    return MediaQuery.of(context).size.height - // full height
        MediaQuery.of(context).padding.top - // top navigator bar
        MediaQuery.of(context).padding.bottom - // bottom navigator bar
        viewInsets.bottom - // keyboard height
        TOP_BAR_HEIGHT - // top bar
        2 * VERTICAL_PADDING; // a bit of spacing
  }

  /// Called when terminal is created or window is resized
  Size getTerminalSize() {
    double width =
        TerminalStyle.TERMINAL_WIDTH == TerminalWidth.SMALL ? 350.0 : 800.0;
    double height = TerminalStyle.IS_MOBILE ||
            TerminalStyle.TERMINAL_HEIGHT == TerminalHeight.SMALL
        ? getTerminalSizeYMobile()
        : 700.0;
    return Size(width, height);
  }

  bool _isFirstOpenedWindow = true;

  /// Called when terminal is created or window is resized
  Point<double> getTerminalPosition([Point<double>? original]) {
    double posX = 0.0;
    double posY = TOP_BAR_HEIGHT / 2;
    if (original == null &&
        TerminalStyle.TERMINAL_WIDTH == TerminalWidth.LARGE_2X) {
      Size size = getTerminalSize();
      posX = size.width / 2 +
          (MediaQuery.of(context).size.width - 2 * size.width) / 6;
      if (_isFirstOpenedWindow) {
        _isFirstOpenedWindow = false;
        posX = -posX;
      }
    }
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

  static final launchButtonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.grey[850]),
    overlayColor: MaterialStateProperty.all(Colors.white12),
    padding:
        MaterialStateProperty.all(EdgeInsets.fromLTRB(15.0, 17.0, 15.0, 17.0)),
    shape: MaterialStateProperty.all(RoundedRectangleBorder(
        side: BorderSide(color: Colors.white54, width: 2.0),
        borderRadius: BorderRadius.circular(10.0))),
  );

  Widget _buildLaunchButton(
          {required String image,
          required String label,
          required void Function() onTap}) =>
      TextButton(
        onPressed: onTap,
        style: launchButtonStyle,
        child: Row(children: [
          SvgPicture.asset(image, height: 30.0, width: 30.0),
          Container(width: 15.0, height: 0.0),
          Text(label,
              textAlign: TextAlign.center,
              style: TerminalStyle.monospaced(
                  fontSize: 16.0, fontWeight: FontWeight.bold))
        ]),
      );

  Widget _buildTopBarProfile() => Row(children: [
        Container(
            margin: EdgeInsets.fromLTRB(0.0, 10.0, 8.0, 10.0),
            width: 5.0,
            color: Colors.white54),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text('Diego Royo Meneses',
                style: TerminalStyle.monospaced(fontWeight: FontWeight.bold)),
            Container(height: 5.0),
            Text(
                TerminalStyle.TERMINAL_WIDTH == TerminalWidth.SMALL
                    ? 'Personal website'
                    : 'Researcher, tinkerer, developer',
                style: TerminalStyle.monospaced(fontStyle: FontStyle.italic)),
          ],
        )
      ]);

  /// Small wrapper to close menu and execute another thing
  void _closeMenu(void Function() then) {
    setState(() => isMenuOpen = false);
    then();
  }

  List<Widget> _buildTopBarButtons() => [
        _buildLaunchButton(
            image: TerminalAssets.ICON_PROJECTS,
            label: 'Personal projects',
            onTap: () => _closeMenu(() => setState(() => openWindow(terminal(
                title: 'Projects', initialCommands: ['cat projects.txt']))))),
        Container(width: 22.0),
        _buildLaunchButton(
            image: TerminalAssets.ICON_CV,
            label: 'Curriculum Vitae',
            onTap: () =>
                _closeMenu(() => openUrl(addBaseUrl(TerminalAssets.PDF_CV)))),
        Container(width: 22.0),
        _buildLaunchButton(
            image: TerminalAssets.ICON_PUBLICATIONS,
            label: 'Publications',
            onTap: () => _closeMenu(() => setState(() => openWindow(terminal(
                title: 'Publications',
                initialCommands: ['cat publications.txt']))))),
        Container(width: 22.0),
        _buildLaunchButton(
            image: TerminalAssets.ICON_NEWS,
            label: 'Recent news',
            onTap: () => _closeMenu(() => setState(() => openWindow(
                terminal(title: 'News', initialCommands: ['cat news.txt']))))),
        Container(width: 22.0),
        _buildLaunchButton(
            image: TerminalAssets.ICON_TERMINAL,
            label: 'Terminal',
            onTap: () => _closeMenu(() => setState(() => openWindow(
                terminal(title: 'Terminal', initialCommands: ['help']))))),
        Container(width: 22.0),
        _buildLaunchButton(
            image: TerminalAssets.ICON_CONTACT,
            label: 'Contact',
            onTap: () => _closeMenu(() => setState(() => openWindow(
                terminal(title: 'Contact', initialCommands: ['neofetch']))))),
      ];

  Widget _buildTopBarButtonsWide() => Row(children: _buildTopBarButtons());

  bool isMenuOpen = false;

  Widget _buildTopBarButtonsSmall() =>
      Stack(clipBehavior: Clip.none, children: [
        TextButton(
          onPressed: () => setState(() => isMenuOpen = !isMenuOpen),
          style: launchButtonStyle,
          child: Icon(
            Icons.menu,
            size: 25.0,
            color: Colors.white,
          ),
        ),
        Positioned(
          right: 0,
          top: 45,
          child: (isMenuOpen && TerminalStyle.IS_WIDE)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _buildTopBarButtons()
                      .map((e) => Container(
                          margin: EdgeInsets.only(top: 6.0),
                          child: DeferPointer(paintOnTop: true, child: e)))
                      .toList(),
                )
              : Container(),
        )
      ]);

  Widget _buildTopBar() => Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
          width: double.infinity,
          height: TOP_BAR_HEIGHT,
          child: Container(
              margin: EdgeInsets.all(15.0),
              child: Material(
                  color: Colors.transparent,
                  elevation: 15.0,
                  borderRadius: BorderRadius.circular(5.0),
                  child: Container(
                      width: TerminalStyle.IS_WIDE ? 360 : 550,
                      height: TerminalStyle.IS_WIDE ? 570 : 440,
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      decoration: BoxDecoration(
                          color: HOME_COLOR,
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Row(
                        children: [
                          _buildTopBarProfile(),
                          Expanded(child: SizedBox.shrink()),
                          TerminalStyle.IS_WIDE
                              ? _buildTopBarButtonsSmall()
                              : _buildTopBarButtonsWide(),
                        ],
                      ))))));

  Widget _buildDesktopContents() => Indexer(
        clipBehavior: Clip.none,
        children: [Indexed(index: 0, child: _buildTopBar())]..addAll(windows
            .asMap()
            .entries
            .map<Widget>((entry) => Indexed(
                index: windowIndex[entry.key],
                child: Positioned.fill(child: entry.value)))
            .toList()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: DeferredPointerHandler(
            child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage(TerminalAssets.BACKGROUND_IMAGE),
            fit: BoxFit.cover,
          )),
          child: SafeArea(child: _buildDesktopContents()),
        )));
  }
}
