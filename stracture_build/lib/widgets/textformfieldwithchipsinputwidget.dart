import 'package:field/presentation/managers/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logger/logger.dart';
import '../presentation/managers/font_manager.dart';
import 'normaltext.dart';

class ATextFormFieldWithChipInputWidget extends StatelessWidget {
  List<ChipData> chipList = [];
  List<ChipData>? selectedChipList = [];
  String lblText;
  bool? disableInteraction;
  Function? editingFinished;
  int? index;

  ATextFormFieldWithChipInputWidget({Key? key, required this.chipList, required this.lblText, this.selectedChipList, this.disableInteraction, this.editingFinished, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: disableInteraction ?? false,
      child: ChipsInput<ChipData>(
        initialValue: selectedChipList != null && selectedChipList!.isNotEmpty ? selectedChipList!.toSet() : {},
        //key: Key("aaa"),
        decoration: InputDecoration(suffixIcon: const Icon(Icons.add), labelText: lblText, fillColor: AColors.white, filled: true, focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black12, width: 3.0)), disabledBorder: InputBorder.none, enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black12, width: 3.0))),
        findSuggestions: _findSuggestions,
        onChanged: _onChanged,
        editingFinished: (String text) {
          if (editingFinished != null) {
            editingFinished!(text, index);
          }
        },
        chipBuilder: (BuildContext context, ChipsInputState<ChipData> state, ChipData profile) {
          return InputChip(
            key: ObjectKey(profile),
            backgroundColor: AColors.white,
            label: NormalTextWidget(
              profile.displayLabel,
              textAlign: TextAlign.start,
              fontWeight: AFontWight.regular,
              fontSize: 10.0,
            ),
            labelStyle: TextStyle(color: AColors.textColor1),
            onDeleted: () => state.deleteChip(profile),
            onSelected: (_) => _onChipTapped(profile),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
        suggestionBuilder: (BuildContext context, ChipsInputState<ChipData> state, ChipData profile) {
          return ListTile(
            key: ObjectKey(profile),
            /*leading: CircleAvatar(
                    backgroundImage: NetworkImage(profile.imageUrl),
                  ),*/
            title: Text(profile.displayLabel),
            subtitle: Text(profile.displayLabel),
            onTap: () => state.selectSuggestion(profile),
          );
        },
      ),
    );
  }

  void _onChipTapped(ChipData profile) {
    Log.d("ATextFormFieldWithChipInputWidget _onChipTapped profile $profile");
  }

  void _onChanged(List<ChipData> data) {
    Log.d("ATextFormFieldWithChipInputWidget _onChanged onChanged $data");
  }

  Future<List<ChipData>> _findSuggestions(String query) async {
    if (query.isNotEmpty) {
      return chipList.where((profile) {
        return profile.displayLabel.contains(query);
      }).toList(growable: false);
    } else {
      return const <ChipData>[];
    }
  }
}

class ChipData {
  final String displayLabel;
  Object object;

  ChipData(this.displayLabel, this.object);

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChipData && runtimeType == other.runtimeType && displayLabel == other.displayLabel;

  @override
  int get hashCode => displayLabel.hashCode;

/*@override
  String toString() {
    return 'Profile{$name}';
  }*/
}

typedef ChipsInputSuggestions<T> = Future<List<T>> Function(String query);
typedef ChipSelected<T> = void Function(T data, bool selected);
typedef ChipsBuilder<T> = Widget Function(BuildContext context, ChipsInputState<T> state, T data);

class ChipsInput<T> extends StatefulWidget {
  const ChipsInput({Key? key, this.decoration = const InputDecoration(), required this.chipBuilder, required this.suggestionBuilder, required this.findSuggestions, required this.onChanged, this.onChipTapped, required this.editingFinished, required this.initialValue}) : super(key: key);

  final InputDecoration decoration;
  final ChipsInputSuggestions findSuggestions;
  final ValueChanged<List<T>> onChanged;
  final ValueChanged<T>? onChipTapped;
  final ChipsBuilder<T> chipBuilder;
  final ChipsBuilder<T>? suggestionBuilder;
  final Function editingFinished;
  final Set<T> initialValue;

  @override
  ChipsInputState<T> createState() => ChipsInputState<T>();
}

class ChipsInputState<T> extends State<ChipsInput<T>> implements TextInputClient {
  static const kObjectReplacementChar = 0xFFFC;

  Set<T> _chips = <T>{};
  List<dynamic>? _suggestions;
  int _searchId = 0;

  late FocusNode _focusNode;
  TextEditingValue _value = const TextEditingValue();
  TextInputConnection? _connection;

  String get text {
    return String.fromCharCodes(
      _value.text.codeUnits.where((ch) => ch != kObjectReplacementChar),
    );
  }

  @override
  TextEditingValue get currentTextEditingValue => _value;

  bool get _hasInputConnection => _connection != null && _connection!.attached;

  void requestKeyboard() {
    if (_focusNode.hasFocus) {
      _openInputConnection();
    } else {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void selectSuggestion(T data) {
    setState(() {
      _chips.add(data);
      _updateTextInputState();
      _suggestions = null;
    });
    widget.onChanged(_chips.toList(growable: false));
  }

  void deleteChip(T data) {
    setState(() {
      _chips.remove(data);
      _updateTextInputState();
    });
    widget.onChanged(_chips.toList(growable: false));
  }

  @override
  void initState() {
    _chips = widget.initialValue;
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _openInputConnection();
    } else {
      _closeInputConnectionIfNeeded();
    }
    setState(() {
      // rebuild so that _TextCursor is hidden.
    });
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _closeInputConnectionIfNeeded();
    super.dispose();
  }

  void _openInputConnection() {
    if (!_hasInputConnection) {
      _connection = TextInput.attach(this, TextInputConfiguration());
      _connection?.setEditingState(_value);
    }
    _connection?.show();
  }

  void _closeInputConnectionIfNeeded() {
    if (_hasInputConnection) {
      _connection?.close();
      //_connection = null;
    }
    widget.editingFinished(text);
  }

  @override
  Widget build(BuildContext context) {
    var chipsChildren = _chips
        .map<Widget>(
          (data) => widget.chipBuilder(context, this, data),
        )
        .toList();

    return Column(
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: requestKeyboard,
          child: InputDecorator(
            decoration: widget.decoration,
            isFocused: _focusNode.hasFocus,
            isEmpty: _value.text.isEmpty,
            child: Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: chipsChildren,
            ),
          ),
        ),
        _suggestions != null && _suggestions!.isNotEmpty
            ? Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    return widget.suggestionBuilder!(context, this, _suggestions![index]);
                  },
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    final oldCount = _countReplacements(_value);
    final newCount = _countReplacements(value);
    setState(() {
      if (newCount < oldCount) {
        _chips = Set.from(_chips.take(newCount));
      }
      _value = value;
    });
    _onSearchChanged(text);
  }

  int _countReplacements(TextEditingValue value) {
    return value.text.codeUnits.where((ch) => ch == kObjectReplacementChar).length;
  }

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    // Not required
  }

  @override
  void connectionClosed() {
    _focusNode.unfocus();
  }

  @override
  void performAction(TextInputAction action) {
    _focusNode.unfocus();
  }

  void _updateTextInputState() {
    final text = String.fromCharCodes(_chips.map((_) => kObjectReplacementChar));
    _value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange(start: 0, end: text.length),
    );
    _connection?.setEditingState(_value);
  }

  void _onSearchChanged(String value) async {
    final localId = ++_searchId;
    final results = await widget.findSuggestions(value);
    if (_searchId == localId && mounted) {
      setState(() => _suggestions = results.where((profile) => !_chips.contains(profile)).toList(growable: false));
    }
  }

  @override
  // TODO: implement currentAutofillScope
  AutofillScope? get currentAutofillScope => throw UnimplementedError();

  @override
  void insertTextPlaceholder(Size size) {}

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @override
  void removeTextPlaceholder() {}

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void showToolbar() {}

  @override
  void performSelector(String selectorName) {
    // TODO: implement performSelector
  }

  @override
  void didChangeInputControl(TextInputControl? oldControl, TextInputControl? newControl) {
    // TODO: implement didChangeInputControl
  }

  @override
  void insertContent(KeyboardInsertedContent content) {
    // TODO: implement insertContent
  }
}
