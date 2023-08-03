import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/foundation.dart';

enum TerminalWidth { LARGE_2X, LARGE, SMALL }

enum TerminalHeight { LARGE, SMALL }

class TerminalStyle {
  /// Needed for different behaviours
  /// (mostly: mobile devices have on-screen keyboard which takes up space)
  // ignore: non_constant_identifier_names
  static final IS_MOBILE = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  /// initial value, can be updated by main thread
  // ignore: non_constant_identifier_names
  static TerminalWidth TERMINAL_WIDTH = TerminalWidth.LARGE_2X;
  // ignore: non_constant_identifier_names
  static TerminalHeight TERMINAL_HEIGHT = TerminalHeight.LARGE;

  static const DEFAULT_FONTSIZE = 16.0;
  static const DEFAULT_FONTCOLOR = Colors.white;
  static const DEFAULT_FONTWEIGHT = FontWeight.normal;
  static const DEFAULT_FONTSTYLE = FontStyle.normal;
  static const MONOSPACED_FONT = 'JuliaMono';

  static TextStyle monospaced(
      {double fontSize = DEFAULT_FONTSIZE,
      Color color = DEFAULT_FONTCOLOR,
      FontWeight fontWeight = DEFAULT_FONTWEIGHT,
      FontStyle fontStyle = DEFAULT_FONTSTYLE,
      TextDecoration? decoration}) {
    return TextStyle(
      fontFamily: MONOSPACED_FONT,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static Style htmlMonospaced(
          {double fontSize = DEFAULT_FONTSIZE,
          Color color = DEFAULT_FONTCOLOR,
          EdgeInsets margin = EdgeInsets.zero,
          Color backgroundColor = Colors.transparent,
          VerticalAlign verticalAlign = VerticalAlign.BASELINE,
          FontWeight fontWeight = DEFAULT_FONTWEIGHT}) =>
      Style(
          margin: margin,
          padding: EdgeInsets.zero,
          fontSize: FontSize(fontSize),
          backgroundColor: backgroundColor,
          color: color,
          verticalAlign: verticalAlign,
          fontFamily: MONOSPACED_FONT,
          fontWeight: fontWeight);

  // ignore: non_constant_identifier_names
  static final Map<String, Style> HTML_MONOSPACED = {
    'body': Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
    'table': Style(display: Display.INLINE),
    'td': Style(display: Display.INLINE_BLOCK),
    'li': htmlMonospaced(),
    'hr': Style(
        backgroundColor: Colors.white, margin: EdgeInsets.only(bottom: 12.0)),
    'p': htmlMonospaced(),
    'a': htmlMonospaced(color: Colors.lightBlue[100]!),
    'pre': htmlMonospaced(),
    'span': htmlMonospaced(color: Color(0xFFFD3762)),
    'ul > p': htmlMonospaced(margin: EdgeInsets.only(bottom: 10.0)),
    'ul > p > span': htmlMonospaced(verticalAlign: VerticalAlign.SUPER),
  };
}
