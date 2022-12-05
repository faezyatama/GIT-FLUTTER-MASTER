import 'package:flutter/material.dart';
import '/base/warna.dart';
import 'keranjangdetail.dart';
import 'wishlist.dart';

class KeranjangBelanja extends StatefulWidget {
  @override
  _KeranjangBelanjaState createState() => _KeranjangBelanjaState();
}

class _KeranjangBelanjaState extends State<KeranjangBelanja> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Keranjang Belanja'),
                backgroundColor: Warna.warnautama,
                bottom: TabBar(
                  indicatorColor: Colors.amber,
                  tabs: [
                    Tab(icon: Icon(Icons.shopping_cart), text: 'Keranjang'),
                    Tab(icon: Icon(Icons.favorite), text: 'Wishlist'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  KeranjangDetail(),
                  Wishllist(),
                ],
              ),
            )));
  }
}
