import 'dart:async';
import 'dart:math';

import 'package:field/injection_container.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/custom_search_view/suggestion_selection_notify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/custom_search_view/custom_search_view_cubit.dart';

typedef SuggestionsCallback<T> = FutureOr<Iterable<T>> Function(String pattern);
typedef ItemBuilder<T> = Widget Function(
    BuildContext context, T itemData, Function suggestionsCallback);
typedef SuggestionSelectionCallback<T> = void Function(T suggestion);
typedef ErrorBuilder = Widget Function(BuildContext context, Object? error);
typedef AnimationTransitionBuilder = Widget Function(
    BuildContext context, Widget child, AnimationController? controller);

class CustomSearchSuggestionView<T> extends FormField<String> {
  final SearchTextFormFieldConfiguration textFieldConfiguration;

  CustomSearchSuggestionView({
    Key? key,
    String? initialValue,
    String? placeholder,
    bool getImmediateSuggestions = false,
    bool autoValidate = false,
    bool enabled = true,
    AutovalidateMode autoValidateMode = AutovalidateMode.disabled,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    ErrorBuilder? errorBuilder,
    WidgetBuilder? noItemsFoundBuilder,
    WidgetBuilder? loadingBuilder,
    void Function(bool)? onSuggestionsBoxToggle,
    Duration debounceDuration = const Duration(milliseconds: 300),
    SuggestionsBoxDecoration suggestionsBoxDecoration = const SuggestionsBoxDecoration(),
    SearchSuggestionsBoxController? suggestionsBoxController,
    required SuggestionSelectionCallback<T> onSuggestionSelected,
    required ItemBuilder<T> itemBuilder,
    required SuggestionsCallback<T> suggestionsCallback,
    double suggestionsBoxVerticalOffset = 5.0,
    this.textFieldConfiguration = const SearchTextFormFieldConfiguration(),
    AnimationTransitionBuilder? transitionBuilder,
    Duration animationDuration = const Duration(milliseconds: 500),
    double animationStart = 0.25,
    bool hideOnLoading = true,
    bool hideOnEmpty = false,
    bool hideOnError = true,
    bool hideSuggestionsOnKeyboardHide = false,
    bool keepSuggestionsOnLoading = true,
    bool keepSuggestionsOnSuggestionSelected = false,
    bool hideKeyboard = false,
    int minCharsForSuggestions = 0,
    bool hideKeyboardOnDrag = false,
    Widget? currentSearchHeader,
  })
      : assert(initialValue == null ||
      textFieldConfiguration.controller == null),
        assert(minCharsForSuggestions >= 0),
        super(
          key: key,
          onSaved: onSaved,
          validator: validator,
          initialValue: textFieldConfiguration.controller != null
              ? textFieldConfiguration.controller!.text
              : (initialValue ?? ''),
          enabled: enabled,
          autovalidateMode: autoValidateMode,
          builder: (FormFieldState<String> field) {
            final _CustomSearchSuggestionViewState state =
            field as _CustomSearchSuggestionViewState<dynamic>;

            return Scrollable(
                viewportBuilder: (BuildContext context,
                    ViewportOffset position) =>
                    CustomSearchView(
                      getImmediateSuggestions: getImmediateSuggestions,
                      transitionBuilder: transitionBuilder,
                      errorBuilder: errorBuilder,
                      placeholder: placeholder,
                      noItemsFoundBuilder: noItemsFoundBuilder,
                      loadingBuilder: loadingBuilder,
                      debounceDuration: debounceDuration,
                      suggestionsBoxDecoration: suggestionsBoxDecoration,
                      suggestionsBoxController: suggestionsBoxController,
                      textFieldConfiguration: textFieldConfiguration.copyWith(
                        onChanged: (text) {
                          state.didChange(text);
                          textFieldConfiguration.onChanged?.call(text);
                        },
                        controller: state._effectiveController,
                      ),
                      suggestionsBoxVerticalOffset:
                      suggestionsBoxVerticalOffset,
                      onSuggestionSelected: onSuggestionSelected,
                      onSuggestionsBoxToggle: onSuggestionsBoxToggle,
                      itemBuilder: itemBuilder,
                      suggestionsCallback: suggestionsCallback,
                      animationStart: animationStart,
                      animationDuration: animationDuration,
                      hideOnLoading: hideOnLoading,
                      hideOnEmpty: hideOnEmpty,
                      hideOnError: hideOnError,
                      hideSuggestionsOnKeyboardHide:
                      hideSuggestionsOnKeyboardHide,
                      keepSuggestionsOnLoading: keepSuggestionsOnLoading,
                      keepSuggestionsOnSuggestionSelected:
                      keepSuggestionsOnSuggestionSelected,
                      hideKeyboard: hideKeyboard,
                      minCharsForSuggestions: minCharsForSuggestions,
                      hideKeyboardOnDrag: hideKeyboardOnDrag,
                      currentSearchHeader: currentSearchHeader,
                    ));
          });

  @override
  _CustomSearchSuggestionViewState<T> createState() =>
      _CustomSearchSuggestionViewState<T>();
}

class _CustomSearchSuggestionViewState<T> extends FormFieldState<String> {
  TextEditingController? _controller;

  TextEditingController? get _effectiveController =>
      widget.textFieldConfiguration.controller ?? _controller;

  @override
  CustomSearchSuggestionView get widget =>
      super.widget as CustomSearchSuggestionView<dynamic>;

  @override
  void initState() {
    super.initState();
    if (widget.textFieldConfiguration.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      widget.textFieldConfiguration.controller!.addListener(
          _handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(CustomSearchSuggestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.textFieldConfiguration.controller !=
        oldWidget.textFieldConfiguration.controller) {
      oldWidget.textFieldConfiguration.controller?.removeListener(
          _handleControllerChanged);
      widget.textFieldConfiguration.controller?.addListener(
          _handleControllerChanged);

      if (oldWidget.textFieldConfiguration.controller != null &&
          widget.textFieldConfiguration.controller == null) {
        _controller =
            TextEditingController.fromValue(
                oldWidget.textFieldConfiguration.controller!.value);
      }
      if (widget.textFieldConfiguration.controller != null) {
        setValue(widget.textFieldConfiguration.controller!.text);
        if (oldWidget.textFieldConfiguration.controller == null)
          _controller = null;
      }
    }
  }

  @override
  void dispose() {
    widget.textFieldConfiguration.controller?.removeListener(
        _handleControllerChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    _effectiveController!.text = widget.initialValue!;
  }

  void _handleControllerChanged() {
    if (_effectiveController!.text != value) didChange(
        _effectiveController!.text);
  }
}

class CustomSearchView<T> extends StatefulWidget {
  final SuggestionsCallback<T> suggestionsCallback;

  final SuggestionSelectionCallback<T> onSuggestionSelected;

  final ItemBuilder<T> itemBuilder;

  final ScrollController? scrollController;

  final SuggestionsBoxDecoration suggestionsBoxDecoration;

  final SearchSuggestionsBoxController? suggestionsBoxController;

  final Duration debounceDuration;
  final WidgetBuilder? loadingBuilder;

  final WidgetBuilder? noItemsFoundBuilder;

  final ErrorBuilder? errorBuilder;

  final AnimationTransitionBuilder? transitionBuilder;

  final Duration animationDuration;

  final double animationStart;

  final double suggestionsBoxVerticalOffset;

  final bool getImmediateSuggestions;

  final bool hideOnLoading;

  final bool hideOnEmpty;

  final bool hideOnError;

  final bool hideSuggestionsOnKeyboardHide;

  final bool keepSuggestionsOnLoading;

  final bool keepSuggestionsOnSuggestionSelected;
  final bool hideKeyboard;
  final String? placeholder;
  final int minCharsForSuggestions;

  final bool hideKeyboardOnDrag;

  final SearchTextFormFieldConfiguration textFieldConfiguration;

  final void Function(bool)? onSuggestionsBoxToggle;
  final Widget? currentSearchHeader;

  const CustomSearchView({
    Key? key,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSuggestionSelected,
    this.textFieldConfiguration = const SearchTextFormFieldConfiguration(),
    this.suggestionsBoxDecoration = const SuggestionsBoxDecoration(),
    this.debounceDuration = const Duration(milliseconds: 300),
    this.suggestionsBoxController,
    this.scrollController,
    this.loadingBuilder,
    this.noItemsFoundBuilder,
    this.errorBuilder,
    required this.placeholder,
    this.transitionBuilder,
    this.animationStart = 0.25,
    this.animationDuration = const Duration(milliseconds: 500),
    this.getImmediateSuggestions = false,
    this.suggestionsBoxVerticalOffset = 5.0,
    this.hideOnLoading = false,
    this.hideOnEmpty = false,
    this.hideOnError = false,
    this.hideSuggestionsOnKeyboardHide = true,
    this.keepSuggestionsOnLoading = true,
    this.keepSuggestionsOnSuggestionSelected = false,
    this.hideKeyboard = false,
    this.minCharsForSuggestions = 0,
    this.onSuggestionsBoxToggle,
    this.hideKeyboardOnDrag = false,
    this.currentSearchHeader,
  })
      : assert(animationStart >= 0.0 && animationStart <= 1.0),
        assert(minCharsForSuggestions >= 0),
        assert(!hideKeyboardOnDrag ||
            hideKeyboardOnDrag && !hideSuggestionsOnKeyboardHide),
        super(key: key);

  @override
  _CustomSearchViewState<T> createState() => _CustomSearchViewState<T>();
}

class _CustomSearchViewState<T> extends State<CustomSearchView<T>>
    with WidgetsBindingObserver {
  FocusNode? _focusNode;
  final KeyboardSuggestionSelectionNotifier _keyboardSuggestionSelectionNotifier =
  KeyboardSuggestionSelectionNotifier();
  TextEditingController? _textEditingController;
  _SearchSuggestionsBox? _suggestionsBox;

  TextEditingController? get _effectiveController =>
      widget.textFieldConfiguration.controller ?? _textEditingController;

  FocusNode? get _effectiveFocusNode =>
      widget.textFieldConfiguration.focusNode ?? _focusNode;
  late VoidCallback _focusNodeListener;

  final LayerLink _layerLink = LayerLink();

  Timer? _resizeOnScrollTimer;
  final Duration _resizeOnScrollRefreshRate = const Duration(milliseconds: 500);
  ScrollPosition? _scrollPosition;

  bool _areSuggestionsFocused = false;
  late final _shouldRefreshSuggestionsFocusIndex =
  ShouldRefreshSuggestionFocusIndexNotifier(
      textFieldFocusNode: _effectiveFocusNode);

  @override
  void didChangeMetrics() {
    _suggestionsBox!.onChangeMetrics();
  }

  @override
  void dispose() {
    _suggestionsBox!.closeOverlay();
    _suggestionsBox!.widgetMounted = false;
    WidgetsBinding.instance.removeObserver(this);
    _effectiveFocusNode!.removeListener(_focusNodeListener);
    _focusNode?.dispose();
    _resizeOnScrollTimer?.cancel();
    _scrollPosition?.removeListener(_scrollResizeListener);
    _textEditingController?.dispose();
    _keyboardSuggestionSelectionNotifier.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode _, RawKeyEvent event) {
    _keyboardSuggestionSelectionNotifier.onKeyboardEvent(event);
    return KeyEventResult.ignored;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.textFieldConfiguration.controller == null) {
      _textEditingController = TextEditingController();
    }

    final textFieldConfigurationFocusNode = widget.textFieldConfiguration
        .focusNode;
    if (textFieldConfigurationFocusNode == null) {
      _focusNode = FocusNode(onKey: _onKeyEvent);
    } else if (textFieldConfigurationFocusNode.onKey == null) {
      textFieldConfigurationFocusNode.onKey = ((node, event) {
        final keyEventResult = _onKeyEvent(node, event);
        return keyEventResult;
      });
    } else {
      final onKeyCopy = textFieldConfigurationFocusNode.onKey!;
      textFieldConfigurationFocusNode.onKey = ((node, event) {
        _onKeyEvent(node, event);
        return onKeyCopy(node, event);
      });
    }

    _suggestionsBox = _SearchSuggestionsBox(context);
    widget.suggestionsBoxController?._suggestionsBox = _suggestionsBox;
    widget.suggestionsBoxController?._effectiveFocusNode = _effectiveFocusNode;

    _focusNodeListener = () {
      if (_effectiveFocusNode!.hasFocus) {
        _suggestionsBox!.openOverlay();
      } else if (!_areSuggestionsFocused) {
        if (widget.hideSuggestionsOnKeyboardHide) {
          _suggestionsBox!.closeOverlay();
        }
      } else {
        _suggestionsBox!.closeOverlay();
      }

      widget.onSuggestionsBoxToggle?.call(_suggestionsBox!.isOpened);
    };

    _effectiveFocusNode!.addListener(_focusNodeListener);


    WidgetsBinding.instance.addPostFrameCallback((duration) {
      if (mounted) {
        _initOverlayEntry();

        _suggestionsBox!.resize();

        if (_effectiveFocusNode!.hasFocus) {
          _suggestionsBox!.openOverlay();
        } else {
          _suggestionsBox!.closeOverlay();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScrollableState? scrollableState = Scrollable.of(context);
    if (scrollableState != null) {
      _scrollPosition = scrollableState.position;

      _scrollPosition!.removeListener(_scrollResizeListener);
      _scrollPosition!.isScrollingNotifier.addListener(_scrollResizeListener);
    }
  }

  void _scrollResizeListener() {
    bool isScrolling = _scrollPosition!.isScrollingNotifier.value;
    _resizeOnScrollTimer?.cancel();
    if (isScrolling) {
      _resizeOnScrollTimer =
          Timer.periodic(_resizeOnScrollRefreshRate, (timer) {
            _suggestionsBox!.resize();
          });
    } else {
      _suggestionsBox!.resize();
    }
  }

  void _initOverlayEntry() {
    _suggestionsBox!._overlayEntry = OverlayEntry(
        builder: (context) {
          void giveTextFieldFocus() {
            _effectiveFocusNode?.requestFocus();
            _areSuggestionsFocused = false;
          }

          void onSuggestionFocus() {
            if (!_areSuggestionsFocused) {
              _areSuggestionsFocused = true;
            }
          }

          final suggestionsList = _SearchSuggestionsList<T>(
            suggestionsBox: _suggestionsBox,
            decoration: widget.suggestionsBoxDecoration,
            debounceDuration: widget.debounceDuration,
            controller: _effectiveController,
            loadingBuilder: widget.loadingBuilder,
            scrollController: widget.scrollController,
            noItemsFoundBuilder: widget.noItemsFoundBuilder,
            errorBuilder: widget.errorBuilder,
            transitionBuilder: widget.transitionBuilder,
            suggestionsCallback: widget.suggestionsCallback,
            animationDuration: widget.animationDuration,
            animationStart: widget.animationStart,
            getImmediateSuggestions: widget.getImmediateSuggestions,
            currentSearchHeader: widget.currentSearchHeader,
            onSuggestionSelected: (T selection) {
              if (!widget.keepSuggestionsOnSuggestionSelected) {
                _effectiveFocusNode!.unfocus();
                _suggestionsBox!.closeOverlay();
              }
              widget.onSuggestionSelected(selection);
            },
            itemBuilder: widget.itemBuilder,
            hideOnLoading: widget.hideOnLoading,
            hideOnEmpty: widget.hideOnEmpty,
            hideOnError: widget.hideOnError,
            keepSuggestionsOnLoading: widget.keepSuggestionsOnLoading,
            minCharsForSuggestions: widget.minCharsForSuggestions,
            keyboardSuggestionSelectionNotifier: _keyboardSuggestionSelectionNotifier,
            shouldRefreshSuggestionFocusIndexNotifier: _shouldRefreshSuggestionsFocusIndex,
            giveTextFieldFocus: giveTextFieldFocus,
            onSuggestionFocus: onSuggestionFocus,
            onKeyEvent: _onKeyEvent,
            hideKeyboardOnDrag: widget.hideKeyboardOnDrag,
            fromSearch: true,
          );

          double w = _suggestionsBox!.textBoxWidth;
          if (widget.suggestionsBoxDecoration.constraints != null) {
            if (widget.suggestionsBoxDecoration.constraints!.minWidth != 0.0 &&
                widget.suggestionsBoxDecoration.constraints!.maxWidth !=
                    double.infinity) {
              w = (widget.suggestionsBoxDecoration.constraints!.minWidth +
                  widget.suggestionsBoxDecoration.constraints!.maxWidth) /
                  2;
            } else
            if (widget.suggestionsBoxDecoration.constraints!.minWidth != 0.0 &&
                widget.suggestionsBoxDecoration.constraints!.minWidth > w) {
              w = widget.suggestionsBoxDecoration.constraints!.minWidth;
            } else if (widget.suggestionsBoxDecoration.constraints!.maxWidth !=
                double.infinity &&
                widget.suggestionsBoxDecoration.constraints!.maxWidth < w) {
              w = widget.suggestionsBoxDecoration.constraints!.maxWidth;
            }
          }

          final Widget compositedFollower = CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(widget.suggestionsBoxDecoration.offsetX,
                _suggestionsBox!.textBoxHeight +
                    widget.suggestionsBoxVerticalOffset),
            child: suggestionsList,
          );
          return Positioned(
            width: w,
            child: compositedFollower,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      key: const Key("CustomSearchView"),
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(4.0)),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8.0, end: 8.0),
              child: Icon(
                Icons.search,
                color: AColors.iconGreyColor,
              ),
            ),
            Flexible(
              child: TextField(
                focusNode: _effectiveFocusNode,
                controller: _effectiveController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.placeholder ??
                        context.toLocale!.search_for,
                    hintStyle: TextStyle(color: AColors.iconGreyColor)),
                style: widget.textFieldConfiguration.style,
                textAlign: widget.textFieldConfiguration.textAlign,
                enabled: widget.textFieldConfiguration.enabled,
                keyboardType: widget.textFieldConfiguration.keyboardType,
                autofocus: widget.textFieldConfiguration.autofocus,
                inputFormatters: widget.textFieldConfiguration.inputFormatters,
                autocorrect: widget.textFieldConfiguration.autocorrect,
                maxLines: widget.textFieldConfiguration.maxLines,
                textAlignVertical: widget.textFieldConfiguration
                    .textAlignVertical,
                minLines: widget.textFieldConfiguration.minLines,
                maxLength: widget.textFieldConfiguration.maxLength,
                maxLengthEnforcement: widget.textFieldConfiguration
                    .maxLengthEnforcement,
                obscureText: widget.textFieldConfiguration.obscureText,
                onChanged: (value) {
                  widget.textFieldConfiguration.onChanged!(value);
                },
                onSubmitted: (value) {
                  widget.textFieldConfiguration.onSubmitted!(value);
                  _effectiveFocusNode!.unfocus();
                  _suggestionsBox!.closeOverlay();
                },
                onEditingComplete: widget.textFieldConfiguration
                    .onEditingComplete,
                onTap: widget.textFieldConfiguration.onTap,
                scrollPadding: widget.textFieldConfiguration.scrollPadding,
                textInputAction: widget.textFieldConfiguration.textInputAction,
                textCapitalization: widget.textFieldConfiguration
                    .textCapitalization,
                keyboardAppearance: widget.textFieldConfiguration
                    .keyboardAppearance,
                cursorWidth: widget.textFieldConfiguration.cursorWidth,
                cursorRadius: widget.textFieldConfiguration.cursorRadius,
                cursorColor: widget.textFieldConfiguration.cursorColor,
                textDirection: widget.textFieldConfiguration.textDirection,
                enableInteractiveSelection:
                widget.textFieldConfiguration.enableInteractiveSelection,
                readOnly: widget.hideKeyboard,
              ),
            ),
            widget.textFieldConfiguration.focusNode!.hasFocus ||
                widget.textFieldConfiguration.controller!.text.isNotEmpty ?
            InkWell(
                onTap: () {
                  if (widget.textFieldConfiguration.suffixIconOnClick != null) {
                    widget.textFieldConfiguration.suffixIconOnClick!();
                    context.closeKeyboard();
                    _effectiveFocusNode!.unfocus();
                    _suggestionsBox!.closeOverlay();
                  }
                },
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 8.0, end: 16.0),
                  child: Icon(
                    Icons.clear,
                    color: AColors.iconGreyColor,
                  ),
                )) : Container()
          ],
        ),
      ),
    );
  }
}

class _SearchSuggestionsList<T> extends StatefulWidget {
  final _SearchSuggestionsBox? suggestionsBox;
  final TextEditingController? controller;
  final bool getImmediateSuggestions;
  final SuggestionSelectionCallback<T>? onSuggestionSelected;
  final SuggestionsCallback<T>? suggestionsCallback;
  final ItemBuilder<T>? itemBuilder;
  final ScrollController? scrollController;
  final SuggestionsBoxDecoration? decoration;
  final Duration? debounceDuration;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? noItemsFoundBuilder;
  final ErrorBuilder? errorBuilder;
  final AnimationTransitionBuilder? transitionBuilder;
  final Duration? animationDuration;
  final double? animationStart;
  final bool? hideOnLoading;
  final bool? hideOnEmpty;
  final bool? hideOnError;
  final bool? keepSuggestionsOnLoading;
  final int? minCharsForSuggestions;
  final KeyboardSuggestionSelectionNotifier keyboardSuggestionSelectionNotifier;
  final ShouldRefreshSuggestionFocusIndexNotifier shouldRefreshSuggestionFocusIndexNotifier;
  final VoidCallback giveTextFieldFocus;
  final VoidCallback onSuggestionFocus;
  final KeyEventResult Function(FocusNode _, RawKeyEvent event) onKeyEvent;
  final bool hideKeyboardOnDrag;
  final Widget? currentSearchHeader;
  final bool? fromSearch;

  const _SearchSuggestionsList({required this.suggestionsBox,
    this.controller,
    this.getImmediateSuggestions = false,
    this.onSuggestionSelected,
    this.suggestionsCallback,
    this.itemBuilder,
    this.scrollController,
    this.decoration,
    this.debounceDuration,
    this.loadingBuilder,
    this.noItemsFoundBuilder,
    this.errorBuilder,
    this.transitionBuilder,
    this.animationDuration,
    this.animationStart,
    this.hideOnLoading,
    this.hideOnEmpty,
    this.hideOnError,
    this.keepSuggestionsOnLoading,
    this.minCharsForSuggestions,
    this.currentSearchHeader,
    required this.keyboardSuggestionSelectionNotifier,
    required this.shouldRefreshSuggestionFocusIndexNotifier,
    required this.giveTextFieldFocus,
    required this.onSuggestionFocus,
    required this.onKeyEvent,
    required this.hideKeyboardOnDrag,
    this.fromSearch});

  @override
  _SearchSuggestionsListState<T> createState() =>
      _SearchSuggestionsListState<T>();
}

class _SearchSuggestionsListState<T> extends State<_SearchSuggestionsList<T>>
    with SingleTickerProviderStateMixin {
  CustomSearchViewCubit? customSearchViewCubit;
  Timer? _debounceTimer;
  late final ScrollController _scrollController = widget.scrollController ??
      ScrollController();

  _SearchSuggestionsListState() {
    customSearchViewCubit = getIt<CustomSearchViewCubit>();
    customSearchViewCubit!.controllerListener = () {
      if (widget.controller!.text == customSearchViewCubit!.lastTextValue)
        return;

      customSearchViewCubit!.lastTextValue = widget.controller!.text;

      _debounceTimer?.cancel();
      if (widget.controller!.text.length < widget.minCharsForSuggestions!) {
        if (mounted) {
          customSearchViewCubit!.setSuggestionListen();
        }
        return;
      } else {
        _debounceTimer = Timer(widget.debounceDuration!, () async {
          if (_debounceTimer!.isActive) return;
          if (customSearchViewCubit!.isLoading!) {
            customSearchViewCubit!.isQueued = true;
            return;
          }

          await invalidateSuggestions();
          while (customSearchViewCubit!.isQueued!) {
            customSearchViewCubit!.isQueued = false;
            await invalidateSuggestions();
          }
        });
      }
    };
  }

  @override
  void didUpdateWidget(_SearchSuggestionsList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller!.addListener(customSearchViewCubit!.controllerListener);
    _getSuggestions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getSuggestions();
  }

  @override
  void initState() {
    super.initState();
    customSearchViewCubit!.animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    customSearchViewCubit!.suggestionsValid =
    widget.minCharsForSuggestions! > 0 ? true : false;
    customSearchViewCubit!.isLoading = false;
    customSearchViewCubit!.isQueued = false;
    customSearchViewCubit!.lastTextValue = widget.controller!.text;

    if (widget.getImmediateSuggestions) {
      _getSuggestions();
    }

    widget.controller!.addListener(customSearchViewCubit!.controllerListener);

    widget.keyboardSuggestionSelectionNotifier.addListener(() {
      final suggestionsLength = customSearchViewCubit!.suggestions?.length;
      final event = widget.keyboardSuggestionSelectionNotifier.value;
      if (event == null || suggestionsLength == null) return;

      if (event == LogicalKeyboardKey.arrowDown &&
          customSearchViewCubit!.suggestionIndex < suggestionsLength - 1) {
        customSearchViewCubit!.suggestionIndex++;
      } else if (event == LogicalKeyboardKey.arrowUp &&
          customSearchViewCubit!.suggestionIndex > -1) {
        customSearchViewCubit!.suggestionIndex--;
      }

      if (customSearchViewCubit!.suggestionIndex > -1 &&
          customSearchViewCubit!.suggestionIndex <
              customSearchViewCubit!.focusNodes.length) {
        final focusNode = customSearchViewCubit!
            .focusNodes[customSearchViewCubit!.suggestionIndex];
        focusNode.requestFocus();
        widget.onSuggestionFocus();
      } else {
        widget.giveTextFieldFocus();
      }
    });

    widget.shouldRefreshSuggestionFocusIndexNotifier.addListener(() {
      if (customSearchViewCubit!.suggestionIndex != -1) {
        customSearchViewCubit!.suggestionIndex = -1;
      }
    });
  }

  Future<void> invalidateSuggestions() async {
    customSearchViewCubit!.suggestionsValid = false;
    await _getSuggestions();
  }

  onRemoveItem() async {
    customSearchViewCubit!.suggestionsValid = false;
    await _getSuggestions();
  }

  Future<void> _getSuggestions() async {
    if (customSearchViewCubit!.suggestionsValid) return;
    customSearchViewCubit!.suggestionsValid = true;

    if (mounted) {
      customSearchViewCubit!.animationController!.forward(from: 1.0);
      customSearchViewCubit!.getSuggestionsChange();
      Iterable<T>? suggestions;
      Object? error;

      try {
        suggestions =
        await widget.suggestionsCallback!(widget.controller!.text);
      } catch (e) {
        error = e;
      }

      if (mounted) {
        double? animationStart = widget.animationStart;
        if (error != null || suggestions?.isEmpty == true) {
          animationStart = 1.0;
        }
        customSearchViewCubit!.animationController!.forward(
            from: animationStart);
        customSearchViewCubit!.setSuggestions(error, suggestions);
        customSearchViewCubit!.focusNodes = List.generate(
          customSearchViewCubit!.suggestions?.length ?? 0,
              (index) =>
              FocusNode(onKey: (_, event) {
                return widget.onKeyEvent(_, event);
              }),
        );
      }
    }
  }

  @override
  void dispose() {
    customSearchViewCubit!.animationController!.dispose();
    _debounceTimer?.cancel();
    for (final focusNode in customSearchViewCubit!.focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = createSuggestionsWidget();

    final animationChild = BlocBuilder<CustomSearchViewCubit, FlowState>(
        builder: (context, state) {
          return SizeTransition(
            axisAlignment: -1.0,
            sizeFactor: CurvedAnimation(
                parent: customSearchViewCubit!.animationController!,
                curve: Curves.fastOutSlowIn),
            child: child,
          );
        });

    BoxConstraints getBoxConstrains() {
      BoxConstraints constraints;
      if (widget.decoration!.constraints == null) {
        if (widget.fromSearch!) {
          constraints = BoxConstraints(
            maxHeight: customSearchViewCubit!.suggestions != null
                ? 40 *
                (customSearchViewCubit!.suggestions!.length >= 3
                    ? 4
                    : customSearchViewCubit!.suggestions!.length + 1)
                    .toDouble()
                : 0,
          );
        } else {
          constraints = BoxConstraints(
            maxHeight:
            customSearchViewCubit!.suggestions != null ? widget.suggestionsBox!
                .maxHeight : 0,
          );
        }
      } else {
        double maxHeight =
        min(widget.decoration!.constraints!.maxHeight,
            widget.suggestionsBox!.maxHeight);
        constraints = widget.decoration!.constraints!.copyWith(
          minHeight: min(widget.decoration!.constraints!.minHeight, maxHeight),
          maxHeight: maxHeight,
        );
      }
      return constraints;
    }

    var container = BlocProvider.value(
        value: customSearchViewCubit!,
        child: BlocBuilder<CustomSearchViewCubit, FlowState>(
            builder: (context, state) {
              return state is LoadingState
                  ? Container()
                  : Material(
                  elevation: widget.decoration!.elevation,
                  color: widget.decoration!.color,
                  shape: widget.decoration!.shape,
                  borderRadius: widget.decoration!.borderRadius,
                  shadowColor: widget.decoration!.shadowColor,
                  clipBehavior: widget.decoration!.clipBehavior,
                  child:ConstrainedBox(
                    constraints: (customSearchViewCubit?.suggestions?.isEmpty??false)
                        ? const BoxConstraints(
                        maxHeight: 0, maxWidth: 0, minWidth: 0, minHeight: 0)
                        : getBoxConstrains(),
                    child: animationChild,
                  ) );
            }));

    return container;
  }

  Widget createSuggestionsWidget() {
    Widget child = BlocBuilder<CustomSearchViewCubit, FlowState>(
    //  buildWhen: (prev, current) => current is ContentState,
      builder: (context, state) {
        return Scrollbar(
          thumbVisibility: true,
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.fromSearch! && (customSearchViewCubit?.suggestions?.isNotEmpty??false)
                  ? widget.currentSearchHeader!
                  : Container(),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    primary: false,
                    shrinkWrap: true,
                    keyboardDismissBehavior: widget.hideKeyboardOnDrag
                        ? ScrollViewKeyboardDismissBehavior.onDrag
                        : ScrollViewKeyboardDismissBehavior.manual,
                    controller: _scrollController,
                    reverse: false,
                    children: List.generate(
                        (customSearchViewCubit?.suggestions?.length??0), (index) {
                      final suggestion = customSearchViewCubit!.suggestions!
                          .elementAt(index);
                      final focusNode = customSearchViewCubit!.focusNodes[index];

                      return InkWell(
                        focusColor: Theme
                            .of(context)
                            .hoverColor,
                        focusNode: focusNode,
                        child: widget.itemBuilder!(
                            context, suggestion, onRemoveItem),
                        onTap: () {
                          widget.giveTextFieldFocus();
                          widget.onSuggestionSelected!(suggestion);
                        },
                      );
                    }),
                  )),
            ],
          ),
        );
      },
    );

    if (widget.decoration!.hasScrollbar) {
      child = Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: child,
      );
    }

    return child;
  }
}

class SuggestionsBoxDecoration {
  final double elevation;
  final Color color;
  final ShapeBorder? shape;
  final bool hasScrollbar;
  final BorderRadius? borderRadius;
  final Color shadowColor;
  final BoxConstraints? constraints;
  final double offsetX;
  final Clip clipBehavior;

  const SuggestionsBoxDecoration({this.elevation = 10.0,
    this.color = Colors.white,
    this.shape,
    this.hasScrollbar = true,
    this.borderRadius,
    this.shadowColor = Colors.white,
    this.constraints,
    this.clipBehavior = Clip.none,
    this.offsetX = 0.0});
}

class SearchTextFormFieldConfiguration<T> {
  final Function? suffixIconOnClick;

  final TextEditingController? controller;

  final FocusNode? focusNode;

  final TextStyle? style;

  final TextAlign textAlign;

  final TextDirection? textDirection;

  final TextAlignVertical? textAlignVertical;

  final bool enabled;

  final bool enableSuggestions;

  final TextInputType keyboardType;

  final bool autofocus;

  final List<TextInputFormatter>? inputFormatters;

  final bool autocorrect;

  final int? maxLines;

  final int? minLines;

  final int? maxLength;

  final MaxLengthEnforcement? maxLengthEnforcement;

  final bool obscureText;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onSubmitted;

  final Color? cursorColor;

  final Radius? cursorRadius;

  final double cursorWidth;

  final Brightness? keyboardAppearance;

  final VoidCallback? onEditingComplete;

  final GestureTapCallback? onTap;

  final EdgeInsets scrollPadding;

  final TextCapitalization textCapitalization;

  final TextInputAction? textInputAction;

  final bool enableInteractiveSelection;

  final SuggestionsCallback<T>? suggestionsCallback;

  const SearchTextFormFieldConfiguration({this.suffixIconOnClick,
    this.style,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.maxLengthEnforcement,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.textAlignVertical,
    this.autocorrect = true,
    this.inputFormatters,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.enableSuggestions = true,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.cursorColor,
    this.cursorRadius,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.cursorWidth = 2.0,
    this.keyboardAppearance,
    this.onEditingComplete,
    this.onTap,
    this.textDirection,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.suggestionsCallback});

  SearchTextFormFieldConfiguration<T> copyWith({Function? suffixIconOnClick,
    TextStyle? style,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool? obscureText,
    MaxLengthEnforcement? maxLengthEnforcement,
    int? maxLength,
    int? maxLines,
    int? minLines,
    bool? autocorrect,
    List<TextInputFormatter>? inputFormatters,
    bool? autofocus,
    TextInputType? keyboardType,
    bool? enabled,
    bool? enableSuggestions,
    TextAlign? textAlign,
    FocusNode? focusNode,
    Color? cursorColor,
    TextAlignVertical? textAlignVertical,
    Radius? cursorRadius,
    double? cursorWidth,
    Brightness? keyboardAppearance,
    VoidCallback? onEditingComplete,
    GestureTapCallback? onTap,
    EdgeInsets? scrollPadding,
    TextCapitalization? textCapitalization,
    TextDirection? textDirection,
    TextInputAction? textInputAction,
    bool? enableInteractiveSelection,
    SuggestionsCallback<T>? suggestionsCallback}) {
    return SearchTextFormFieldConfiguration(
        suffixIconOnClick: suffixIconOnClick ?? this.suffixIconOnClick,
        style: style ?? this.style,
        controller: controller ?? this.controller,
        onChanged: onChanged ?? this.onChanged,
        onSubmitted: onSubmitted ?? this.onSubmitted,
        obscureText: obscureText ?? this.obscureText,
        maxLengthEnforcement: maxLengthEnforcement ?? this.maxLengthEnforcement,
        maxLength: maxLength ?? this.maxLength,
        maxLines: maxLines ?? this.maxLines,
        minLines: minLines ?? this.minLines,
        autocorrect: autocorrect ?? this.autocorrect,
        inputFormatters: inputFormatters ?? this.inputFormatters,
        autofocus: autofocus ?? this.autofocus,
        keyboardType: keyboardType ?? this.keyboardType,
        enabled: enabled ?? this.enabled,
        enableSuggestions: enableSuggestions ?? this.enableSuggestions,
        textAlign: textAlign ?? this.textAlign,
        textAlignVertical: textAlignVertical ?? this.textAlignVertical,
        focusNode: focusNode ?? this.focusNode,
        cursorColor: cursorColor ?? this.cursorColor,
        cursorRadius: cursorRadius ?? this.cursorRadius,
        cursorWidth: cursorWidth ?? this.cursorWidth,
        keyboardAppearance: keyboardAppearance ?? this.keyboardAppearance,
        onEditingComplete: onEditingComplete ?? this.onEditingComplete,
        onTap: onTap ?? this.onTap,
        scrollPadding: scrollPadding ?? this.scrollPadding,
        textCapitalization: textCapitalization ?? this.textCapitalization,
        textInputAction: textInputAction ?? this.textInputAction,
        textDirection: textDirection ?? this.textDirection,
        enableInteractiveSelection: enableInteractiveSelection ??
            this.enableInteractiveSelection,
        suggestionsCallback: suggestionsCallback ?? this.suggestionsCallback);
  }
}

class _SearchSuggestionsBox {
  static const int waitMetricsTimeoutMillis = 1000;
  static const double minOverlaySpace = 64.0;

  final BuildContext context;

  OverlayEntry? _overlayEntry;

  bool isOpened = false;
  bool widgetMounted = true;
  double maxHeight = 300.0;
  double textBoxWidth = 100.0;
  double textBoxHeight = 100.0;
  double offsetY = 100.0;
  bool hideSuggestionBox = false;

  _SearchSuggestionsBox(this.context);

  void openOverlay() {
    if (isOpened) return;
    assert(_overlayEntry != null);
    resize();
    Overlay.of(context).insert(_overlayEntry!);
    isOpened = true;
  }

  void closeOverlay() {
    if (!isOpened) return;
    assert(_overlayEntry != null);
    _overlayEntry!.remove();
    isOpened = false;
  }

  void toggleOverlay() {
    if (isOpened) {
      closeOverlay();
    } else {
      openOverlay();
    }
  }

  MediaQuery? _findRootMediaQuery() {
    MediaQuery? rootMediaQuery;
    context.visitAncestorElements((element) {
      if (element.widget is MediaQuery) {
        rootMediaQuery = element.widget as MediaQuery;
      }
      return true;
    });

    return rootMediaQuery;
  }

  Future<bool> _waitChangeMetrics() async {
    if (widgetMounted) {
      EdgeInsets initial = MediaQuery
          .of(context)
          .viewInsets;
      MediaQuery? initialRootMediaQuery = _findRootMediaQuery();

      int timer = 0;
      while (widgetMounted && timer < waitMetricsTimeoutMillis) {
        await Future<void>.delayed(const Duration(milliseconds: 170));
        timer += 170;

        if (widgetMounted &&
            (MediaQuery
                .of(context)
                .viewInsets != initial ||
                _findRootMediaQuery() != initialRootMediaQuery)) {
          return true;
        }
      }
    }

    return false;
  }

  void resize() {
    if (widgetMounted) {
      _adjustMaxHeightAndOrientation();
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _adjustMaxHeightAndOrientation() {
    CustomSearchView widget = context.widget as CustomSearchView;

    RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || box.hasSize == false) {
      return;
    }

    textBoxWidth = box.size.width;
    textBoxHeight = box.size.height;

    double textBoxAbsY = box
        .localToGlobal(Offset.zero)
        .dy;
    offsetY = box
        .localToGlobal(Offset.zero)
        .dy;

    double windowHeight = MediaQuery
        .of(context)
        .size
        .height;

    MediaQuery rootMediaQuery = _findRootMediaQuery()!;

    double keyboardHeight = rootMediaQuery.data.viewInsets.bottom;

    double maxHDesired =
    _calculateMaxHeight(
        box, widget, windowHeight, rootMediaQuery, keyboardHeight, textBoxAbsY);

    if (maxHDesired >= minOverlaySpace) {
      maxHeight = maxHDesired;
    } else {
      double maxHFlipped = _calculateMaxHeight(
          box, widget, windowHeight, rootMediaQuery, keyboardHeight,
          textBoxAbsY);
      if (maxHFlipped > maxHDesired) {
        maxHeight = maxHFlipped;
      }
    }

    if (maxHeight < 0) maxHeight = 0;
  }

  double _calculateMaxHeight(RenderBox box, CustomSearchView widget,
      double windowHeight,
      MediaQuery rootMediaQuery, double keyboardHeight, double textBoxAbsY) {
    return _calculateMaxHeightDown(
        box, widget, windowHeight, rootMediaQuery, keyboardHeight, textBoxAbsY);
  }

  double _calculateMaxHeightDown(RenderBox box, CustomSearchView widget,
      double windowHeight,
      MediaQuery rootMediaQuery, double keyboardHeight, double textBoxAbsY) {
    double unsafeAreaHeight = keyboardHeight == 0 ? rootMediaQuery.data.padding
        .bottom : 0;

    return windowHeight -
        keyboardHeight -
        unsafeAreaHeight -
        textBoxHeight -
        textBoxAbsY -
        2 * widget.suggestionsBoxVerticalOffset;
  }

  Future<void> onChangeMetrics() async {
    if (await _waitChangeMetrics()) {
      resize();
    }
  }
}

class SearchSuggestionsBoxController {
  _SearchSuggestionsBox? _suggestionsBox;
  FocusNode? _effectiveFocusNode;

  void open() {
    _effectiveFocusNode?.requestFocus();
  }

  bool isOpened() {
    return _suggestionsBox?.isOpened ?? false;
  }

  void close() {
    _effectiveFocusNode?.unfocus();
  }

  void toggle() {
    if (_suggestionsBox?.isOpened ?? false) {
      close();
    } else {
      open();
    }
  }

  void resize() {
    _suggestionsBox!.resize();
  }
}

