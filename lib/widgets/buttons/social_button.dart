import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:terminal/include/assets.dart';
import 'package:terminal/include/style.dart';
import 'package:terminal/util/html.dart';

class SocialButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final void Function() onPressed;

  SocialButton(
      {Key? key,
      required this.color,
      required this.icon,
      required this.text,
      required this.onPressed})
      : super(key: key);

  SocialButton.twitter()
      : this(
            color: Color(0xFF00ACEE),
            icon: FeatherIcons.twitter,
            text: 'Twitter',
            onPressed: () => openUrl(TerminalAssets.URL_TWITTER));

  SocialButton.linkedin()
      : this(
            color: Color(0xFF0E76A8),
            icon: FeatherIcons.linkedin,
            text: 'LinkedIn',
            onPressed: () => openUrl(TerminalAssets.URL_LINKEDIN));

  SocialButton.github()
      : this(
            color: Color(0xFF171515),
            icon: FeatherIcons.github,
            text: 'GitHub',
            onPressed: () => openUrl(TerminalAssets.URL_GITHUB));

  @override
  Widget build(BuildContext context) => ElevatedButton(
      style: ElevatedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          side: BorderSide(color: Colors.white24, width: 2.0),
          primary: color,
          padding: EdgeInsets.symmetric(horizontal: 8.0)),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16.0),
          Container(width: 8.0),
          Text(text, style: TerminalStyle.monospaced())
        ],
      ));
}
