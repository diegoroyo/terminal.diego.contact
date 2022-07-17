import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terminal/include/cat_files.dart';
import 'package:terminal/include/style.dart';
import 'package:terminal/widgets/terminal/terminal.dart';
import 'package:terminal/util/first_disabled_focus_node.dart';
import 'dart:collection' show Queue;

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
                        return null;
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
                          return null;
                        }
                        partial = text.substring(lastSpace + 1, pos);
                        autocompletes = CatFiles.FILENAME_MAP.keys.toList();
                      }
                      List<String> filteredAutocompletes = autocomplete(
                          partial: partial, autocompletes: autocompletes);
                      if (filteredAutocompletes.isEmpty) {
                        return null;
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
                      return null;
                    }),
                    ArrowUpIntent: CallbackAction<ArrowUpIntent>(onInvoke: (_) {
                      int idToRequest = lastCommandsQueue.length;
                      String? replaceCommand =
                          widget.requestCommandHistory(idToRequest);
                      if (replaceCommand == null) {
                        // we have reached the history limit, no more commands
                        return null;
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
                      return null;
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
                      return null;
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
