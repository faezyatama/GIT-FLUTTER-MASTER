import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'daftarProdukTS.dart';
import 'tambahProdukTS.dart';

class ListProdukToko extends StatefulWidget {
  @override
  _ListProdukTokoState createState() => _ListProdukTokoState();
}

class _ListProdukTokoState extends State<ListProdukToko> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Produk Toko'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
              onPressed: () {
                Get.off(TambahProdukTS());
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: DaftarProdukTS(),
    );
  }
}
