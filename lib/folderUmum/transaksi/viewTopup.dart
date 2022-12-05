import 'package:flutter/material.dart';
import '/base/warna.dart';
import 'topup.dart';

import 'historyTopup.dart';

class ViewTopup extends StatefulWidget {
  @override
  _ViewTopupState createState() => _ViewTopupState();
}

class _ViewTopupState extends State<ViewTopup> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Top Up Saldo'),
                backgroundColor: Warna.warnautama,
                bottom: TabBar(
                  indicatorColor: Colors.amber,
                  tabs: [
                    Tab(icon: Icon(Icons.add_shopping_cart), text: 'Request'),
                    Tab(
                        icon: Icon(Icons.account_balance_wallet),
                        text: 'History TopUp'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  TopupSaldo(),
                  HistoryTopup(),
                ],
              ),
            )));
  }
}
