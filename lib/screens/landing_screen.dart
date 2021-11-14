import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:terminal/include/assets.dart';
import 'package:terminal/include/style.dart';
import 'package:terminal/widgets/floating_window.dart';
import 'package:terminal/widgets/terminal.dart';
import 'dart:math';

/// Pantalla de carga inicial con el logo de Miora
class LandingScreen extends StatefulWidget {
  LandingScreen();

  @override
  _LandingScreenState createState() => new _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  static const HOME_COLOR = Color(0xFF1D1F28);

  List<FloatingWindow> windows = [];
  List<int> windowIndex = [];

  @override
  void initState() {
    super.initState();

    openWindow(
      FloatingWindow(
          key: GlobalKey(),
          title: 'About me',
          width: 600,
          height: 500,
          initialPosX: 0,
          initialPosY: 0,
          child: Terminal(
            initialCommands: ['neofetch', 'head news.txt -n 2'],
          ),
          requestFocus: requestFocus,
          onClosed: closeWindow),
    );
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
      TextButton(
        onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.black12),
          overlayColor: MaterialStateProperty.all(Colors.black12),
          foregroundColor: MaterialStateProperty.all(Colors.black12),
          padding: MaterialStateProperty.all(EdgeInsets.all(15.0)),
        ),
        child: Column(children: [
          SvgPicture.asset(image, height: 60.0, width: 60.0),
          Container(height: 5.0),
          Text(label,
              style: TerminalStyle.monospaced(
                  fontSize: 16.0, fontWeight: FontWeight.bold))
        ]),
      );

  Widget _buildCenter() => Material(
      color: Colors.transparent,
      elevation: 15.0,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
          width: 550,
          height: 300,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLaunchButton(
                      image: TerminalAssets.ICON_PROJECTS,
                      label: 'Projects',
                      onTap: () => setState(() => openWindow(FloatingWindow(
                          key: GlobalKey(),
                          title: 'Projects',
                          width: 600,
                          height: 500,
                          initialPosX: 0,
                          initialPosY: 0,
                          child: Terminal(
                            initialCommands: [
                              'cat projects.txt',
                            ],
                          ),
                          requestFocus: requestFocus,
                          onClosed: closeWindow)))),
                  _buildLaunchButton(
                      image: TerminalAssets.ICON_NEWS,
                      label: 'News',
                      onTap: () => setState(() => openWindow(FloatingWindow(
                          key: GlobalKey(),
                          title: 'News',
                          width: 600,
                          height: 500,
                          initialPosX: 0,
                          initialPosY: 0,
                          child: Terminal(
                            initialCommands: [
                              'cat news.txt',
                            ],
                          ),
                          requestFocus: requestFocus,
                          onClosed: closeWindow)))),
                  _buildLaunchButton(
                      image: TerminalAssets.ICON_TERMINAL,
                      label: 'Terminal',
                      onTap: () => setState(() => openWindow(FloatingWindow(
                          key: GlobalKey(),
                          title: 'Terminal',
                          width: 600,
                          height: 500,
                          initialPosX: 0,
                          initialPosY: 0,
                          child: Terminal(
                            initialCommands: [],
                          ),
                          requestFocus: requestFocus,
                          onClosed: closeWindow)))),
                  _buildLaunchButton(
                      image: TerminalAssets.ICON_CONTACT,
                      label: 'Contact',
                      onTap: () => setState(() => openWindow(FloatingWindow(
                          key: GlobalKey(),
                          title: 'Contact',
                          width: 600,
                          height: 500,
                          initialPosX: 0,
                          initialPosY: 0,
                          child: Terminal(
                            initialCommands: ['neofetch'],
                          ),
                          requestFocus: requestFocus,
                          onClosed: closeWindow)))),
                ],
              )
            ],
          )));

  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child: Container(
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
