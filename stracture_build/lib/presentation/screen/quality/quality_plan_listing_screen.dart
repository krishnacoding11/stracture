import 'package:field/bloc/quality/quality_plan_listing_cubit.dart';
import 'package:field/bloc/quality/quality_plan_listing_state.dart';
import 'package:field/data/model/quality_plan_list_vo.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/screen/quality/quality_plan_location_listing_screen.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/event_analytics.dart';
import '../../../bloc/sitetask/sitetask_state.dart';
import '../../../bloc/sitetask/unique_value_cubit.dart';
import '../../../enums.dart';
import '../../../injection_container.dart';
import '../../../widgets/custom_search_view/custom_search_view.dart';
import '../../../widgets/pagination_view/pagination_view.dart';
import '../../../widgets/progressbar.dart';
import '../../../widgets/tooltip_dialog/tooltip_dialog.dart';
import '../../base/state_renderer/state_render_impl.dart';
import '../../managers/color_manager.dart';
import '../../managers/font_manager.dart';

class QualityListingScreen extends StatefulWidget {
  const QualityListingScreen({Key? key}) : super(key: key);

  @override
  State<QualityListingScreen> createState() => _QualityListingScreenState();
}

class _QualityListingScreenState extends State<QualityListingScreen> {
  late QualityPlanListingCubit qualityPlanListingCubit;
  late UniqueValueCubit _uniqueValueCubit;
  late final ScrollController paginationScrollController;
  late final ScrollController animatedScrollController;
  final FocusNode _searchFocusNode = FocusNode();
  late ScrollController scrollController;
  final TooltipController _tooltipController = TooltipController();
  final TextEditingController _searchLocationController = TextEditingController();
  bool isExpand = false;

  final TextEditingController _searchQualityPlanController = TextEditingController();

  @override
  void initState() {
    scrollController = ScrollController();
    qualityPlanListingCubit = getIt<QualityPlanListingCubit>();
    _uniqueValueCubit = getIt<UniqueValueCubit>();
    paginationScrollController = ScrollController();
    animatedScrollController = getIt<ScrollController>();
    qualityPlanListingCubit.getRecentQualityPlan(true);
    _scrollingAnimation();
    _forwardAnimation();

    super.initState();
    FireBaseEventAnalytics.setCurrentScreen(FireBaseFromScreen.quality.value);
  }

  _scrollingAnimation() {
    paginationScrollController.addListener(() {
      _animationController();
    });
    scrollController.addListener(() {
      _filterAnimationController();
    });
  }

  _animationController() {
    if (!Utility.isTablet) {
      if (paginationScrollController.position.userScrollDirection == ScrollDirection.reverse) {
        _reverseAnimation();
      }
    }
    if (paginationScrollController.position.userScrollDirection == ScrollDirection.forward) {
      _forwardAnimation();
    }
  }

  _filterAnimationController() {
    if (!Utility.isTablet) {
      if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        _reverseAnimation();
      }
    }
    if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
      _forwardAnimation();
    }
  }

  _reverseAnimation() {
    if(animatedScrollController.hasClients) {
      animatedScrollController.animateTo(
        animatedScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.linear,
      );
    }
  }

  _forwardAnimation() {
    if(animatedScrollController.hasClients) {
      animatedScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.linear,
      );
    }
  }

  @override
  void dispose() {
    paginationScrollController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Utility.isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    return MultiBlocProvider(
        providers: [
          BlocProvider<QualityPlanListingCubit>(create: (_) => qualityPlanListingCubit),
          BlocProvider<UniqueValueCubit>(create: (_) => _uniqueValueCubit)
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<QualityPlanListingCubit, FlowState>(
              listenWhen: (previous, current) => current is ScrollState,
              listener: (context, state) {
                if (state is ScrollState && state.position! > 0) {
                  if (paginationScrollController.hasClients) {
                    paginationScrollController.jumpTo(state.position!);
                  }
                  qualityPlanListingCubit.scrollPosition = 0;
                }
              },
            )
          ],
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
                color: AColors.white,
                child: Padding(
                    padding: (Utility.isTablet && (MediaQuery.of(context).orientation) == Orientation.landscape)
                        ? const EdgeInsetsDirectional.only(
                            start: 70.0,
                            end: 70.0,
                          )
                        : const EdgeInsets.all(18),
                    //   vertical: 5,
                    //   horizontal: 15,
                    // ),
                    child: Column(
                      children: [
                        if (Utility.isTablet)
                          const SizedBox(
                            height: 20,
                          ),
                        searchAndFilterWidget(),
                        const SizedBox(
                          height: 20,
                        ),
                        _qualityPlanListWidget(context),
                      ],
                    ))),
            endDrawerEnableOpenDragGesture: false,
          ),
        ));
  }

  Widget _qualityPlanListWidget(BuildContext context) {
    return BlocBuilder<QualityPlanListingCubit, FlowState>(builder: (_, state) {
      if (state is LoadingState || state is InitialState) {
        return const Center(
          child: ACircularProgress(
            key: Key("key_quality_plan_listing_progressbar"),
          ),
        );
      } else if (state is ErrorState) {
        return Expanded(
          child: Center(
            child: NormalTextWidget(state.message),
          ),
        );
      } else {
        return Expanded(
          child: BlocBuilder<UniqueValueCubit, String>(
            builder: (context, state) {
              return IgnorePointer(
                ignoring: !showList(this.context),
                child: Container(
                  color: showList(this.context) || qualityPlanListingCubit.qualityMode == QualityMode.searchMode
                      ? AColors.white
                      : AColors.iconGreyColor.withOpacity(0.4),
                  child: PaginationView<Data>(
                    key: !showList(context) || qualityPlanListingCubit.qualityMode == QualityMode.searchMode
                        ? Key(state)
                        : const PageStorageKey<String>("plan_listing"), // for scrool and search
                    //  key: qualityPlanListingCubit.currentPage==0?Key(state):const PageStorageKey<String>("plan_listing"),
                    shrinkWrap: true,
                    scrollController: paginationScrollController,
                    itemBuilder: (_, item, index) => _qualityListRowItemWidget(context, index, item),
                    pageFetch: _pageFetch,
                    pullToRefresh: true,
                    onError: (dynamic error) => Center(
                      child: NormalTextWidget(
                        context.toLocale!.error_message_something_wrong,
                        key: const Key("key_listview_error_widget"),
                      ),
                    ),
                    onEmpty: (qualityPlanListingCubit.isSubmitted && qualityPlanListingCubit.qualityMode == QualityMode.searchMode)
                        ? Center(
                            child: NormalTextWidget(context.toLocale!.no_matches_found),
                          )
                        : Center(
                            child: NormalTextWidget(
                              context.toLocale!.no_quality_data_available,
                              key: const Key("key_listview_empty_widget"),
                            ),
                          ),
                    bottomLoader: const Center(
                      child: ACircularProgress(
                        key: Key("key_listview_bottomLoader_widget"),
                      ),
                    ),
                    initialLoader: const Center(
                      child: ACircularProgress(
                        key: Key("key_listview_initialLoader_widget"),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
    });
  }

  _qualityListRowItemWidget(BuildContext context, int index, item) {
    return BlocBuilder<QualityPlanListingCubit, FlowState>(
      buildWhen: (previous, current) => current is RefreshPaginationItemState,
      builder: (context, state) {
        String lastUpdatedDate = qualityPlanListingCubit.getDateInProperFormat(item.lastupdatedate);
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 2, color: AColors.dividerColor),
            ),
          ),
          child: ListTile(
            title: NormalTextWidget(
              item.planTitle.replaceAll('', '\u200B') ?? "",
              fontWeight: AFontWight.semiBold,
              fontSize: 16.0,
              color: AColors.textColor,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.start,
            ),
            subtitle: Utility.isTablet
                ? null
                : _showTextWithDescription(
                    context.toLocale!.lbl_quality_updated,
                    lastUpdatedDate,
                  ),
            trailing: Utility.isTablet ? _showTabletTrailingView(item, lastUpdatedDate) : _showPhoneTrailingView(item),
            onTap: () {
              clearCurrentSearch();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LocationListingScreen(
                            qualityPlanData: item,
                          ))).then((value) {
                print(value);
                qualityPlanListingCubit.updateIndexData(value);
                qualityPlanListingCubit.qualityMode = QualityMode.searchMode;
              });
              FireBaseEventAnalytics.setEvent(FireBaseEventType.qualityPlanSelect, FireBaseFromScreen.quality, bIncludeProjectName: true);
            },
          ),
        );
      },
    );
  }

  _showTabletTrailingView(item, lastUpdatedDate) {
    return SizedBox(
      width: 220,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _setNormalTextWidget(
                    context.toLocale!.last_updated,
                    13.0,
                    AColors.iconGreyColor,
                  ),
                  _setNormalTextWidget(
                    lastUpdatedDate,
                    16.0,
                    AColors.textColor,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: _showCompletion(item),
          ),
          Expanded(
            flex: 1,
            child: _showCircularProgress(item),
          )
        ],
      ),
    );
  }

  _showPhoneTrailingView(item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _showCompletion(item),
        _showCircularProgress(item),
      ],
    );
  }

  _showCompletion(item) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: NormalTextWidget(
        '${item.percentageCompletion.toString()}%',
        fontWeight: AFontWight.medium,
        fontSize: 13.0,
        color: AColors.iconGreyColor,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  _showCircularProgress(item) {
    return ACircularProgress(
      color: AColors.lightGreenColor,
      strokeWidth: 7,
      progressValue: item.percentageCompletion / 100,
      backgroundColor: AColors.dividerColor,
    );
  }

  _showTextWithDescription(String txtTitle, String txtValue) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _setNormalTextWidget(
          txtTitle,
          13.0,
          AColors.iconGreyColor,
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 3.0),
            child: _setNormalTextWidget(
              txtValue,
              13.0,
              AColors.textColor,
            ),
          ),
        ),
      ],
    );
  }

  _setNormalTextWidget(txtName, fontSize, Color color) {
    return NormalTextWidget(
      txtName,
      fontWeight: AFontWight.medium,
      fontSize: fontSize,
      maxLines: 1,
      color: color,
      textAlign: TextAlign.left,
      overflow: TextOverflow.ellipsis,
    );
  }

  Future<List<Data>> _pageFetch(int offset) async {
    var items = isNetWorkConnected() ? await qualityPlanListingCubit.getQualityPlanList(offset) : null;
    return items ?? [];
  }

  Widget searchAndFilterWidget() {
    return BlocBuilder<QualityPlanListingCubit, FlowState>(
        buildWhen: (previous, current) => current is QualitySearchBarVisibleState,
        builder: (context, state) {
          if (state is QualitySearchBarVisibleState) {
            isExpand = state.isExpand;
          }
          return state is QualitySearchBarVisibleState && state.isExpand
              ? Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.max, children: [searchTaskWidget()])
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    (Utility.isTablet) ? searchBarWidget(Utility.isTablet) : const SizedBox.shrink(),
                    sortFilterWidget(),
                    (!Utility.isTablet)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [searchBarWidget(Utility.isTablet), filterWidget()],
                          )
                        : filterWidget()
                  ],
                );
        });
  }

  Widget searchTaskWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(3.0, 8.0, Utility.isTablet ? 8.0 : 3.0, 8.0),
          child: CustomSearchSuggestionView<Data>(
            key: const Key("searchBoxLocationList"),
            placeholder: context.toLocale!.search_quality_plan,
            textFieldConfiguration: SearchTextFormFieldConfiguration(
              autofocus: Utility.isTablet ? false : true,
              controller: _searchQualityPlanController,
              focusNode: _searchFocusNode,
              scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), //Fix focus issue in mobile ,
              textInputAction: TextInputAction.search,
              suffixIconOnClick: () {
                clearCurrentSearch();
                _uniqueValueCubit.updateValue();
              },
              onSubmitted: (value) async {
                context.closeKeyboard();
                if (value.trim().isNotEmpty) {
                  await qualityPlanListingCubit.addRecentQualityPlanList(qualityPlanTitle: value);
                  qualityPlanListingCubit.setSuggesion = true;
                  qualityPlanListingCubit.isSubmitted = true;
                  qualityPlanListingCubit.qualityMode = QualityMode.searchMode;
                  if (!_uniqueValueCubit.isClosed) _uniqueValueCubit.updateValue();
                } else {
                  qualityPlanListingCubit.isSubmitted = false;
                  qualityPlanListingCubit.searchString = "";
                  _uniqueValueCubit.updateValue();
                }
              },
            ),
            suggestionsCallback: (value) async {
              qualityPlanListingCubit.searchString = value.trim();
              if (showList(context)) {
                return [];
              } else {
                if (value.isEmpty && showList(context)) {
                  return qualityPlanListingCubit.recentList;
                } else {
                  if (value.trim().length >= 3) {
                    qualityPlanListingCubit.setSearchMode = QualityPlanSearchMode.suggested;
                    return await qualityPlanListingCubit.getSuggestedSearchList(value.toLowerCase(), isFromSuggestion: true, offset: 0);
                  } else if (value.trim().length <= 2) {
                    qualityPlanListingCubit.setSearchMode = QualityPlanSearchMode.recent;
                    return qualityPlanListingCubit.recentList;
                  } else {
                    return [];
                  }
                }
              }
            },
            currentSearchHeader: BlocProvider.value(
                value: qualityPlanListingCubit,
                child: BlocBuilder<QualityPlanListingCubit, FlowState>(
                    buildWhen: (prev, current) => current is QualityPlanSearchModeState,
                    builder: (context, state) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NormalTextWidget(
                          qualityPlanListingCubit.searchMode == QualityPlanSearchMode.recent
                              ? context.toLocale!.text_recent_searches
                              : context.toLocale!.text_suggested_searches,
                          fontWeight: AFontWight.regular,
                          fontSize: 13,
                          color: AColors.iconGreyColor,
                        ),
                      );
                    })),
            itemBuilder: (context, suggestion, suggestionsCallback) {
              return Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 18.0, end: 16.0, top: 0.0, bottom: 0.0),
                      child: qualityPlanListingCubit.searchMode == QualityPlanSearchMode.suggested
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: NormalTextWidget(
                                    suggestion.planTitle!,
                                    fontSize: 15,
                                    fontWeight: AFontWight.medium,
                                    overflow: TextOverflow.ellipsis,
                                    color: AColors.textColor,
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time_outlined,
                                        color: AColors.lightGreyColor,
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Flexible(
                                        child: NormalTextWidget(
                                          suggestion.planTitle!,
                                          fontWeight: AFontWight.light,
                                          fontSize: 15,
                                          overflow: TextOverflow.ellipsis,
                                          color: AColors.textColor,
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await qualityPlanListingCubit.removeQualityFromRecentSearch(newSearch: suggestion.planTitle!);
                                    await suggestionsCallback();
                                    if (qualityPlanListingCubit.recentList.isEmpty) {
                                      _searchQualityPlanController.clear();
                                      _searchFocusNode.unfocus();
                                    }
                                  },
                                  child: Icon(
                                    Icons.clear,
                                    color: AColors.iconGreyColor,
                                    size: 24,
                                  ),
                                )
                              ],
                            ),
                    ),
                  )
                ],
              );
            },
            onSuggestionSelected: (suggestion) async {
              _searchQualityPlanController.text = suggestion.planTitle!;
              qualityPlanListingCubit.searchString = suggestion.planTitle!;
              qualityPlanListingCubit.setSuggesion = true;
              qualityPlanListingCubit.isSubmitted = true;
              qualityPlanListingCubit.qualityMode = QualityMode.searchMode;
              _uniqueValueCubit.updateValue();
              if (qualityPlanListingCubit.searchMode == QualityPlanSearchMode.suggested) {
                if (qualityPlanListingCubit.searchString.trim().isNotEmpty) {
                  await qualityPlanListingCubit.addRecentQualityPlanList(qualityPlanTitle: suggestion.planTitle);
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget searchBarWidget(bool isTablet) {
    return isTablet
        ? searchTaskWidget()
        : IconButton(
            padding: const EdgeInsetsDirectional.only(start: 16.0, top: 8.0, bottom: 8.0),
            constraints: const BoxConstraints(),
            color: AColors.iconGreyColor,
            onPressed: () {
              qualityPlanListingCubit.updateSearchBarVisibleState(true);
            },
            icon: const Icon(Icons.search),
          );
  }

  Widget sortFilterWidget() {
    return BlocBuilder<QualityPlanListingCubit, FlowState>(
        buildWhen: (previous, current) => current is SortChangeState,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8.0, end: 8.0),
                child: TooltipDialog(
                  toolTipContent: Container(
                    constraints: const BoxConstraints(minWidth: 100, maxWidth: 140, minHeight: 70, maxHeight: 120),
                    child: Column(
                      children: <Widget>[
                        _getTile(ListSortField.lastUpdatedDate),
                        const Divider(height: 1.0),
                        _getTile(ListSortField.title),
                      ],
                    ),
                  ),
                  toolTipController: _tooltipController,
                  child: InkWell(
                    onTap: () {
                      qualityPlanListingCubit.qualityMode = QualityMode.searchMode;
                      _tooltipController.showTooltipDialog();
                    },
                    child: NormalTextWidget(
                      getSortFieldName(qualityPlanListingCubit.sortValue),
                      fontSize: 16,
                      fontWeight: AFontWight.medium,
                      color: AColors.iconGreyColor,
                      key: const Key("key_qualityPlanListing_sort_field_widget"),
                    ),
                  ),
                ),
              ),
              IconButton(
                key: const Key("key_qualityPlanListing_sort_order_widget"),
                icon: Icon(
                  (qualityPlanListingCubit.sortOrder) ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  color: AColors.iconGreyColor,
                ),
                onPressed: () {
                  //set the below line for case ASITEFLD-2329
                  qualityPlanListingCubit.qualityMode = QualityMode.searchMode;
                  qualityPlanListingCubit.setSortOrder = !qualityPlanListingCubit.sortOrder;
                  _uniqueValueCubit.updateValue();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          );
        });
  }

  Widget filterWidget() {
    return Container();
    // Commenting this code against ASITEFLD-3190, as currently we are not performing any action on click of Filter, so hiding it for now.
    // return BlocBuilder<QualityPlanListingCubit, FlowState>(
    //     buildWhen: (prev, current) => current is ApplyFilterState,
    //     builder: (context, state) {
    //       bool currentApplyFilter = false;
    //       if (state is ApplyFilterState && state.isFilterApply) {
    //         currentApplyFilter = true;
    //       }
    //       return IconButton(
    //         padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
    //         constraints: const BoxConstraints(),
    //         color: currentApplyFilter ? AColors.themeBlueColor : AColors.iconGreyColor,
    //         onPressed: () {
    //           /*onFilterButtonClick()*/
    //         },
    //         icon: currentApplyFilter ? const Icon(Icons.filter_alt) : const Icon(Icons.filter_alt_outlined),
    //       );
    //     });
  }

  Widget _getTile(ListSortField data) {
    return ListTile(
        title: NormalTextWidget(
          getSortFieldName(data),
          fontWeight: AFontWight.regular,
          fontSize: 16.0,
          textAlign: TextAlign.left,
        ),
        onTap: () {
          _tooltipController.hideTooltipDialog();
          qualityPlanListingCubit.setSortValue = data;
          _uniqueValueCubit.updateValue();
        });
  }

  String getSortFieldName(ListSortField item) {
    switch (item) {
      case ListSortField.lastUpdatedDate:
        return context.toLocale!.last_updated;
      case ListSortField.title:
        return context.toLocale!.name;
      default:
        return context.toLocale!.last_updated;
    }
  }

  bool showList(BuildContext context) {
    return !_searchFocusNode.hasFocus;
  }

  Widget currentSearchListView(item) {
    return _qualityListRowItemWidget(context, 0, item);
  }

  clearCurrentSearch() {
    context.closeKeyboard();
    _searchQualityPlanController.clear();
    qualityPlanListingCubit.onClearSearch();
    qualityPlanListingCubit.searchString = "";
    _searchFocusNode.unfocus();
    qualityPlanListingCubit.setSuggesion = true;
    qualityPlanListingCubit.isSubmitted = false;
    if (!_uniqueValueCubit.isClosed) _uniqueValueCubit.updateValue();
    qualityPlanListingCubit.qualityMode = QualityMode.listMode;
    qualityPlanListingCubit.updateSearchBarVisibleState(false);
  }
}
