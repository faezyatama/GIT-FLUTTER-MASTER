import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import '/base/api_service.dart';

class BesarinGambar extends StatefulWidget {
  @override
  _BesarinGambarState createState() => _BesarinGambarState();
}

class _BesarinGambarState extends State<BesarinGambar> {
  final c = Get.find<ApiService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(c.besarinGambarNama.value),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Obx(() => PhotoView(
              minScale: 0.7,
              maxScale: 3.0,
              imageProvider: NetworkImage(c.besarinGambar.value),
            )),
      ),
    );
  }
}
