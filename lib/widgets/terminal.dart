import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:terminal/include/cat_files.dart';
import 'package:terminal/include/style.dart';
import 'package:terminal/util/first_disabled_focus_node.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:collection' show Queue;

import 'package:terminal/util/scroll_behavior_no_glow.dart';

/// Prompt ///

class ArrowUpIntent extends Intent {
  const ArrowUpIntent();
}

class ArrowDownIntent extends Intent {
  const ArrowDownIntent();
}

class CommandPrompt extends StatefulWidget {
  final String text;
  final void Function(String) onSubmit;
  final FocusNode _textFocusNode;
  final String? Function(int) requestCommandHistory;

  void focus() {
    _textFocusNode.requestFocus();
  }

  /// note: initial value, current value is stored in the state
  final bool active;

  CommandPrompt(
      {Key? key,
      required this.text,
      required this.onSubmit,
      required this.requestCommandHistory,
      this.active = true})
      : _textFocusNode =
            TerminalStyle.IS_MOBILE ? FirstDisabledFocusNode() : FocusNode(),
        super(key: key);

  @override
  _CommandPromptState createState() =>
      _CommandPromptState(active: active, text: text);
}

class _CommandPromptState extends State<CommandPrompt> {
  bool active;
  TextEditingController textController;
  Queue<String> lastCommandsQueue;

  _CommandPromptState({required this.active, required String text})
      : textController = TextEditingController(text: text),
        lastCommandsQueue = Queue();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(widget._textFocusNode);
    });
  }

  void onSubmitted(String result) {
    setState(() => active = false);
    widget.onSubmit(textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text('~\$', style: TerminalStyle.monospaced()),
      Container(width: 5.0),
      Expanded(
          child: Shortcuts(
              shortcuts: <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.arrowUp): ArrowUpIntent(),
            SingleActivator(LogicalKeyboardKey.arrowDown): ArrowDownIntent(),
          },
              child: Actions(
                  actions: <Type, Action<Intent>>{
                    ArrowUpIntent: CallbackAction<ArrowUpIntent>(onInvoke: (_) {
                      int idToRequest = lastCommandsQueue.length;
                      String? replaceCommand =
                          widget.requestCommandHistory(idToRequest);
                      if (replaceCommand == null) {
                        // we have reached the history limit, no more commands
                        return;
                      }
                      if (idToRequest > 0) {
                        // we need to request an old command already inputted
                        // user could have edited textController, ask history
                        // for a clean version
                        lastCommandsQueue.addLast(
                            widget.requestCommandHistory(idToRequest - 1)!);
                      } else {
                        // we store whatever the user has written,
                        // an incomplete command
                        lastCommandsQueue.addLast(textController.text);
                      }
                      setState(() {
                        textController.text = replaceCommand;
                        textController.selection = TextSelection.fromPosition(
                            TextPosition(offset: textController.text.length));
                      });
                    }),
                    ArrowDownIntent:
                        CallbackAction<ArrowDownIntent>(onInvoke: (_) {
                      if (lastCommandsQueue.isNotEmpty) {
                        String lastCommand = lastCommandsQueue.removeLast();
                        setState(() {
                          textController.text = lastCommand;
                          textController.selection = TextSelection.fromPosition(
                              TextPosition(offset: textController.text.length));
                        });
                      }
                    }),
                  },
                  child: TextField(
                    enableSuggestions: false,
                    autocorrect: false,
                    style: TerminalStyle.monospaced(),
                    keyboardType: TextInputType.emailAddress,
                    focusNode: widget._textFocusNode,
                    readOnly: !active,
                    controller: textController,
                    maxLines: 1,
                    maxLength: 40,
                    enabled: active,
                    textInputAction: TextInputAction.done,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    cursorColor: Colors.white60,
                    onSubmitted: onSubmitted,
                    showCursor: true,
                    cursorWidth: 8.0,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                        counterText: ''),
                  ))))
    ]);
  }
}

/// Commands ///

dynamic getPositionalArg(
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

dynamic getNamedArg(
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
  final String? command, filename;
  final int numLines;
  String htmlData = '';

  _CatCommandState(List<String> args)
      : command = getPositionalArg(
            args: args, pos: 0, parse: (e) => e, defaultValue: null),
        filename = getPositionalArg(
            args: args, pos: 1, parse: (e) => e, defaultValue: null),
        numLines = getNamedArg(
            args: args, name: '-n', parse: int.parse, defaultValue: -1);

  @override
  void initState() {
    super.initState();
    CatFiles.read(command: command, filename: filename, numLines: numLines)
        .then((data) {
      setState(() => htmlData = data);
    });
  }

  Widget socialButton(
          {required Color color,
          required IconData icon,
          required String text,
          required void Function() onPressed}) =>
      ElevatedButton(
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

  @override
  Widget build(BuildContext context) {
    var customRender = {
      'selectable': (context, widget) => SelectableText(
          context.tree.element!.text,
          style: TerminalStyle.monospaced()),
      'twitter': (content, widget) => socialButton(
          color: Color(0xFF00ACEE),
          icon: FeatherIcons.twitter,
          text: 'Twitter',
          onPressed: () =>
              html.window.open('https://www.twitter.com/disti150', '_blank')),
      'linkedin': (content, widget) => socialButton(
          color: Color(0xFF0E76A8),
          icon: FeatherIcons.linkedin,
          text: 'LinkedIn',
          onPressed: () => html.window
              .open('https://www.linkedin.com/in/diegorm/', '_blank')),
      'github': (content, widget) => socialButton(
          color: Color(0xFF171515),
          icon: FeatherIcons.github,
          text: 'GitHub',
          onPressed: () =>
              html.window.open('https://www.github.com/diegoroyo', '_blank')),
    };
    return Html(
      customRender: customRender,
      style: TerminalStyle.HTML_MONOSPACED,
      data: htmlData,
      tagsList: Html.tags..addAll(customRender.keys),
    );
  }
}

/// Terminal ///

class Terminal extends StatefulWidget {
  // ignore: non_constant_identifier_names
  static final Map<String, Command Function(List<String>)> COMMAND_MAP = {
    'ls': (args) {
      List<String> filenames = CatFiles.FILENAME_MAPS.keys.toList();
      filenames.sort();
      return TextCommand.create(args, text: filenames.join('  '));
    },
    'cat': (args) => CatCommand.create(args),
    'neofetch': (args) => CatCommand.create(['cat', 'neofetch.txt']),
    'head': (args) => CatCommand.create(args),
    'help': (args) {
      List<String> commands = Terminal.COMMAND_MAP.keys.toList();
      commands.sort();
      return TextCommand.create(args,
          text: 'available commands: ${commands.join("  ")}');
    }
  };
  final List<String>? initialCommands;

  const Terminal({Key? key, this.initialCommands}) : super(key: key);

  @override
  _TerminalState createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  List<Widget>? _widgets;
  Queue<String> commandHistory;
  int _knownWidgets = 0;
  ScrollController _scrollController;

  _TerminalState()
      : commandHistory = Queue(),
        _scrollController = ScrollController();

  void _addWidget(Widget widget) {
    setState(() => _widgets!.add(widget));
  }

  void _addCommandPrompt([String? command]) {
    var prompt = CommandPrompt(
        text: command ?? '',
        onSubmit: (result) {
          _addCommandResult(result);
          _addCommandPrompt();
        },
        requestCommandHistory: (index) => index < commandHistory.length
            ? commandHistory.elementAt(index)
            : null,
        active: command == null);
    _addWidget(prompt);
    if (command != null) {
      _addCommandResult(command);
    }
  }

  void _addCommandResult(String command) {
    commandHistory.addFirst(command);
    command = command.replaceAll(' +', ' ').trim().toLowerCase();
    var arguments = command.split(' ');
    var firstArg = arguments.first;
    if (arguments.length > 0 && Terminal.COMMAND_MAP.containsKey(firstArg)) {
      var commandCreate = Terminal.COMMAND_MAP[firstArg]!;
      _addWidget(commandCreate(arguments));
    } else if (firstArg.isNotEmpty) {
      setState(() => _widgets!.add(Text(
          'terminal: $firstArg: command not found, type \'help\' to see available commands',
          style: TerminalStyle.monospaced())));
    }
  }

  @override
  void initState() {
    super.initState();
    if (_widgets == null) {
      _widgets = <Widget>[];
      if (widget.initialCommands != null) {
        widget.initialCommands!.forEach(_addCommandPrompt);
      }
      _addCommandPrompt();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_widgets != null &&
        _scrollController.hasClients &&
        _knownWidgets != _widgets!.length) {
      _knownWidgets = _widgets!.length;
    }
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (_widgets == null ||
              _widgets!.isEmpty ||
              _widgets!.last is! CommandPrompt) {
            return;
          }
          var prompt = _widgets!.last as CommandPrompt;
          if (prompt.active) {
            prompt.focus();
          }
        },
        child: Container(
            margin: EdgeInsets.only(right: 3.0, top: 5.0, bottom: 5.0),
            clipBehavior: Clip.none,
            child: RawScrollbar(
                thumbColor: Colors.white12,
                controller: _scrollController,
                isAlwaysShown: true,
                thickness: 7.0,
                radius: Radius.circular(20.0),
                child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: ScrollConfiguration(
                        behavior: ScrollBehaviorNoGlow(),
                        child: SingleChildScrollView(
                          clipBehavior: Clip.none,
                          // reverse: true,
                          padding: EdgeInsets.only(left: 5.0, right: 15.0),
                          controller: _scrollController,
                          dragStartBehavior: DragStartBehavior.down,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (_widgets ?? [])
                                .map((e) =>
                                    SizedBox(width: double.infinity, child: e))
                                .toList(),
                          ),
                        ))))));
  }
}
