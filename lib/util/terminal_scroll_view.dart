import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:terminal/util/scroll_behavior_no_glow.dart';

class TerminalScrollView extends StatelessWidget {
  final ScrollController controller;
  final Widget child;

  TerminalScrollView(
      {Key? key, ScrollController? controller, required this.child})
      : controller = controller ?? ScrollController(),
        super(key: key);

  @override
  Widget build(BuildContext context) => RawScrollbar(
      thumbColor: Colors.white12,
      controller: controller,
      isAlwaysShown: true,
      thickness: 7.0,
      radius: Radius.circular(20.0),
      child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ScrollConfiguration(
              behavior: ScrollBehaviorNoGlow(),
              child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  controller: controller,
                  dragStartBehavior: DragStartBehavior.down,
                  child: child))));
}
