import 'package:flutter/material.dart';

class FirstDisabledFocusNode extends FocusNode {
  @override
  bool consumeKeyboardToken() {
    return false;
  }
}
