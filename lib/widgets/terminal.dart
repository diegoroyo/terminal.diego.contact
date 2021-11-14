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

class TabIntent extends Intent {
  const TabIntent();
}

class ArrowUpIntent extends Intent {
  const ArrowUpIntent();
}

class ArrowDownIntent extends Intent {
  const ArrowDownIntent();
}

class CommandPrompt extends StatefulWidget {
  final String text;
  final int cursorPos;
  final void Function(String) onSubmit;
  final FocusNode _textFocusNode;
  final void Function(String, int, List<String>) onShowAutocompleteResults;
  final String? Function(int) requestCommandHistory;

  void focus() {
    _textFocusNode.requestFocus();
  }

  /// note: initial value, current value is stored in the state
  final bool active;

  CommandPrompt(
      {Key? key,
      required this.text,
      required this.cursorPos,
      required this.onSubmit,
      required this.onShowAutocompleteResults,
      required this.requestCommandHistory,
      this.active = true})
      : _textFocusNode =
            TerminalStyle.IS_MOBILE ? FirstDisabledFocusNode() : FocusNode(),
        super(key: key);

  @override
  _CommandPromptState createState() => _CommandPromptState(
      active: active, text: text, initialCursorPos: cursorPos);
}

class _CommandPromptState extends State<CommandPrompt> {
  int initialCursorPos;
  bool active;
  TextEditingController textController;
  Queue<String> lastCommandsQueue;

  _CommandPromptState(
      {required this.active,
      required String text,
      required this.initialCursorPos})
      : textController = TextEditingController(text: text),
        lastCommandsQueue = Queue();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(widget._textFocusNode);
      setState(() {
        textController.selection =
            TextSelection.fromPosition(TextPosition(offset: initialCursorPos));
      });
    });
  }

  void onSubmitted(String result) {
    setState(() => active = false);
    widget.onSubmit(textController.text);
  }

  List<String> autocomplete(
      {required String partial, required List<String> autocompletes}) {
    List<String> candidates = List.from(autocompletes);
    for (int i = 0; i < partial.length; i++) {
      if (candidates.isEmpty) {
        break;
      }
      // letter-by-letter equality check
      candidates = candidates.where((c) => c[i] == partial[i]).toList();
    }
    candidates.sort();
    return candidates;
  }

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text('~\$', style: TerminalStyle.monospaced()),
      Container(width: 5.0),
      Expanded(
          child: Shortcuts(
              shortcuts: <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.tab): TabIntent(),
            SingleActivator(LogicalKeyboardKey.arrowUp): ArrowUpIntent(),
            SingleActivator(LogicalKeyboardKey.arrowDown): ArrowDownIntent(),
          },
              child: Actions(
                  actions: <Type, Action<Intent>>{
                    TabIntent: CallbackAction<TabIntent>(onInvoke: (_) {
                      String text = textController.text;
                      if (text.isEmpty) {
                        return;
                      }
                      int pos = textController.selection.start;
                      bool recommendCommands =
                          !text.substring(0, pos).contains(' ');
                      String partial = '';
                      List<String> autocompletes;
                      if (recommendCommands) {
                        partial = text.substring(0, pos).trim();
                        autocompletes = Terminal.COMMAND_MAP.keys.toList();
                      } else {
                        // recommend text files
                        int lastSpace = text.substring(0, pos).lastIndexOf(' ');
                        if (lastSpace == -1) {
                          print('Terminal autocompletion assertion error: '
                              'trying to autocomplete a text file when the cursor '
                              'is on the start on the line (a command should be recommended instead?)');
                          return;
                        }
                        partial = text.substring(lastSpace + 1, pos);
                        autocompletes = CatFiles.FILENAME_MAP.keys.toList();
                      }
                      List<String> filteredAutocompletes = autocomplete(
                          partial: partial, autocompletes: autocompletes);
                      if (filteredAutocompletes.isEmpty) {
                        return;
                      } else if (filteredAutocompletes.length == 1) {
                        String result =
                            filteredAutocompletes[0].substring(partial.length);
                        String modifiedText = text.substring(0, pos) +
                            result +
                            text.substring(pos);
                        setState(() {
                          textController.text = modifiedText;
                          textController.selection = TextSelection.fromPosition(
                              TextPosition(offset: pos + result.length));
                        });
                      } else {
                        setState(() => active = false);
                        widget.onShowAutocompleteResults(
                            text, pos, filteredAutocompletes);
                      }
                    }),
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
                    // NOTE(diego): on android, google keyboard's suggestions
                    // prevent the onSubmitted event from being triggered
                    // (i guess the enter press is consumed by the suggestion
                    // system and does not reach this textfield)
                    // setting keyboardtype to emailAddress serves as a
                    // workaround as it disables suggestions, something that
                    // "enableSuggestions: false" and "autocorrect: false"
                    // both failed to do
                    // so this is actually really important please dont remove
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
      onLinkTap: (url, context, attributes, element) {
        if (url != null) {
          html.window.open(url, '_blank');
        }
      },
    );
  }
}

/// Terminal ///

class Terminal extends StatefulWidget {
  // ignore: non_constant_identifier_names
  static final Map<String, Command Function(List<String>)> COMMAND_MAP = {
    'ls': (args) {
      List<String> filenames = CatFiles.FILENAME_MAP.keys.toList();
      filenames.sort();
      return TextCommand.create(args, text: filenames.join('  '));
    },
    'cat': (args) => CatCommand.create(args),
    'neofetch': (args) => CatCommand.create(['cat', 'neofetch.txt']),
    'head': (args) => CatCommand.create(args),
    'help': (args) => CatCommand.create(['cat', 'help.txt']),
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

  void _addCommandPrompt(
      {required bool autoSubmit, String? command, int? cursorPos}) {
    var prompt = CommandPrompt(
        text: command ?? '',
        cursorPos: cursorPos ?? 0,
        onSubmit: (result) {
          _addCommandResult(result);
          _addCommandPrompt(autoSubmit: false);
        },
        onShowAutocompleteResults: (prompt, cursorPos, suggestions) {
          _addWidget(TextCommand.create([], text: suggestions.join('  ')));
          _addCommandPrompt(
              command: prompt, cursorPos: cursorPos, autoSubmit: false);
        },
        requestCommandHistory: (index) => index < commandHistory.length
            ? commandHistory.elementAt(index)
            : null,
        active: !autoSubmit);
    _addWidget(prompt);
    if (autoSubmit) {
      if (command == null || command.isEmpty) {
        print('Terminal prompt assertion error: trying to autoSubmit '
            'a command prompt when the command is empty/null?');
      } else {
        _addCommandResult(command);
      }
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
        widget.initialCommands!
            .forEach((c) => _addCommandPrompt(command: c, autoSubmit: true));
      }
      _addCommandPrompt(autoSubmit: false);
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
