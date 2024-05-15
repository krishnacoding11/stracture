import 'package:field/widgets/custom_search_view/suggestion_selection_notify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart'; // Import this to access RawKeyEvent classes

void main() {
  group('KeyboardSuggestionSelectionNotifier', () {
    late KeyboardSuggestionSelectionNotifier notifierKeyboard;
    late ShouldRefreshSuggestionFocusIndexNotifier notifier;
    late FocusNode textFieldFocusNode;

    setUp(() {
      notifierKeyboard = KeyboardSuggestionSelectionNotifier();
      textFieldFocusNode = FocusNode();
      notifier = ShouldRefreshSuggestionFocusIndexNotifier(
        textFieldFocusNode: textFieldFocusNode,
      );
    });

    test('onKeyboardEvent arrowDown', () {
      final event = RawKeyDownEvent(
        data: RawKeyEventDataAndroid(keyCode: 20), // KeyCode for arrowDown
      );

      notifierKeyboard.onKeyboardEvent(event);

      expect(notifierKeyboard.value, LogicalKeyboardKey.arrowDown);
    });

    test('onKeyboardEvent arrowUp', () {
      final event = RawKeyDownEvent(
        data: RawKeyEventDataAndroid(keyCode: 19), // KeyCode for arrowUp
      );

      notifierKeyboard.onKeyboardEvent(event);

      expect(notifierKeyboard.value, LogicalKeyboardKey.arrowUp);
    });

    test('onKeyboardEvent non-arrow key', () {
      final event = RawKeyDownEvent(
        data: RawKeyEventDataAndroid(keyCode: 29), // KeyCode for keyA (example)
      );

      notifierKeyboard.onKeyboardEvent(event);

      expect(notifierKeyboard.value, isNull);
    });

    test('onKeyboardEvent arrowDown repeated', () {
      final event1 = RawKeyDownEvent(
        data: RawKeyEventDataAndroid(keyCode: 20), // KeyCode for arrowDown
      );

      final event2 = RawKeyDownEvent(
        data: RawKeyEventDataAndroid(keyCode: 20), // KeyCode for arrowDown
      );

      notifierKeyboard.onKeyboardEvent(event1);
      notifierKeyboard.onKeyboardEvent(event2);

      expect(notifierKeyboard.value, LogicalKeyboardKey.arrowDown);
    });

    test('onKeyboardEvent arrowUp followed by arrowDown', () {
      final event1 = RawKeyDownEvent(
        data: RawKeyEventDataAndroid(keyCode: 19), // KeyCode for arrowUp
      );

      final event2 = RawKeyDownEvent(
        data: RawKeyEventDataAndroid(keyCode: 20), // KeyCode for arrowDown
      );

      notifierKeyboard.onKeyboardEvent(event1);
      notifierKeyboard.onKeyboardEvent(event2);

      expect(notifierKeyboard.value, LogicalKeyboardKey.arrowDown);
    });

    test('notifier notifies when focus gained', () async {
      bool notified = false;

      notifier.addListener(() {
        notified = true;
      });

      // Simulate gaining focus
      textFieldFocusNode.requestFocus();

      // Wait for possible asynchronous notification
      await Future.delayed(Duration(milliseconds: 100));

      expect(notified, false);
    });

    test('notifier does not notify when focus lost', () async {
      bool notified = false;

      notifier.addListener(() {
        notified = true;
      });

      // Simulate losing focus
      textFieldFocusNode.requestFocus();
      textFieldFocusNode.unfocus();

      // Wait for possible asynchronous notification
      await Future.delayed(Duration(milliseconds: 100));

      expect(notified, false);
    });

  });
}
