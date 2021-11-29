import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:terminal/include/assets.dart';
import 'package:terminal/include/style.dart';
import 'package:terminal/util/html.dart';
import 'package:terminal/widgets/buttons/animated_elevated_button.dart';

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

  SocialButton.twitter({String? link})
      : this(
            color: Color(0xFF00ACEE),
            icon: FeatherIcons.twitter,
            text: 'Twitter',
            onPressed: () => openUrl(link ?? TerminalAssets.URL_TWITTER));

  SocialButton.linkedin()
      : this(
            color: Color(0xFF0E76A8),
            icon: FeatherIcons.linkedin,
            text: 'LinkedIn',
            onPressed: () => openUrl(TerminalAssets.URL_LINKEDIN));

  SocialButton.github({String? link})
      : this(
            color: Color(0xFF171515),
            icon: FeatherIcons.github,
            text: 'GitHub',
            onPressed: () => openUrl(link ?? TerminalAssets.URL_GITHUB));

  SocialButton.gplay({String? link})
      : this(
            color: Color(0xFF1D7C48),
            icon: FeatherIcons.link,
            text: 'Google Play',
            onPressed: () => openUrl(link ?? TerminalAssets.URL_GITHUB));

  SocialButton.apple({String? link})
      : this(
            color: Color(0xFF3C3C3C),
            icon: FeatherIcons.link,
            text: 'Apple Store',
            onPressed: () => openUrl(link ?? TerminalAssets.URL_GITHUB));

  SocialButton.windows({required bool? download, required String link})
      : this(
            color: Color(0xFF01A6F0),
            icon: download == true ? FeatherIcons.download : FeatherIcons.link,
            text: 'Windows',
            onPressed: () => openUrl(link));

  SocialButton.linux({required bool? download, required String link})
      : this(
            color: Color(0xFF333333),
            icon: download == true ? FeatherIcons.download : FeatherIcons.link,
            text: 'Linux',
            onPressed: () => openUrl(link));

  SocialButton.pypi({required bool? download, required String link})
      : this(
            color: Color(0xFF006DAD),
            icon: download == true ? FeatherIcons.download : FeatherIcons.link,
            text: 'PyPI',
            onPressed: () => openUrl(link));

  SocialButton.youtube({required String link})
      : this(
            color: Color(0xFFFF0000),
            icon: FeatherIcons.youtube,
            text: 'YouTube',
            onPressed: () => openUrl(link));

  SocialButton.link(
      {required bool? download, required String text, required String link})
      : this(
            color: Color(0xFF222222),
            icon: download == true ? FeatherIcons.download : FeatherIcons.link,
            text: text,
            onPressed: () => openUrl(link));

  @override
  Widget build(BuildContext context) => AnimatedElevatedButton(
      color: color,
      style: ElevatedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          side: BorderSide(color: Colors.white24, width: 2.0),
          primary: color,
          padding: EdgeInsets.symmetric(horizontal: 8.0)),
      maxElevation: 5.0,
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
