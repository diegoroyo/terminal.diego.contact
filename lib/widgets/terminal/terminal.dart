import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:terminal/include/cat_files.dart';
import 'package:terminal/include/style.dart';
import 'package:terminal/util/scroll_behavior_no_glow.dart';
import 'package:terminal/widgets/terminal/command_prompt.dart';
import 'package:terminal/widgets/terminal/commands.dart';
import 'dart:collection' show Queue;

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

class _TerminalState extends State<Terminal> with WidgetsBindingObserver {
  List<Widget>? _widgets;
  Queue<String> commandHistory;
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
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {
      Future.delayed(Duration(milliseconds: 250)).then((_) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 100), curve: Curves.linear);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
