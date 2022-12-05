import 'package:flutter/material.dart';
import '/base/warna.dart';
import 'penarikan.dart';

import 'historypenarikan.dart';

class ViewPenarikan extends StatefulWidget {
  @override
  _ViewPenarikanState createState() => _ViewPenarikanState();
}

class _ViewPenarikanState extends State<ViewPenarikan> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Penarikan Dana'),
                backgroundColor: Warna.warnautama,
                bottom: TabBar(
                  indicatorColor: Colors.amber,
                  tabs: [
                    Tab(
                        icon: Icon(Icons.add_shopping_cart),
                        text: 'Request Penarikan'),
                    Tab(
                        icon: Icon(Icons.account_balance_wallet),
                        text: 'History Penarikan'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [PenarikanDana(), HistoriPenarikan()],
              ),
            )));
  }
}
