import 'package:flutter/material.dart';
import '/base/warna.dart';

class HomeAutodebet extends StatefulWidget {
  @override
  State<HomeAutodebet> createState() => _HomeAutodebetState();
}

class _HomeAutodebetState extends State<HomeAutodebet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.warnautama,
        title: Text("Autodebet Pinjaman"),
      ),
    );
  }
}
