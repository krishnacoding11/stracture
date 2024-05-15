import 'package:pdftron_flutter/pdftron_flutter.dart';

Config getSiteTabConfig() {
  Config config = Config()
    ..multiTabEnabled = false
    ..hideTopAppNavBar = true
    ..hideBottomToolbar = true
    ..hideTopToolbars = true
    ..continuousAnnotationEditing = false
    ..pageIndicatorEnabled = false
    ..rememberLastUsedTool = false
    ..tabletLayoutEnabled = false
    ..hideAnnotationToolbarSwitcher = true
    ..autoSaveEnabled = false
    ..hidePresetBar = true
    ..hideScrollbars = true
    ..longPressMenuEnabled = false
    ..singleLineToolbar = false
    ..layoutMode = LayoutModes.continuous
    ..fitMode = FitModes.fitPage
    ..pageNumberIndicatorAlwaysVisible = false
    ..initialPageNumber = 1
    ..documentSliderEnabled = false;

  return config;
}

Config getFilePreviewConfig() {
  Config config = Config()
    ..multiTabEnabled = false
    ..hideTopAppNavBar = false
    ..hideBottomToolbar = true
    ..hideTopToolbars = true
    ..continuousAnnotationEditing = false
    ..pageIndicatorEnabled = false
    ..rememberLastUsedTool = false
    ..tabletLayoutEnabled = false
    ..hideAnnotationToolbarSwitcher = true
    ..autoSaveEnabled = false
    ..hidePresetBar = true
    ..singleLineToolbar = true
    ..hideScrollbars = true
    ..longPressMenuEnabled = false
    ..singleLineToolbar = false
    ..layoutMode = LayoutModes.continuous
    ..fitMode = FitModes.fitPage
    ..pageNumberIndicatorAlwaysVisible = false
    ..initialPageNumber = 1;

  return config;
}
