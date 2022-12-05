import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/warna.dart';

class TerimaSaldo extends StatefulWidget {
  @override
  _TerimaSaldoState createState() => _TerimaSaldoState();
}

class _TerimaSaldoState extends State<TerimaSaldo> {
  //BOTTOM NAVIGATION BAR
  @override
  @override
  Widget build(BuildContext context) {
    Box dbbox = Hive.box<String>('sasukaDB');
    String ss = dbbox.get('kodess');
    String dataqr = 'send+$ss+';

    var bytes = utf8.encode(dataqr + 'sasukaKey');
    var signature = md5.convert(bytes).toString();
    String qrdata = dataqr + signature;

    return Scaffold(
      appBar: AppBar(
        title: Text('Terima Saldo'),
        backgroundColor: Warna.warnautama,
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Center(
          child: ListView(
            children: [
              Column(children: [
                Text(
                  'Terima Saldo Dengan Mudah',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Warna.warnautama),
                ),
                Text(
                  'Mau terima saldo dari teman, tinggal scan QR code ini saja',
                  style: TextStyle(
                    fontSize: 16,
                    color: Warna.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  width: Get.width * 0.75,
                  height: Get.width * 0.75,
                  child: Image(
                      width: Get.width * 0.7,
                      image: CachedNetworkImageProvider(
                        'https://chart.googleapis.com/chart?cht=qr&chs=300x300&chl=$qrdata',
                      )),
                ),
                Text(
                  'Atau kamu juga bisa memberikan Kode Anggota ini kepada teman kamu untuk menerima saldo',
                  style: TextStyle(fontSize: 16, color: Warna.grey),
                  textAlign: TextAlign.center,
                ),
                Padding(padding: EdgeInsets.only(top: 12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dbbox.get('kodess'),
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Warna.warnautama),
                    ),
                    Padding(padding: EdgeInsets.only(left: 22)),
                    GestureDetector(
                      onTap: () {
                        FlutterClipboard.copy(dbbox.get('kodess'));
                        Get.snackbar("Copy to Clipboard",
                            "Kode Anggota kamu berhasil di copy");
                      },
                      child: Icon(
                        Icons.copy,
                        size: 28,
                        color: Warna.warnautama,
                      ),
                    )
                  ],
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
