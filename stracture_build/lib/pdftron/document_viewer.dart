import 'dart:async';
import 'dart:io';

import 'package:field/pdftron/pdftron_config.dart';
import 'package:field/pdftron/pdftron_document_view.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';

class DocumentViewer extends StatefulWidget {
  final String title;
  final String filePath;

  const DocumentViewer({super.key, required this.title, required this.filePath});
  @override
  DocumentViewerState createState() => DocumentViewerState();
}

class DocumentViewerState extends State<DocumentViewer> {
  PdftronDocumentViewController? _pdftronDocumentViewController;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onDocumentViewCreated(PdftronDocumentViewController controller) async {
    _pdftronDocumentViewController = controller;
    startDocumentLoadedListener((path) async {
      await controller.setBackgroundColor(255, 255, 255);
      await controller.requestResetRenderingPdftron();
    });
    _openDocument();
  }

  void _openDocument() async {
    try {
      if (File(widget.filePath).existsSync()) {
        File pdfFile = File(widget.filePath);
        await _pdftronDocumentViewController
            ?.openDocument(pdfFile.uri.toString(),config: getFilePreviewConfig())
            .catchError((error) {
              if (kDebugMode) {
                print(error);
              }
        });
      }
    } catch (e) {
      //
    }
  }

  // Platform messages are asynchronous, so we initialize via an async method.
  Future<void> initPlatformState() async {
    String version;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      PdftronFlutter.initialize();
      version = await PdftronFlutter.version;
    } on PlatformException {
      version = 'Failed to get platform version.';
    }
    if (kDebugMode) {
      print(version);
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
          titleTextStyle: const TextStyle(color: AColors.black,fontFamily: "Sofia", fontWeight: AFontWight.medium,fontSize: 20),
          // toolbarHeight: 25,
          backgroundColor: AColors.white,
          elevation: 1,
          //automaticallyImplyLeading: true,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black54,
            ),
          ),
        ),
        body: SafeArea(child: PdftronDocumentView(onCreated: onDocumentViewCreated)));
  }
}
