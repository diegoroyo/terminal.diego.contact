import 'package:flutter/material.dart';
import 'package:terminal/routes.dart';
import 'package:url_strategy/url_strategy.dart';

void main() => runApp(TerminalApp());

class TerminalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    setPathUrlStrategy();
    WidgetsFlutterBinding.ensureInitialized();
    return MaterialApp(
      title: 'Diego Royo Meneses',
      initialRoute: '/',
      onGenerateRoute: Routes.getRoute,
      debugShowCheckedModeBanner: false,
      supportedLocales: [Locale('en')],
    );
  }
}
