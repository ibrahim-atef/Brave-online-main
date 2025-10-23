import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:egyptm/common/common.dart';
import 'package:egyptm/common/components.dart';

import '../../../../../../common/data/app_data.dart';

class PdfViewerPage extends StatefulWidget {
  static const String pageName = '/pdf-viewer';
  const PdfViewerPage({super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? title;
  String? path;
  String? name;

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  PdfViewerController pdfViewerController = PdfViewerController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      path = (ModalRoute.of(context)!.settings.arguments as List)[0];
      title = (ModalRoute.of(context)!.settings.arguments as List)[1];
      name = await AppData.getName();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
      child: Scaffold(
        appBar: appbar(title: title ?? ''),
        body: path != null
            ? Stack(
                children: [
                  SfPdfViewer.network(
                    path ?? '',
                    key: _pdfViewerKey,
                    controller: pdfViewerController,
                  ),
                  if (name != null)
                    IgnorePointer(
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Opacity(
                            opacity: 0.2,
                            child: Text(
                              name!,
                                style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6666), // فاتح أحمر
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                ],
              )
            : const SizedBox(),
      ),
    );
  }

  @override
  void dispose() {
    pdfViewerController.dispose();
    super.dispose();
  }
}
