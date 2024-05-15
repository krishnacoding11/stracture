import 'package:field/bloc/sitetask/toggle_cubit.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../analytics/event_analytics.dart';
import '../../../../injection_container.dart';
import '../../../../utils/utils.dart';
import '../../../managers/color_manager.dart';
import '../../../managers/font_manager.dart';

class SearchTask extends StatefulWidget {
  const SearchTask(
      {Key? key,
        this.initialValue,
        this.placeholder,
        this.onSearchChanged,
        this.onCloseIconPressed,
        this.borderWidth,
        this.onRecentSearchListUpdated,
        this.setInitialOptionsValue,
        this.contentPadding,
        this.textLimitLength,
        this.isShowClearButtonOnCleared,
        this.fromScreen = FireBaseFromScreen.login})
      : super(key: key);
  final Function? setInitialOptionsValue;
  final Function? onSearchChanged;
  final Function? onCloseIconPressed;
  final Function? onRecentSearchListUpdated;
  final String? initialValue;
  final double? borderWidth;
  final bool? isShowClearButtonOnCleared;
  final FireBaseFromScreen fromScreen;
  final String? placeholder;
  final int? textLimitLength;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<SearchTask> createState() => _SearchTaskState();
}

class _SearchTaskState extends State<SearchTask> {
  final List<String> _options = <String>[];
  String searchText = "";
  String highlightSearch = "";
  bool show = false;
  final ToggleCubit _toggleCubit = getIt<ToggleCubit>();
  int maxSearchLength = 3;
  bool isFocusChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.setInitialOptionsValue != null) {
        widget.setInitialOptionsValue!(_options);
      }
      searchText = widget.initialValue ?? "";
      highlightSearch = "";
      _showHideSuffixIcon(searchText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => _toggleCubit,
        child: BlocBuilder<ToggleCubit, bool>(builder: (context, state) {
          return LayoutBuilder(
              builder: (context, constraints) => RawAutocomplete<String>(
                initialValue:
                TextEditingValue(text: widget.initialValue ?? ""),
                onSelected: (option) {
                  _showHideSuffixIcon(option);
                  _passChangedValue(option);
                  context.closeKeyboard();
                },
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return _options.where((String option) {
                    return option
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  focusNode.addListener(() {
                    if (!isFocusChanges && focusNode.hasFocus) {
                      isFocusChanges = true;
                      setState(() {});
                    }
                  });
                  return SizedBox(
                    height: 40,
                    child: Semantics(
                          label: "SearchTextfield",
                          child:TextFormField(
                      inputFormatters: widget.textLimitLength != null
                                ? [
                                    new LengthLimitingTextInputFormatter(widget.textLimitLength),
                                  ]
                                : null,
                            controller: textEditingController,
                            focusNode: focusNode,
                            style: TextStyle(height: 1.3),
                            textAlignVertical: TextAlignVertical.center,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: AColors.white,
                                border: InputBorder.none,
                                contentPadding: widget.contentPadding ??EdgeInsets.zero,
                                suffixIcon: isFocusChanges
                                    ? InkWell(
                                    onTap: () {
                                      isFocusChanges = false;
                                      FocusScope.of(context).unfocus();
                                      textEditingController.clear();
                                      context.closeKeyboard();
                                      _showHideSuffixIcon("");
                                      _passSearchText("", true);widget.onCloseIconPressed?.call();
                                    },
                                    child: Icon(Icons.close, color: AColors.iconGreyColor))
                                    : null,
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: AColors.lightGreyColor, width: widget.borderWidth ?? 2.0)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: AColors.lightGreyColor, width: widget.borderWidth ?? 2.0)),
                                hintText: widget.placeholder ?? context.toLocale!.lbl_search_site,
                                isDense: true,
                                prefixIcon: Icon(Icons.search, color: AColors.iconGreyColor)),
                            onChanged: (value) {
                              _showHideSuffixIcon(value);
                              _passChangedValue(value);
                            },
                            onFieldSubmitted: (String value) {
                              // Searching on clicking on search button from the keyboard
                              _passSearchText(value.trim());
                              _saveRecentSearch(value.trim());
                              _showHideSuffixIcon(value);

                        if (value.isEmpty) {
                          isFocusChanges = false;
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),
                  ),
                );
                },optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(5.0)),
                      ),
                      elevation: 5.0,
                      child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight: 24 *
                                  (options.length >= 3
                                      ? 3
                                      : options.length) +
                                  50,
                              minWidth: constraints.biggest.width,
                              maxWidth: constraints.biggest.width),
                          //140.0,
                          child: Column(
                            children: [
                              Align(
                                  alignment: Directionality.of(context) ==
                                      TextDirection.rtl
                                      ? Alignment.topRight
                                      : Alignment.topLeft,
                                  child: Padding(
                                      padding:
                                      const EdgeInsetsDirectional.only(
                                          start: 15, top: 10),
                                      child: NormalTextWidget(
                                        context.toLocale!.recent_searches,
                                        textAlign: TextAlign.start,
                                        fontWeight: AFontWight.regular,
                                        fontSize: 10.0,
                                      ))),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(1.0),
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final String option =
                                    options.elementAt(index);
                                    return GestureDetector(
                                      onTap: () {
                                        onSelected(option);
                                      },
                                      child: ListTile(
                                        horizontalTitleGap: 0,
                                        contentPadding:
                                        const EdgeInsetsDirectional
                                            .fromSTEB(15, 0, 0, 0),
                                        dense: true,
                                        visualDensity: const VisualDensity(
                                            vertical: -3),
                                        title: RichText(
                                          text: TextSpan(
                                            style:
                                            DefaultTextStyle.of(context)
                                                .style,
                                            children: Utility.getTextSpans(
                                                option, highlightSearch),
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.close),
                                          iconSize: 20,
                                          color: AColors.iconGreyColor,
                                          onPressed: () {
                                            setState(() {
                                              _removeRecentSearch(option);
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )),
                    ),
                  );
                },
              ));
        }));
  }

  Future<void> _saveRecentSearch(String searchValue) async {
    final bool matchNewSearch =
    _options.any((element) => element == searchValue);
    if (matchNewSearch) {
      _options.removeWhere((element) => element == searchValue);
    }
    if (!searchValue.isNullOrEmpty() && searchValue.length >= maxSearchLength) {
      String? listItem = _options.firstWhere(
            (item) => item == searchValue,
        orElse: () => "",
      );
      if (listItem.isEmpty) {
        _options.insert(0, searchValue);
        if (_options.length > 5) {
          _options.removeLast();
        }
        if (widget.onRecentSearchListUpdated != null) {
          widget.onRecentSearchListUpdated!(_options);
        }
      }
    }
  }

  Future<void> _removeRecentSearch(String searchValue) async {
    _options.remove(searchValue);
    if (widget.onRecentSearchListUpdated != null) {
      widget.onRecentSearchListUpdated!(_options);
    }
  }

  void _showHideSuffixIcon(String value) {
    if (widget.isShowClearButtonOnCleared == null ||
        widget.isShowClearButtonOnCleared == false) {
      _toggleCubit.toggleChange(value.isNotEmpty);
    }
  }

  void _passChangedValue(String value) {
    highlightSearch = value;
    if ((value.isEmpty && searchText.isNotEmpty) ||
        (value.length >= maxSearchLength)) {
      _passSearchText(value);
    }
  }

  void _passSearchText(String value, [bool isFromCloseButton = false]) {
    highlightSearch = value;
    searchText = value;
    if (widget.onSearchChanged != null) {
      widget.onSearchChanged!(value, isFromCloseButton);
    }
  }
}