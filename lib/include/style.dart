import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/foundation.dart';

class TerminalStyle {
  // ignore: non_constant_identifier_names
  static final IS_MOBILE = kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  /// initial value, can be updated by main thread
  // ignore: non_constant_identifier_names
  static var IS_VERTICAL = IS_MOBILE;

  static const DEFAULT_FONTSIZE = 16.0;
  static const DEFAULT_FONTCOLOR = Colors.white;
  static const DEFAULT_FONTWEIGHT = FontWeight.normal;
  static const MONOSPACED_FONT = 'JuliaMono';

  static TextStyle monospaced(
      {double fontSize = DEFAULT_FONTSIZE,
      Color color = DEFAULT_FONTCOLOR,
      FontWeight fontWeight = DEFAULT_FONTWEIGHT}) {
    return TextStyle(
      fontFamily: MONOSPACED_FONT,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }

  static Style htmlMonospaced(
          {double fontSize = DEFAULT_FONTSIZE,
          Color color = DEFAULT_FONTCOLOR,
          FontWeight fontWeight = DEFAULT_FONTWEIGHT}) =>
      Style(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          fontSize: FontSize(fontSize),
          color: color,
          fontFamily: MONOSPACED_FONT,
          fontWeight: fontWeight);

  // ignore: non_constant_identifier_names
  static final Map<String, Style> HTML_MONOSPACED = {
    'body': Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
    'p': htmlMonospaced(),
    'pre': htmlMonospaced(),
    'span': htmlMonospaced(color: Colors.red)
  };
}
