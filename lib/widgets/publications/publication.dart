import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:popover/popover.dart';
import 'package:terminal/include/assets.dart';
import 'package:terminal/include/style.dart';
import 'package:terminal/util/html.dart';
import 'package:terminal/util/yaml.dart';
import 'package:terminal/widgets/buttons/social_button.dart';
import 'package:terminal/widgets/images/expandable_image.dart';
import 'package:yaml/yaml.dart';

class Publication extends StatefulWidget {
  final String id;

  Publication({Key? key, required this.id});

  Publication.fromContext({Key? key, required RenderContext context})
      : this(key: key, id: context.tree.element!.attributes['id']!);

  @override
  _PublicationState createState() => _PublicationState(id);
}

class _PublicationState extends State<Publication> {
  static const TEXT_COLOR_TITLE = Colors.white;
  // ignore: non_constant_identifier_names
  static final TEXT_COLOR_BODY = Colors.grey[200]!;
  static const TEXT_COLOR_ACCENT = Colors.red;
  static const Map<String, dynamic> REMARKS_MAP = {
    'asterisk': '*',
    'mail': FeatherIcons.mail,
  };
  bool contentLoaded = false;

  YamlMap? data;
  Widget? authorsList;
  GlobalKey bibtexButtonKey = GlobalKey();

  void _loadContent(String? filename) async {
    if (filename == null) {
      print('Publication: null filename received? Check PUBLICATION_MAP');
      return;
    }
    YamlMap? yamlData = await parseYaml(TerminalAssets.readText(filename));
    if (yamlData != null) {
      Widget authorsWidget = await _generateAuthors(
          yamlData['authors'], yamlData['author-remarks']);
      setState(() {
        data = yamlData;
        authorsList = authorsWidget;
        contentLoaded = true;
      });
    }
  }

  _PublicationState(String id) {
    _loadContent(TerminalAssets.PUBLICATION_MAP[id]);
  }

  void animatePopover(
      {required GlobalKey key,
      required String text,
      required double width,
      required double height}) {
    showPopover(
        context: key.currentContext!,
        transitionDuration: const Duration(milliseconds: 100),
        bodyBuilder: (context) => Center(
            child: Text(text,
                textAlign: TextAlign.center,
                style: TerminalStyle.monospaced())),
        direction: PopoverDirection.bottom,
        backgroundColor: Colors.green[700]!,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        width: width,
        height: height,
        arrowDyOffset: 0.0,
        arrowHeight: 10,
        arrowWidth: 12);
    Future.delayed(Duration(seconds: 1)).then((_) {
      Navigator.of(context).pop();
    });
  }

  Future<Widget> _generateAuthors(
      YamlList authors, YamlList? authorRemarks) async {
    var authorWidgets = <Widget>[];
    for (int i = 0; i < authors.length; i++) {
      String authorId = authors[i];
      var author = await TerminalAssets.readAuthor(authorId);
      if (author == null) {
        print('Publication: author not found: $authorId');
        continue;
      }
      TextStyle authorStyle;
      TapGestureRecognizer? recognizer;
      if (author.containsKey('url')) {
        // hyperlink style
        authorStyle = TerminalStyle.monospaced(
            color: Colors.lightBlue[100]!,
            decoration: TextDecoration.underline);
        recognizer = TapGestureRecognizer()
          ..onTap = () => openUrl(author['url']);
      } else {
        // flat text
        authorStyle = TerminalStyle.monospaced(color: TEXT_COLOR_BODY);
      }
      var textSpans = <InlineSpan>[];
      textSpans.add(TextSpan(
          text: author['name'], style: authorStyle, recognizer: recognizer));
      var authorsWithRemark = Set<String>();
      if (authorRemarks != null) {
        for (var remark in authorRemarks) {
          if (remark.keys.first == authorId) {
            if (authorsWithRemark.contains(remark.keys.first)) {
              textSpans.add(WidgetSpan(
                  child: Transform.translate(
                      offset: Offset(0, -4),
                      child: RichText(
                          text: TextSpan(
                              text: ',',
                              style: TerminalStyle.monospaced(
                                  color: TEXT_COLOR_BODY))))));
            }
            authorsWithRemark.add(remark.keys.first);
            var remarkKey = GlobalKey();
            var icon = REMARKS_MAP[remark.values.first['icon']] ?? '?';
            void Function() onTap = () => animatePopover(
                key: remarkKey,
                text: remark.values.first['text'],
                width: 240.0,
                height: 35.0);
            Widget remarkWidget = Container();
            if (icon is String) {
              remarkWidget = RichText(
                  key: remarkKey,
                  text: TextSpan(
                      text: icon,
                      recognizer: TapGestureRecognizer()..onTap = onTap,
                      style:
                          TerminalStyle.monospaced(color: TEXT_COLOR_ACCENT)));
            } else if (icon is IconData) {
              remarkWidget = MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: onTap,
                      child: Icon(
                        icon,
                        key: remarkKey,
                        color: TEXT_COLOR_ACCENT,
                        size: TerminalStyle.DEFAULT_FONTSIZE,
                      )));
            }
            textSpans.add(WidgetSpan(
                child: Transform.translate(
                    offset: Offset(1, -4), child: remarkWidget)));
          }
        }
      }
      if (i < authors.length - 2) {
        textSpans.add(TextSpan(
            text: ', ',
            style: TerminalStyle.monospaced(color: TEXT_COLOR_BODY)));
      } else if (i == authors.length - 2) {
        textSpans.add(TextSpan(
            text: ' and ',
            style: TerminalStyle.monospaced(color: TEXT_COLOR_BODY)));
      }
      authorWidgets.add(RichText(text: TextSpan(children: textSpans)));
    }
    return Wrap(children: authorWidgets, runSpacing: 2.0);
  }

  String _parsePublished(YamlMap published) {
    var parts = <String>[];
    if (published.containsKey('name')) {
      parts.add(published['name'].toString());
    }
    if (published.containsKey('year')) {
      parts.add(published['year'].toString());
    }
    return parts.join(', ');
  }

  Widget _iconText(
          {required IconData icon,
          required Color iconColor,
          required Widget text}) =>
      Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: TerminalStyle.DEFAULT_FONTSIZE),
            Container(width: 8.0),
            Expanded(child: text),
          ]);

  IconData _getButtonIcon(String? action) {
    switch (action) {
      case 'pdf':
        return FeatherIcons.bookOpen;
      case 'redirect':
        return FeatherIcons.link;
      case 'bibtex':
        return Icons.format_quote;
      default:
        return Icons.question_mark;
    }
  }

  void _doButtonAction(String? action, String? content) {
    if (action == null || content == null) {
      return;
    }
    if (action == 'redirect') {
      openUrl(content);
    } else if (action == 'pdf') {
      assert(content.startsWith('/'));
      openUrl(addBaseUrl(content));
    } else if (action == 'bibtex') {
      Clipboard.setData(ClipboardData(text: content));
      animatePopover(
          key: bibtexButtonKey,
          text: 'Copied BibTeX!',
          width: 160.0,
          height: 35.0);
    }
  }

  Widget _buildPublication() => Container(
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.black38,
          border: Border.all(width: 2.0, color: Colors.grey[700]!)),
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
      child: Column(children: [
        Wrap(
          alignment: TerminalStyle.TERMINAL_WIDTH == TerminalWidth.SMALL
              ? WrapAlignment.center
              : WrapAlignment.start,
          runSpacing: 12.0,
          children: [
            ExpandableImage(
                size: Size(240.0, 160.0),
                image: AssetImage(
                    TerminalAssets.publicationImage(data!['image']))),
            Container(
                width: 480.0,
                child: IntrinsicHeight(
                    child: Row(children: [
                  Container(
                      margin: EdgeInsets.only(left: 10.0, right: 5.0),
                      width: 1.0,
                      color: Colors.white60),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data!['title'],
                          style: TerminalStyle.monospaced(
                              color: TEXT_COLOR_TITLE,
                              fontWeight: FontWeight.bold)),
                      Container(
                          margin: EdgeInsets.only(top: 3.0),
                          child: _iconText(
                              icon: FeatherIcons.user,
                              iconColor: TEXT_COLOR_BODY,
                              text: authorsList!)),
                      Container(
                          margin: EdgeInsets.only(top: 3.0),
                          child: _iconText(
                              icon: FeatherIcons.book,
                              iconColor: TEXT_COLOR_BODY,
                              text: Text(_parsePublished(data!['published']),
                                  style: TerminalStyle.monospaced(
                                      color: TEXT_COLOR_BODY,
                                      fontStyle: FontStyle.italic)))),
                      data!['mention'] == null
                          ? Container()
                          : Container(
                              margin: EdgeInsets.only(top: 3.0),
                              child: _iconText(
                                  icon: FeatherIcons.star,
                                  iconColor: TEXT_COLOR_ACCENT,
                                  text: Text(data!['mention'],
                                      style: TerminalStyle.monospaced(
                                          color: TEXT_COLOR_ACCENT,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic)))),
                    ],
                  ))
                ]))),
          ],
        ),
        Container(height: 10.0),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
              child: Wrap(
            spacing: 5.0,
            runSpacing: 5.0,
            children: data!['buttons']
                .map<Widget>((button) => SocialButton(
                    key: button['action'] == 'bibtex' ? bibtexButtonKey : null,
                    color: Colors.red[900]!,
                    icon: _getButtonIcon(button['action']),
                    text: button['text'],
                    onPressed: () =>
                        _doButtonAction(button['action'], button['content'])))
                .toList(),
          )),
          TerminalStyle.TERMINAL_WIDTH == TerminalWidth.SMALL
              ? Container()
              : Container(
                  margin: EdgeInsets.only(left: 20.0, right: 3.0, bottom: 8.0),
                  child: Text(data!['published']['type'],
                      style: TerminalStyle.monospaced(color: TEXT_COLOR_BODY))),
        ])
      ]));

  Widget _buildLoadingIndicator() => Container(
      width: double.infinity,
      height: 100.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0), color: Colors.black38),
      child: Center(child: CircularProgressIndicator(color: Colors.white)));

  @override
  Widget build(BuildContext context) => Container(
      margin: EdgeInsets.only(top: 7.0),
      child: contentLoaded ? _buildPublication() : _buildLoadingIndicator());
}
