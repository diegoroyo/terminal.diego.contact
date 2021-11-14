import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:terminal/routes.dart';

void main() => runApp(TerminalApp());

class TerminalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
