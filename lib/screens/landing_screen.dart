import 'package:flutter/material.dart';
import 'package:terminal/include/assets.dart';
import 'package:terminal/widgets/floating_window.dart';

/// Pantalla de carga inicial con el logo de Miora
class LandingScreen extends StatefulWidget {
  LandingScreen();

  @override
  _LandingScreenState createState() => new _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    // _awaitForFirebase().then((_) {
    //   MioraLocation.updateUserLocation(context).then((_) => _checkForToken());
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage(TerminalAssets.BACKGROUND_IMAGE),
        fit: BoxFit.cover,
      )),
      child: SafeArea(
          child: FloatingWindow(
        title: 'About me',
        width: 500,
        height: 400,
        child: Text('hola', style: TextStyle(color: Colors.white)),
      )),
    );
  }
}
