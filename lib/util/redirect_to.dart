import 'package:flutter/material.dart';

/// The most equivalent thing to 301 redirect i could find
class Redirect extends StatefulWidget {
  final String to;

  Redirect({required this.to});

  @override
  State<StatefulWidget> createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback(doRedirect);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void doRedirect(_) {
    Navigator.of(context).popAndPushNamed(widget.to);
  }
}
