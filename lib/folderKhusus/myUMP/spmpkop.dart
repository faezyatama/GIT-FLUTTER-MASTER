import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfSPMPKop extends StatefulWidget {
  @override
  _PdfSPMPKopState createState() => _PdfSPMPKopState();
}

class _PdfSPMPKopState extends State<PdfSPMPKop> {
  final c = Get.find<ApiService>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('SPMPKOP'),
          backgroundColor: Colors.blue,
        ),
        body: Container(
            child: SfPdfViewer.network(c.spmpkopPilihan.value,
                canShowScrollHead: true, canShowScrollStatus: true)));
  }
}
