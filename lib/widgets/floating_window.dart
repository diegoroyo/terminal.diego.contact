import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:terminal/include/assets.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:hovering/hovering.dart';

class FloatingWindow extends StatefulWidget {
  final String title;
  final double width, height;
  final Widget child;
  final void Function(FloatingWindow) onClosed, requestFocus;
  final double initialPosX, initialPosY;

  FloatingWindow(
      {Key? key,
      this.title = '',
      required this.child,
      required this.width,
      required this.height,
      required this.initialPosX,
      required this.initialPosY,
      required this.requestFocus,
      required this.onClosed})
      : super(key: key);

  @override
  _FloatingWindowState createState() =>
      _FloatingWindowState(initialPosX, initialPosY);
}

class _FloatingWindowState extends State<FloatingWindow> {
  static const BACKGROUND_COLOR = Color(0xFF1D1F28); // rgb 29, 31, 40
  static const TOPBAR_COLOR = Color(0xFF282A36);
  static const TOPBAR_TEXTSTYLE = TextStyle(
      color: Colors.white,
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'JuliaMono');

  _FloatingWindowState(this.posX, this.posY);

  Vector3 speed = Vector3(0.0, 0.0, 0.0);
  double posX, posY;
  bool closed = false;

  Widget _buildTopBarIcon(
      {required String image,
      required double iconScale,
      required void Function() onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: HoverCrossFadeWidget(
            duration: Duration(milliseconds: 300),
            firstChild: Image.asset(
              image,
              height: 25.6 * iconScale,
              width: 30.0 * iconScale,
              filterQuality: FilterQuality.medium,
            ),
            secondChild: Image.asset(
              image,
              height: 25.6 * iconScale,
              width: 30.0 * iconScale,
              filterQuality: FilterQuality.medium,
              color: Colors.white70,
              colorBlendMode: BlendMode.modulate,
            )));
  }

  Widget _buildTopBar() {
    const topBarHorizontalPadding = 15.0;
    const iconScale = 0.5;
    return DefaultTextStyle(
        style: TOPBAR_TEXTSTYLE,
        child: Container(
            color: TOPBAR_COLOR,
            padding: EdgeInsets.symmetric(
                horizontal: topBarHorizontalPadding, vertical: 6.0),
            child: SizedBox(
                width: closed ? 0 : widget.width - 2 * topBarHorizontalPadding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Spacer(),
                    Text(widget.title),
                    Spacer(),
                    _buildTopBarIcon(
                        image: TerminalAssets.ICON_MIMINIZE,
                        iconScale: iconScale,
                        onTap: () => setState(() => closed = true)),
                    Container(width: 8.0),
                    _buildTopBarIcon(
                        image: TerminalAssets.ICON_MAXIMIZE,
                        iconScale: iconScale,
                        onTap: () => setState(() => closed = true)),
                    Container(width: 8.0),
                    _buildTopBarIcon(
                        image: TerminalAssets.ICON_CLOSE,
                        iconScale: iconScale,
                        onTap: () => setState(() => closed = true)),
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = 8.0;
    final deformMatrix = Matrix4.translationValues(widget.width / 2.0, 0.0, 0.0)
      ..multiply(Matrix4.skewY(speed.y / 30.0))
      ..translate(-widget.width / 2.0)
      ..multiply(Matrix4.skewX(speed.x / 50.0));
    return UnconstrainedBox(
        child: Container(
            transform: Matrix4.translationValues(posX, posY, 0.0),
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanDown: (_) => widget.requestFocus(widget),
                child: Container(
                    transform: deformMatrix,
                    decoration: BoxDecoration(
                        color: BACKGROUND_COLOR.withAlpha(120),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 8.0,
                            spreadRadius: 5.0,
                          )
                        ],
                        borderRadius: BorderRadius.circular(borderRadius)),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: Column(children: [
                          GestureDetector(
                              onPanUpdate: (dragDetails) => setState(() {
                                    var delta = Vector3(dragDetails.delta.dx,
                                        dragDetails.delta.dy, 0.0);
                                    posX += delta.x;
                                    posY += delta.y;
                                    speed += delta * 0.4;
                                    speed.clamp(Vector3(-15.0, -15.0, 0.0),
                                        Vector3(15.0, 15.0, 0.0));
                                    speed *= 0.9;
                                  }),
                              onPanEnd: (dragDetails) => setState(() {
                                    speed = Vector3(0.0, 0.0, 0.0);
                                  }),
                              child: _buildTopBar()),
                          ClipRRect(
                              child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 10.0,
                                      sigmaY: 10.0,
                                      tileMode: TileMode.repeated),
                                  child: AnimatedContainer(
                                      duration: Duration(milliseconds: 100),
                                      onEnd: () => widget.onClosed(widget),
                                      width: closed ? 0 : widget.width,
                                      height: closed ? 0 : widget.height,
                                      child: widget.child))),
                        ]))))));
  }
}
