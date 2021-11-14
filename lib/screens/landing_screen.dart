import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:terminal/include/assets.dart';
import 'package:terminal/include/style.dart';
import 'package:terminal/widgets/floating_window.dart';
import 'package:terminal/widgets/terminal.dart';
import 'dart:math';

class LandingScreen extends StatefulWidget {
  LandingScreen();

  @override
  _LandingScreenState createState() => new _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  static const HOME_COLOR = Color(0xFF1D1F28);

  Random random = Random();

  List<FloatingWindow> windows = [];
  List<int> windowIndex = []; // z-ordering

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      openWindow(
        terminal(
            title: 'About me',
            initialCommands: ['neofetch', 'head news.txt -n 2']),
      );
    });
  }

  FloatingWindow terminal(
          {required String title, required List<String> initialCommands}) =>
      FloatingWindow(
          key: GlobalKey(),
          title: title,
          width: TerminalStyle.IS_VERTICAL ? 350 : 600,
          height: TerminalStyle.IS_VERTICAL
              ? (TerminalStyle.IS_MOBILE ? 400 : 500)
              : 500,
          initialPosX:
              TerminalStyle.IS_VERTICAL ? 0 : random.nextInt(300) - 150,
          initialPosY: TerminalStyle.IS_VERTICAL
              ? (TerminalStyle.IS_MOBILE ? -120 : 0)
              : random.nextInt(300) - 150,
          child: Terminal(
            initialCommands: initialCommands,
          ),
          requestFocus: requestFocus,
          onClosed: closeWindow);

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
          Container(width: 0.0, height: 5.0),
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
          width: TerminalStyle.IS_VERTICAL ? 330 : 550,
          height: TerminalStyle.IS_VERTICAL ? 420 : 300,
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
                      label: 'Projects',
                      onTap: () => setState(() => openWindow(terminal(
                          title: 'Projects',
                          initialCommands: ['cat projects.txt'])))),
                  _buildLaunchButton(
                      image: TerminalAssets.ICON_NEWS,
                      label: 'News',
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
    // FIXME(diego): IS_VERTICAL is updated in each build. There should be
    // better ways to do this e.g. didChangeMetrics as seen in
    // https://github.com/flutter/flutter/issues/56832
    TerminalStyle.IS_VERTICAL = MediaQuery.of(context).size.aspectRatio < 1;
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
