import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:terminal/include/style.dart';
import 'package:terminal/util/html.dart';
import 'package:terminal/util/window_callbacks.dart';
import 'package:terminal/widgets/buttons/project_button.dart';
import 'package:terminal/widgets/buttons/social_button.dart';
import 'package:terminal/widgets/images/caption_image.dart';
import 'package:terminal/widgets/images/cover_image.dart';
import 'package:terminal/widgets/images/screenshot_image.dart';
import 'package:terminal/widgets/text/elevated_text.dart';

class HtmlViewer extends StatefulWidget {
  final Color color;
  final String data;
  final WindowCallbacks windowCallbacks;

  const HtmlViewer(
      {Key? key,
      required this.data,
      required this.windowCallbacks,
      this.color = Colors.transparent})
      : super(key: key);

  @override
  _HtmlViewerState createState() => _HtmlViewerState();
}

class _HtmlViewerState extends State<HtmlViewer> {
  Map<String, Widget Function(RenderContext, Widget)>? customRender;

  String? getAttr(RenderContext context, String name) =>
      context.tree.element!.attributes[name];

  Widget wrap(RenderContext context, Widget widget) => SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runSpacing: 10.0,
        children: (widget as ContainerSpan)
            .children!
            .where((e) => e is WidgetSpan)
            .map((e) => (e as WidgetSpan).child)
            .toList(),
      ));

  bool? parseBool(String? string) {
    if (string == null) {
      return null;
    }
    return string.trim().toLowerCase() == 'true';
  }

  @override
  void initState() {
    super.initState();

    customRender = {
      'selectable': (context, _) => SelectableText(context.tree.element!.text,
          style: TerminalStyle.monospaced()),
      'twitter': (context, _) =>
          SocialButton.twitter(link: getAttr(context, 'link')),
      'linkedin': (_, __) => SocialButton.linkedin(),
      'github': (context, _) =>
          SocialButton.github(link: getAttr(context, 'link')),
      'gplay': (context, _) =>
          SocialButton.gplay(link: getAttr(context, 'link')),
      'apple': (context, _) =>
          SocialButton.apple(link: getAttr(context, 'link')),
      'windows': (context, _) => SocialButton.windows(
          download: parseBool(getAttr(context, 'download')),
          link: getAttr(context, 'link')!),
      'linux': (context, _) => SocialButton.linux(
          download: parseBool(getAttr(context, 'download')),
          link: getAttr(context, 'link')!),
      'youtube': (context, _) =>
          SocialButton.youtube(link: getAttr(context, 'link')!),
      'pypi': (context, _) => SocialButton.pypi(
          download: parseBool(getAttr(context, 'download')),
          link: getAttr(context, 'link')!),
      'link': (context, _) => SocialButton.link(
          download: parseBool(getAttr(context, 'download')),
          text: getAttr(context, 'text')!,
          link: getAttr(context, 'link')!),
      'project': (context, _) => ProjectButton.fromContext(
          context: context, windowCallbacks: widget.windowCallbacks),
      'elevated': (context, _) => ElevatedText.fromContext(context: context),
      'cover': (context, _) => CoverImage.fromContext(context: context),
      'icaption': (context, _) => CaptionImage.fromContext(context: context),
      'screenshot': (context, _) =>
          ScreenshotImage.fromContext(context: context),
      'wrap': (context, widget) => wrap(context, widget),
    };
  }

  @override
  Widget build(BuildContext context) => Container(
      color: widget.color,
      child: Html(
        customRender: customRender!,
        style: TerminalStyle.HTML_MONOSPACED,
        data: widget.data,
        tagsList: Html.tags..addAll(customRender!.keys),
        onLinkTap: (url, context, attributes, element) {
          if (url != null) {
            openUrl(url);
          }
        },
      ));
}
