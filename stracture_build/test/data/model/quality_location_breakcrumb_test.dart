import 'package:field/data/model/quality_location_breadcrumb.dart';
import 'package:field/data/model/quality_plan_location_listing_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QualityLocationBreadcrumb', () {
    test('QualityLocationBreadcrumb.fromJson should create object from JSON response', () {
      final jsonResponse = '''
        {
          "projectPlanDetailsVO": {
            "projectID": "proj1",
            "planID": "plan1",
            "projectName": "Project 1",
            "planName": "Plan 1",
            "perCompletion": 50,
            "generateURI": true
          },
          "locations": [
            {
              "locationID": "loc1",
              "locationName": "Location 1"
            },
            {
              "locationID": "loc2",
              "locationName": "Location 2"
            }
          ],
          "generateURI": true
        }
      ''';

      final qualityLocationBreadcrumb = QualityLocationBreadcrumb.fromJson(jsonResponse);

      expect(qualityLocationBreadcrumb.projectPlanDetailsVO?.projectID, equals('proj1'));
      expect(qualityLocationBreadcrumb.projectPlanDetailsVO?.planID, equals('plan1'));
      expect(qualityLocationBreadcrumb.projectPlanDetailsVO?.projectName, equals('Project 1'));
      expect(qualityLocationBreadcrumb.projectPlanDetailsVO?.planName, equals('Plan 1'));
      expect(qualityLocationBreadcrumb.projectPlanDetailsVO?.perCompletion, equals(50));
      expect(qualityLocationBreadcrumb.projectPlanDetailsVO?.generateURI, isTrue);

      expect(qualityLocationBreadcrumb.locations?.length, equals(2));

      expect(qualityLocationBreadcrumb.generateURI, isTrue);
    });

    test('QualityLocationBreadcrumb.copyWith should create a copy of the object', () {
      final original = QualityLocationBreadcrumb(
        projectPlanDetailsVO: ProjectPlanDetailsVo(projectID: 'proj1', planID: 'plan1', projectName: 'Project 1', planName: 'Plan 1', perCompletion: 50, generateURI: true),
        locations: [Locations(siteLocationId: 'loc1', locationPath: 'Location 1')],
        generateURI: true,
      );

      final copied = original.copyWith(locations: [Locations(siteLocationId: 'loc2', locationPath: 'Location 2')]);

      expect(copied.projectPlanDetailsVO?.projectID, equals('proj1'));
      expect(copied.projectPlanDetailsVO?.planID, equals('plan1'));
      expect(copied.projectPlanDetailsVO?.projectName, equals('Project 1'));
      expect(copied.projectPlanDetailsVO?.planName, equals('Plan 1'));
      expect(copied.projectPlanDetailsVO?.perCompletion, equals(50));
      expect(copied.projectPlanDetailsVO?.generateURI, isTrue);

      expect(copied.locations?.length, equals(1));
      expect(copied.locations?[0].siteLocationId, equals('loc2'));
      expect(copied.locations?[0].locationPath, equals('Location 2'));

      expect(copied.generateURI, isTrue);
    });

    test('QualityLocationBreadcrumb.toJson should return correct JSON representation', () {
      final qualityLocationBreadcrumb = QualityLocationBreadcrumb(
        projectPlanDetailsVO: ProjectPlanDetailsVo(
          projectID: 'proj1',
          planID: 'plan1',
          projectName: 'Project 1',
          planName: 'Plan 1',
          perCompletion: 50,
          generateURI: true,
        ),
        locations: [
          Locations(siteLocationId: 'loc1', locationPath: 'Location 1'),
          Locations(siteLocationId: 'loc2', locationPath: 'Location 2'),
        ],
        generateURI: true,
      );

      final json = qualityLocationBreadcrumb.toJson();

      expect(json['projectPlanDetailsVO']['projectID'], equals('proj1'));
      expect(json['projectPlanDetailsVO']['planID'], equals('plan1'));
      expect(json['projectPlanDetailsVO']['projectName'], equals('Project 1'));
      expect(json['projectPlanDetailsVO']['planName'], equals('Plan 1'));
      expect(json['projectPlanDetailsVO']['perCompletion'], equals(50));
      expect(json['projectPlanDetailsVO']['generateURI'], isTrue);

      expect(json['locations'], isList);
      expect(json['locations'][0]['locationID'], equals(null));
      expect(json['locations'][0]['locationName'], equals(null));
      expect(json['locations'][1]['locationID'], equals(null));
      expect(json['locations'][1]['locationName'], equals(null));

      expect(json['generateURI'], isTrue);
    });

    test('copyWith should return a new ProjectPlanDetailsVo with updated properties', () {
      // Arrange
      final projectID1 = 'project_id_1';
      final planID1 = 'plan_id_1';
      final projectName1 = 'project_name_1';
      final planName1 = 'plan_name_1';
      final perCompletion1 = 50;
      final generateURI1 = true;
      final projectPlanDetailsVo1 = ProjectPlanDetailsVo(
        projectID: projectID1,
        planID: planID1,
        projectName: projectName1,
        planName: planName1,
        perCompletion: perCompletion1,
        generateURI: generateURI1,
      );

      final projectID2 = 'project_id_2';
      final planID2 = 'plan_id_2';
      final projectName2 = 'project_name_2';
      final planName2 = 'plan_name_2';
      final perCompletion2 = 75;
      final generateURI2 = false;

      // Act
      final projectPlanDetailsVo2 = projectPlanDetailsVo1.copyWith(
        projectID: projectID2,
        planID: planID2,
        projectName: projectName2,
        planName: planName2,
        perCompletion: perCompletion2,
        generateURI: generateURI2,
      );

      // Assert
      expect(projectPlanDetailsVo2.projectID, equals(projectID2));
      expect(projectPlanDetailsVo2.planID, equals(planID2));
      expect(projectPlanDetailsVo2.projectName, equals(projectName2));
      expect(projectPlanDetailsVo2.planName, equals(planName2));
      expect(projectPlanDetailsVo2.perCompletion, equals(perCompletion2));
      expect(projectPlanDetailsVo2.generateURI, equals(generateURI2));

      // Ensure the original object remains unchanged
      expect(projectPlanDetailsVo1.projectID, equals(projectID1));
      expect(projectPlanDetailsVo1.planID, equals(planID1));
      expect(projectPlanDetailsVo1.projectName, equals(projectName1));
      expect(projectPlanDetailsVo1.planName, equals(planName1));
      expect(projectPlanDetailsVo1.perCompletion, equals(perCompletion1));
      expect(projectPlanDetailsVo1.generateURI, equals(generateURI1));
    });

    test('copyWith should return a new QualityLocationBreadcrumb object with updated properties', () {
      // Arrange
      final projectPlanDetailsVO = ProjectPlanDetailsVo(
        projectID: 'project_id_1',
        planID: 'plan_id_1',
        projectName: 'Project 1',
        planName: 'Plan 1',
        perCompletion: 50,
        generateURI: true,
      );

      final locations = [
        Locations(
          siteLocationId: 'site_location_id_1',
          qiLocationId: 'qi_location_id_1',
          hasLocation: true,
          // Add other properties here as needed
        ),
        // Add more location objects as needed
      ];

      final generateURI = false;

      final qualityLocationBreadcrumb = QualityLocationBreadcrumb(
        projectPlanDetailsVO: projectPlanDetailsVO,
        locations: locations,
        generateURI: generateURI,
      );

      // Act
      final updatedProjectPlanDetailsVO = ProjectPlanDetailsVo(
        projectID: 'project_id_2',
        planID: 'plan_id_2',
        projectName: 'Project 2',
        planName: 'Plan 2',
        perCompletion: 75,
        generateURI: false,
      );

      final updatedLocations = [
        Locations(
          siteLocationId: 'site_location_id_2',
          qiLocationId: 'qi_location_id_2',
          hasLocation: false,
          // Add other properties here as needed
        ),
        // Add more location objects as needed
      ];

      final updatedGenerateURI = true;

      final updatedQualityLocationBreadcrumb = qualityLocationBreadcrumb.copyWith(
        projectPlanDetailsVO: updatedProjectPlanDetailsVO,
        locations: updatedLocations,
        generateURI: updatedGenerateURI,
      );

      // Assert
      expect(updatedQualityLocationBreadcrumb.projectPlanDetailsVO, equals(updatedProjectPlanDetailsVO));
      expect(updatedQualityLocationBreadcrumb.locations, equals(updatedLocations));
      expect(updatedQualityLocationBreadcrumb.generateURI, equals(updatedGenerateURI));

      // Ensure the original object remains unchanged
      expect(qualityLocationBreadcrumb.projectPlanDetailsVO, equals(projectPlanDetailsVO));
      expect(qualityLocationBreadcrumb.locations, equals(locations));
      expect(qualityLocationBreadcrumb.generateURI, equals(generateURI));
    });

    test('copyWith should return a new QualityLocationBreadcrumb object with the same properties if nothing is updated', () {
      // Arrange
      final projectPlanDetailsVO = ProjectPlanDetailsVo(
        projectID: 'project_id_1',
        planID: 'plan_id_1',
        projectName: 'Project 1',
        planName: 'Plan 1',
        perCompletion: 50,
        generateURI: true,
      );

      final locations = [
        Locations(
          siteLocationId: 'site_location_id_1',
          qiLocationId: 'qi_location_id_1',
          hasLocation: true,
          // Add other properties here as needed
        ),
        // Add more location objects as needed
      ];

      final generateURI = false;

      final qualityLocationBreadcrumb = QualityLocationBreadcrumb(
        projectPlanDetailsVO: projectPlanDetailsVO,
        locations: locations,
        generateURI: generateURI,
      );

      // Act
      final updatedQualityLocationBreadcrumb = qualityLocationBreadcrumb.copyWith();

      // Assert
      expect(updatedQualityLocationBreadcrumb.projectPlanDetailsVO, equals(projectPlanDetailsVO));
      expect(updatedQualityLocationBreadcrumb.locations, equals(locations));
      expect(updatedQualityLocationBreadcrumb.generateURI, equals(generateURI));

      // Ensure the original object remains unchanged
      expect(qualityLocationBreadcrumb.projectPlanDetailsVO, equals(projectPlanDetailsVO));
      expect(qualityLocationBreadcrumb.locations, equals(locations));
      expect(qualityLocationBreadcrumb.generateURI, equals(generateURI));
    });

    test('copyWith should return a new ProjectPlanDetailsVo object with updated properties', () {
      // Arrange
      final projectID = 'project_id_1';
      final planID = 'plan_id_1';
      final projectName = 'Project 1';
      final planName = 'Plan 1';
      final perCompletion = 50;
      final generateURI = true;

      final projectPlanDetails = ProjectPlanDetailsVo(
        projectID: projectID,
        planID: planID,
        projectName: projectName,
        planName: planName,
        perCompletion: perCompletion,
        generateURI: generateURI,
      );

      // Act
      final updatedProjectID = 'project_id_2';
      final updatedPlanID = 'plan_id_2';
      final updatedProjectName = 'Project 2';
      final updatedPlanName = 'Plan 2';
      final updatedPerCompletion = 75;
      final updatedGenerateURI = false;

      final updatedProjectPlanDetails = projectPlanDetails.copyWith(
        projectID: updatedProjectID,
        planID: updatedPlanID,
        projectName: updatedProjectName,
        planName: updatedPlanName,
        perCompletion: updatedPerCompletion,
        generateURI: updatedGenerateURI,
      );

      // Assert
      expect(updatedProjectPlanDetails.projectID, equals(updatedProjectID));
      expect(updatedProjectPlanDetails.planID, equals(updatedPlanID));
      expect(updatedProjectPlanDetails.projectName, equals(updatedProjectName));
      expect(updatedProjectPlanDetails.planName, equals(updatedPlanName));
      expect(updatedProjectPlanDetails.perCompletion, equals(updatedPerCompletion));
      expect(updatedProjectPlanDetails.generateURI, equals(updatedGenerateURI));

      // Ensure the original object remains unchanged
      expect(projectPlanDetails.projectID, equals(projectID));
      expect(projectPlanDetails.planID, equals(planID));
      expect(projectPlanDetails.projectName, equals(projectName));
      expect(projectPlanDetails.planName, equals(planName));
      expect(projectPlanDetails.perCompletion, equals(perCompletion));
      expect(projectPlanDetails.generateURI, equals(generateURI));
    });

    test('copyWith should return a new ProjectPlanDetailsVo object with the same properties if nothing is updated', () {
      // Arrange
      final projectID = 'project_id_1';
      final planID = 'plan_id_1';
      final projectName = 'Project 1';
      final planName = 'Plan 1';
      final perCompletion = 50;
      final generateURI = true;

      final projectPlanDetails = ProjectPlanDetailsVo(
        projectID: projectID,
        planID: planID,
        projectName: projectName,
        planName: planName,
        perCompletion: perCompletion,
        generateURI: generateURI,
      );

      // Act
      final updatedProjectPlanDetails = projectPlanDetails.copyWith();

      // Assert
      expect(updatedProjectPlanDetails.projectID, equals(projectID));
      expect(updatedProjectPlanDetails.planID, equals(planID));
      expect(updatedProjectPlanDetails.projectName, equals(projectName));
      expect(updatedProjectPlanDetails.planName, equals(planName));
      expect(updatedProjectPlanDetails.perCompletion, equals(perCompletion));
      expect(updatedProjectPlanDetails.generateURI, equals(generateURI));

      // Ensure the original object remains unchanged
      expect(projectPlanDetails.projectID, equals(projectID));
      expect(projectPlanDetails.planID, equals(planID));
      expect(projectPlanDetails.projectName, equals(projectName));
      expect(projectPlanDetails.planName, equals(planName));
      expect(projectPlanDetails.perCompletion, equals(perCompletion));
      expect(projectPlanDetails.generateURI, equals(generateURI));
    });

  });
}
