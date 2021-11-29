import 'package:flutter/material.dart';

class AnimatedElevatedButton extends StatefulWidget {
  final Color color;
  final ButtonStyle style;
  final void Function() onPressed;
  final double maxElevation;
  final Duration duration;
  final Curve curve;
  final Widget child;

  const AnimatedElevatedButton(
      {Key? key,
      required this.color,
      required this.style,
      required this.onPressed,
      required this.maxElevation,
      required this.child,
      this.curve = Curves.linear,
      this.duration = const Duration(milliseconds: 150)})
      : super(key: key);

  @override
  _AnimatedElevatedButtonState createState() =>
      _AnimatedElevatedButtonState(maxElevation);
}

class _AnimatedElevatedButtonState extends State<AnimatedElevatedButton> {
  double currentElevation;

  _AnimatedElevatedButtonState(this.currentElevation);

  void setElevation(double newElevation) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() => currentElevation = newElevation);
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
      duration: widget.duration,
      curve: widget.curve,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.0),
        boxShadow: [
          BoxShadow(
              color:
                  Color.alphaBlend(widget.color.withAlpha(200), Colors.black54),
              offset: Offset(0.0, currentElevation),
              spreadRadius: 0.0,
              blurRadius: 0.0)
        ],
      ),
      margin: EdgeInsets.only(
          top: widget.maxElevation - currentElevation,
          bottom: currentElevation),
      child: ElevatedButton(
          style: widget.style.copyWith(elevation:
              MaterialStateProperty.resolveWith<double>(
                  (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.focused) ||
                states.contains(MaterialState.pressed)) {
              setElevation(0.0);
            } else {
              setElevation(widget.maxElevation);
            }
            return 0.0;
          })),
          onPressed: widget.onPressed,
          child: widget.child));
}
