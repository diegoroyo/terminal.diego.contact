import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:terminal/routes.dart';

void main() => runApp(TerminalApp());

class TerminalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    // ]);
    return MaterialApp(
      title: 'Diego Royo',
      initialRoute: 'landing',
      onGenerateRoute: Routes.getRoute,
      // builder: (context, child) =>
      //     ScrollConfiguration(behavior: ScrollBehaviorNoGlow(), child: child),
      debugShowCheckedModeBanner: false,
      supportedLocales: [Locale('en')],
    );
  }
}
