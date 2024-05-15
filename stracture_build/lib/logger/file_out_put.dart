import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:field/utils/global.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../utils/app_path_helper.dart';

class FileOutputLog extends LogOutput {
  FileOutputLog({
    this.overrideExisting = false,
    this.encoding = utf8,
  });

  final bool overrideExisting;
  final Encoding encoding;
  IOSink? _sink;
  File? logFile;
  static final levelPrefixes = {
    Level.verbose: '[V]',
    Level.debug: '[D]',
    Level.info: '[I]',
    Level.warning: '[W]',
    Level.error: '[E]',
    Level.wtf: '[WTF]',
  };
  static final logTags = ["curl", "QUERY"];

  @override
  void init() async {
    try {
      final String filePath = await AppPathHelper().getSyncLogFilePath();
      logFile = File(filePath);
    } catch (e) {
      print(e);
    }
  }

  @override
  void output(OutputEvent event) {
    if (kDebugMode) {
      String msg = event.lines.join("\n");
      if (logTags.any(msg.contains)) {
        log(msg);
      } else {
        event.lines.forEach(print);
      }
    }

    try {
      if (!isLogEnable) {
        return;
      }

      if ((logFile != null && !logFile!.existsSync()) || _sink == null) {
        logFile?.createSync();
        _sink = logFile?.openWrite(
          mode: overrideExisting ? FileMode.writeOnly : FileMode.writeOnlyAppend,
          encoding: encoding,
        );
      }
      var messageStr = _stringifyMessage(event.origin.message);
      var errorStr = event.origin.error != null ? '  ERROR: ${event.origin.error}' : '';
      var timeStr = '${DateTime.now().toIso8601String()}';
      List s = ['${_labelFor(event.level)} $timeStr $messageStr$errorStr'];
      _sink?.writeAll(s);
      _sink?.write('\n');
    } catch (e) {
      print(e);
    }
  }

  String _labelFor(Level level) {
    var prefix = levelPrefixes[level]!;
    return prefix;
  }

  String _stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      var encoder = JsonEncoder.withIndent(null);
      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }

  @override
  void destroy() async {
    await _sink?.flush();
    await _sink?.close();
  }
}
