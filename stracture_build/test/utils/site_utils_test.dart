import 'dart:collection';

import 'package:field/data/model/site_location.dart';
import 'package:field/utils/site_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/fixture_reader.dart';

void main() {
  List<SiteLocation>? siteLocationList = [];
  LinkedHashMap<String, List<SiteLocation>> mapSiteLocation = LinkedHashMap();
  String folderId = "05083618\$\$2hfy9D";
  setUp(() {
    siteLocationList = SiteLocation.jsonToList(fixture("site_location.json"));
    mapSiteLocation[folderId] = siteLocationList!;
  });

  test('getLocationFromLocationId', () {
    SiteLocation? siteLocation =
        SiteUtility.getLocationFromLocationId(25016, siteLocationList!);
    expect(25016, siteLocation!.pfLocationTreeDetail!.locationId);
  });
  test('getLocationFromLocationId', () {
    SiteLocation? siteLocation = SiteUtility.getLocationFromLocationId(
        25016, null,
        mapSiteLocation: mapSiteLocation);
    expect(25016, siteLocation!.pfLocationTreeDetail!.locationId);
  });
  test('getLocationFromAnnotationId', () async {
    String annotationId = "d94fe932-40b2-abd6-5500-2dc2dd7f7bd0";
    SiteLocation? siteLocation = await SiteUtility.getLocationFromAnnotationId(
        annotationId, siteLocationList,
        mapSiteLocation: mapSiteLocation);
    expect(annotationId, siteLocation!.pfLocationTreeDetail!.annotationId);
  });

  test('Is Location Has Plan', () {
    expect(true, SiteUtility.isLocationHasPlan(siteLocationList![0]));
  });

  test('Is Location Has No Plan', () {
    expect(false, SiteUtility.isLocationHasPlan(siteLocationList![1]));
  });
}
