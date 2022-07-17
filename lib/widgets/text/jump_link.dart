import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:terminal/include/style.dart';
import 'package:popover/popover.dart';
import 'package:terminal/util/html.dart';

class JumpLink extends StatelessWidget {
  final String text, link;
  final TextStyle textStyle;

  static String _getLink(String link) {
    assert(link.startsWith('/')); // local link
    if (link.startsWith('/')) {
      // relative
      return addBaseUrl(link);
    } else {
      // absolute (i hope)
      return link;
    }
  }

  JumpLink(
      {Key? key,
      required this.text,
      required this.link,
      required this.textStyle})
      : super(key: key);

  JumpLink.fromContext({Key? key, required RenderContext context})
      : this(
            key: key,
            text: context.tree.element!.attributes['text']!,
            link: _getLink(context.tree.element!.attributes['href']!),
            textStyle: TerminalStyle.monospaced(
                fontSize: 20.0, fontWeight: FontWeight.bold));

  @override
  Widget build(BuildContext context) => MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: link));
            showPopover(
                context: context,
                transitionDuration: const Duration(milliseconds: 100),
                bodyBuilder: (context) => Center(
                    child: Text('Copied link!',
                        style: TerminalStyle.monospaced())),
                direction: TerminalStyle.IS_VERTICAL
                    ? PopoverDirection.top
                    : PopoverDirection.left,
                backgroundColor: Colors.green[700]!,
                barrierDismissible: false,
                barrierColor: Colors.transparent,
                width: 140,
                height: 25,
                arrowDyOffset: 0.0,
                arrowHeight: 10,
                arrowWidth: 12);
            Future.delayed(Duration(seconds: 1)).then((_) {
              Navigator.of(context).pop();
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 2.0),
                  child:
                      Icon(FeatherIcons.link, color: Colors.white, size: 23.0)),
              Expanded(
                  child: Text(
                text,
                style: textStyle,
                maxLines: 2,
              ))
            ],
          )));
}
