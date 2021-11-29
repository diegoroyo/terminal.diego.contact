import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:terminal/include/style.dart';

class ElevatedText extends StatelessWidget {
  final String text;
  final Color backgroundColor;

  ElevatedText({Key? key, required this.text, required this.backgroundColor})
      : super(key: key);

  ElevatedText.fromContext({Key? key, required RenderContext context})
      : this(
            key: key,
            text: context.tree.element!.attributes['text']!,
            backgroundColor: Colors.grey[350]!);

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 12.0),
      padding: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
                blurRadius: 0.0,
                color: Color.alphaBlend(Colors.black45, backgroundColor),
                offset: Offset(0.0, 3.0))
          ]),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TerminalStyle.monospaced(
            fontSize: 17.0, color: Colors.black, fontWeight: FontWeight.bold),
      ));
}
