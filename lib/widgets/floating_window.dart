import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:terminal/include/assets.dart';
import 'package:terminal/util/window_callbacks.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:hovering/hovering.dart';

class FloatingWindow extends StatefulWidget {
  final String title;
  final Size Function() getSize;
  final Point<double> Function(Point<double>?) getPosition;
  final bool movable;
  final Widget child;
  final WindowCallbacks windowCallbacks;

  FloatingWindow(
      {Key? key,
      this.title = '',
      required this.child,
      required this.getSize,
      required this.getPosition,
      required this.movable,
      required this.windowCallbacks})
      : super(key: key);

  @override
  _FloatingWindowState createState() =>
      _FloatingWindowState(size: getSize(), position: getPosition(null));
}

class _FloatingWindowState extends State<FloatingWindow>
    with WidgetsBindingObserver {
  static const BACKGROUND_COLOR = Color(0xFF1D1F28); // rgb 29, 31, 40
  static const TOPBAR_COLOR = Color(0xFF282A36);
  static const TOPBAR_TEXTSTYLE = TextStyle(
      color: Colors.white,
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'JuliaMono');

  Vector3 speed = Vector3(0.0, 0.0, 0.0);
  bool closed = true;

  Point<double> position;
  Size size;

  _FloatingWindowState({required this.size, required this.position});

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => closed = false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {
      size = widget.getSize();
      position = widget.getPosition(position);
    });
  }

  Widget _buildTopBarIcon(
      {required String image,
      required double iconScale,
      required EdgeInsets padding,
      required void Function() onTap}) {
    return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
            padding: padding,
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
                ))));
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
                width: closed ? 0 : size.width - 2 * topBarHorizontalPadding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                        child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    )),
                    _buildTopBarIcon(
                        image: TerminalAssets.ICON_MIMINIZE,
                        padding: EdgeInsets.fromLTRB(0.0, 5.0, 4.0, 5.0),
                        iconScale: iconScale,
                        onTap: () => setState(() => closed = true)),
                    _buildTopBarIcon(
                        image: TerminalAssets.ICON_MAXIMIZE,
                        padding: EdgeInsets.fromLTRB(4.0, 5.0, 4.0, 5.0),
                        iconScale: iconScale,
                        onTap: () => setState(() => closed = true)),
                    _buildTopBarIcon(
                        image: TerminalAssets.ICON_CLOSE,
                        padding: EdgeInsets.fromLTRB(4.0, 5.0, 0.0, 5.0),
                        iconScale: iconScale,
                        onTap: () => setState(() => closed = true)),
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = 8.0;
    final deformMatrix = Matrix4.translationValues(size.width / 2.0, 0.0, 0.0)
      ..multiply(Matrix4.skewY(speed.y / 30.0))
      ..translate(-size.width / 2.0)
      ..multiply(Matrix4.skewX(speed.x / 50.0));
    return UnconstrainedBox(
        child: Container(
            transform: Matrix4.translationValues(position.x, position.y, 0.0),
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanDown: (_) => widget.windowCallbacks.requestFocus(widget),
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
                              onPanUpdate: (dragDetails) {
                                if (!widget.movable) {
                                  return;
                                }
                                setState(() {
                                  var delta = Vector3(dragDetails.delta.dx,
                                      dragDetails.delta.dy, 0.0);
                                  position = Point<double>(position.x + delta.x,
                                      position.y + delta.y);
                                  speed += delta * 0.4;
                                  speed.clamp(Vector3(-15.0, -15.0, 0.0),
                                      Vector3(15.0, 15.0, 0.0));
                                  speed *= 0.9;
                                });
                              },
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
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      onEnd: () {
                                        if (closed) {
                                          widget.windowCallbacks
                                              .closeWindow(widget);
                                        }
                                      },
                                      width: closed ? 0 : size.width,
                                      height: closed ? 0 : size.height,
                                      child: widget.child))),
                        ]))))));
  }
}
