import 'dart:convert';

import 'package:field/data/dao/bim_model_calibration_dao.dart';
import 'package:field/data/dao/bim_model_list_dao.dart';
import 'package:field/data/dao/floor_bim_model_dao.dart';
import 'package:field/data/dao/floor_calibration_dao.dart';
import 'package:field/data/dao/model_bim_models_dao.dart';
import 'package:field/data/dao/model_list_dao.dart';
import 'package:field/data/dao/project_dao.dart';
import 'package:field/data/model/bim_model_calibration_vo.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/floor_bim_model_vo.dart';
import 'package:field/data/model/floor_calibration_model_vo.dart';
import 'package:field/data/model/model_bim_model_vo.dart';
import 'package:field/data/model/model_vo.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Floor Calibration create table query test', () {
    FloorCalibrationModelDao floorCalibrationModelDao = FloorCalibrationModelDao();
    String strBimModelListCreateQuery = 'CREATE TABLE IF NOT EXISTS FloorCalibratedListTbl(calibrationId INTEGER NOT NULL,floorId INTEGER NOT NULL)';
    expect(strBimModelListCreateQuery, floorCalibrationModelDao.createTableQuery);
  });

  test('Floor Calibration item to map test', () {
    FloorCalibrationModelDao floorCalibrationModelDao = FloorCalibrationModelDao();
    String strData = "{\"calibrationId\":\"${"43812\$\$17KRZw"}\",\"floorId\":\"${"46312\$\$17KRZw"}\"}";
    FloorCalibrationModel floorCalibrationModel = FloorCalibrationModel.fromJson(json.decode(strData));
    var dataMap = floorCalibrationModelDao.toMap(floorCalibrationModel);
    dataMap.then((value) {
      expect(2, value.length);
    });
  });

  test('Floor Calibration from map test', () {
    var dataMap = {
      "calibrationId": "46542\$\$17KRZw",
      "floorId": "46312\$\$17KRZw",
    };
    FloorCalibrationModelDao floorCalibrationModelDao = FloorCalibrationModelDao();
    FloorCalibrationModel floorCalibrationModel = floorCalibrationModelDao.fromMap(dataMap);
    expect(floorCalibrationModel.floorId,"46312\$\$17KRZw");
    expect(floorCalibrationModel.calibrationId,null);
  });

  test('Floor Calibration from map test', () async {
    var dataMap = {
      "calibrationId": "46542\$\$17KRZw",
      "floorId": "46312\$\$17KRZw",
    };
    List<Map<String, dynamic>> mapBimModel= [];
    List<FloorCalibrationModel> objects = [];
    FloorCalibrationModelDao floorCalibrationModelDao = FloorCalibrationModelDao();
    mapBimModel = await floorCalibrationModelDao.toListMap(objects);
    expect(objects.length,0);
    FloorCalibrationModel floorCalibrationModel = floorCalibrationModelDao.fromMap(dataMap);
    objects.add(floorCalibrationModel);
    expect(objects.length,1);
  });

  test('Floor Calibration list from list map test', () {
    var dataMap = [{
      "calibrationId": "46542\$\$17KRZw",
      "floorId": "46312\$\$17KRZw",
    },{
      "calibrationId": "46542\$\$17KRZw",
      "floorId": "46312\$\$17KRZw",
    }];
    FloorCalibrationModelDao floorCalibrationModelDao = FloorCalibrationModelDao();
    List<FloorCalibrationModel> floorBimModelList = floorCalibrationModelDao.fromList(dataMap);
    expect(floorBimModelList.length, 2);
  });

  test('Floor Calibration from map test', () async {
    var dataMap = {
      "calibrationId": "46542\$\$17KRZw",
      "floorId": "46312\$\$17KRZw",
    };
    FloorCalibrationModelDao floorCalibrationModelDao = FloorCalibrationModelDao();
    FloorCalibrationModel floorCalibrationModel = floorCalibrationModelDao.fromMap(dataMap);
    expect(floorCalibrationModel.calibrationId,null);
  });
}