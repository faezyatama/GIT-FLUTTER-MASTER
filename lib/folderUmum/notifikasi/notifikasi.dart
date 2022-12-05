import 'package:flutter/material.dart';
import '/base/warna.dart';
import 'notifInfoAkun.dart';
import 'notifInfoSatuaja.dart';

class NotifikasiAplikasi extends StatefulWidget {
  @override
  _NotifikasiAplikasiState createState() => _NotifikasiAplikasiState();
}

class _NotifikasiAplikasiState extends State<NotifikasiAplikasi> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Informasi'),
                backgroundColor: Warna.warnautama,
                bottom: TabBar(
                  indicatorColor: Colors.amber,
                  tabs: [
                    Tab(icon: Icon(Icons.tap_and_play), text: 'Info Akun'),
                    Tab(icon: Icon(Icons.feedback), text: 'Info Aplikasi'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  NotifInfoAkun(),
                  NotifInfoSatuaja(),
                ],
              ),
            )));
  }
}
