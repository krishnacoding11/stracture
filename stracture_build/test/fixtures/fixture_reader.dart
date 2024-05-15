import 'dart:io';
import 'dart:typed_data';

String fixture(String name) => File('test/fixtures/data/$name').readAsStringSync();

String fixtureFile(String path) => File('test/fixtures/files/$path').path;

String fixtureFileContent(String path) => File('test/fixtures/$path').readAsStringSync();

Uint8List fixtureZipFile(String path) => File('test/fixtures/data/$path').readAsBytesSync();
