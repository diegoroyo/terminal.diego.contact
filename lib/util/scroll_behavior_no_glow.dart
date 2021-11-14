import 'package:flutter/material.dart';

// Remove scroll glow on after edge pressing
// https://stackoverflow.com/questions/58645048/how-to-remove-overscroll-on-ios
class ScrollBehaviorNoGlow extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      ClampingScrollPhysics();

  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
