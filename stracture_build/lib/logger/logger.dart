import 'package:field/utils/global.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'file_out_put.dart';

// ignore: non_constant_identifier_names
var Log = Logger(
  printer: PrettyPrinter(
    printEmojis: false,
    colors: false,
    noBoxingByDefault: true,
    excludeBox: {Level.debug:true},
    errorMethodCount: 0,
    methodCount: 0,
  ),
  filter: FieldFilter(),
  output: FileOutputLog(),
);

var loggerNoStack = Logger(printer: PrettyPrinter(printEmojis: false, colors: false, noBoxingByDefault: true, excludeBox: {Level.debug: true}, errorMethodCount: 0, methodCount: 0), filter: FieldFilter());

class FieldFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return kDebugMode || isLogEnable;
  }
}


