import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:terminal/include/cat_files.dart';
import 'package:terminal/include/style.dart';
import 'package:terminal/util/html.dart';
import 'package:terminal/widgets/buttons/social_button.dart';

dynamic _getPositionalArg(
    {required List<String> args,
    required int pos,
    required dynamic Function(String) parse,
    required dynamic defaultValue}) {
  int j = 0;
  for (int i = 0; i < args.length; i++) {
    if (args[i].startsWith('-')) {
      i += 1;
    } else {
      if (pos == j) {
        try {
          return parse(args[i]);
        } catch (_) {
          return defaultValue;
        }
      }
      j += 1;
    }
  }
  return defaultValue;
}

dynamic _getNamedArg(
    {required List<String> args,
    required String name,
    required dynamic Function(String) parse,
    required dynamic defaultValue}) {
  var index = args.indexOf(name);
  if (index == -1 || index == args.length - 1) {
    return defaultValue;
  } else {
    try {
      return parse(args[index + 1]);
    } catch (_) {
      return defaultValue;
    }
  }
}

abstract class Command extends StatefulWidget {
  final List<String> args;

  const Command._({Key? key, required this.args}) : super(key: key);
}

class TextCommand extends Command {
  final String text;

  const TextCommand._(
      {Key? key, required List<String> args, required this.text})
      : super._(key: key, args: args);

  static TextCommand create(List<String> args, {required String text}) =>
      TextCommand._(args: args, text: text);

  @override
  _TextCommandState createState() => _TextCommandState();
}

class _TextCommandState extends State<TextCommand> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.text, style: TerminalStyle.monospaced());
  }
}

class CatCommand extends Command {
  const CatCommand._({Key? key, required List<String> args})
      : super._(key: key, args: args);

  static CatCommand create(List<String> args) => CatCommand._(args: args);

  @override
  _CatCommandState createState() => _CatCommandState(args);
}

class _CatCommandState extends State<CatCommand> {
  final Map<String, Widget Function(RenderContext, Widget)> customRender = {
    'selectable': (context, widget) => SelectableText(
        context.tree.element!.text,
        style: TerminalStyle.monospaced()),
    'twitter': (content, widget) => SocialButton.twitter(),
    'linkedin': (content, widget) => SocialButton.linkedin(),
    'github': (content, widget) => SocialButton.github(),
  };

  final String? command, filename;
  final int numLines;
  String htmlData = '';

  _CatCommandState(List<String> args)
      : command = _getPositionalArg(
            args: args, pos: 0, parse: (e) => e, defaultValue: null),
        filename = _getPositionalArg(
            args: args, pos: 1, parse: (e) => e, defaultValue: null),
        numLines = _getNamedArg(
            args: args, name: '-n', parse: int.parse, defaultValue: -1);

  @override
  void initState() {
    super.initState();
    CatFiles.read(command: command, filename: filename, numLines: numLines)
        .then((data) {
      setState(() => htmlData = data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Html(
      customRender: customRender,
      style: TerminalStyle.HTML_MONOSPACED,
      data: htmlData,
      tagsList: Html.tags..addAll(customRender.keys),
      onLinkTap: (url, context, attributes, element) {
        if (url != null) {
          openUrl(url);
        }
      },
    );
  }
}
