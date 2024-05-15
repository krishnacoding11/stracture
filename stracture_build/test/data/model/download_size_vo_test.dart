import 'package:field/data/model/download_size_vo.dart';
import 'package:field/data/model/sync_size_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson should create DownloadSizeVo instance from JSON data', () {
    final jsonData = {
      'pdfAndXfdfSize': 100,
      'formTemplateSize': 50,
      'totalSize': 150,
      'countOfLocations': 5,
      'totalFormXmlSize': 30,
      'attachmentsSize': 10,
      'associationsSize': 5,
      'countOfForms': 8,
    };

    final downloadSizeVo = DownloadSizeVo.fromJson(jsonData);

    expect(downloadSizeVo.pdfAndXfdfSize, 100);
    expect(downloadSizeVo.formTemplateSize, 50);
    expect(downloadSizeVo.totalSize, 150);
    expect(downloadSizeVo.countOfLocations, 5);
    expect(downloadSizeVo.totalFormXmlSize, 30);
    expect(downloadSizeVo.attachmentsSize, 10);
    expect(downloadSizeVo.associationsSize, 5);
    expect(downloadSizeVo.countOfForms, 8);
  });

  test('toJson should convert DownloadSizeVo to JSON data', () {
    final downloadSizeVo = DownloadSizeVo(
      pdfAndXfdfSize: 100,
      formTemplateSize: 50,
      totalSize: 150,
      countOfLocations: 5,
      totalFormXmlSize: 30,
      attachmentsSize: 10,
      associationsSize: 5,
      countOfForms: 8,
    );

    final jsonData = downloadSizeVo.toJson();

    expect(jsonData['pdfAndXfdfSize'], 100);
    expect(jsonData['formTemplateSize'], 50);
    expect(jsonData['totalSize'], 150);
    expect(jsonData['countOfLocations'], 5);
    expect(jsonData['totalFormXmlSize'], 30);
    expect(jsonData['attachmentsSize'], 10);
    expect(jsonData['associationsSize'], 5);
    expect(jsonData['countOfForms'], 8);
  });

  test('getDownloadSize should convert nested JSON to DownloadSizeVo map', () {
    final jsonData = {
      'project1': [
        {
          'downloadSize1': {
            'pdfAndXfdfSize': 100,
            'formTemplateSize': 50,
            'totalSize': 150,
            'countOfLocations': 5,
            'totalFormXmlSize': 30,
            'attachmentsSize': 10,
            'associationsSize': 5,
            'countOfForms': 8,
          }
        }
      ],
      'project2': [
        {
          'downloadSize2': {
            'pdfAndXfdfSize': 200,
            'formTemplateSize': 80,
            'totalSize': 280,
            'countOfLocations': 10,
            'totalFormXmlSize': 50,
            'attachmentsSize': 20,
            'associationsSize': 8,
            'countOfForms': 12,
          }
        }
      ],
    };

    final downloadSizeMap = DownloadSizeVo.getDownloadSize(jsonData);

    expect(downloadSizeMap['project1']![0]['downloadSize1']!.pdfAndXfdfSize, 100);
    expect(downloadSizeMap['project1']![0]['downloadSize1']!.formTemplateSize, 50);
    expect(downloadSizeMap['project2']![0]['downloadSize2']!.totalSize, 280);
    expect(downloadSizeMap['project2']![0]['downloadSize2']!.countOfLocations, 10);
  });

  test('fromSyncVo should convert List of SyncSizeVo to a map with totalSize and totalLocationCount', () {
    final syncSizeVoList = [
      SyncSizeVo(locationId: 1, downloadSizeVo: DownloadSizeVo(totalSize: 100, countOfLocations: 5)),
      SyncSizeVo(locationId: 2, downloadSizeVo: DownloadSizeVo(totalSize: 50, countOfLocations: 3)),
    ];

    final attributeSetVOList = DownloadSizeVo.fromSyncVo(syncSizeVoList);

    expect(attributeSetVOList['totalSize'], 150);
    expect(attributeSetVOList['totalLocationCount'], 8);
  });

  test('copyWith should correctly update properties', () {
    final original = DownloadSizeVo(
      pdfAndXfdfSize: 100,
      formTemplateSize: 50,
      totalSize: 200,
      countOfLocations: 5,
      totalFormXmlSize: 300,
      attachmentsSize: 40,
      associationsSize: 30,
      countOfForms: 10,
    );

    final updated = original.copyWith(
      pdfAndXfdfSize: 150,
      formTemplateSize: 70,
      totalSize: 250,
      countOfLocations: 6,
      totalFormXmlSize: 350,
      attachmentsSize: 45,
      associationsSize: 35,
      countOfForms: 12,
    );

    expect(original.pdfAndXfdfSize, 100);
    expect(original.formTemplateSize, 50);
    expect(updated.pdfAndXfdfSize, 150);
    expect(updated.formTemplateSize, 70);
  });
}
