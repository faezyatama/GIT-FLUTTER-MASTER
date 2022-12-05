import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'pulsa-china.dart';
import 'pulsa-malaysia.dart';
import 'pulsa-paket.dart';
import 'pulsa-vietnam.dart';

import 'pulsa-data.dart';
import 'pulsa-philipines.dart';
import 'pulsa-reguler.dart';
import 'pulsa-singapore.dart';
import 'pulsa-thailand.dart';

class PulsaTrx extends StatefulWidget {
  @override
  _PulsaTrxState createState() => _PulsaTrxState();
}

class _PulsaTrxState extends State<PulsaTrx> {
  final c = Get.find<ApiService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pulsa'),
          backgroundColor: Warna.warnautama,
        ),
        body: Container(
          padding: EdgeInsets.all(22),
          child: Column(
            children: [
              Text(
                'Pulsa All Operator',
                style: TextStyle(
                    fontSize: 18,
                    color: Warna.grey,
                    fontWeight: FontWeight.w600),
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              Text(
                  'Kemudahan dalam mengisi pulsa berbagai operator dengan harga terbaik',
                  style: TextStyle(
                    fontSize: 14,
                    color: Warna.grey,
                  ),
                  textAlign: TextAlign.center),
              Padding(padding: EdgeInsets.only(top: 16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      c.pulsadetail.value = 'Pulsa Reguler';
                      Get.to(() => PulsaReguler());
                    },
                    child: Card(
                      child: Container(
                        width: Get.width * 0.27,
                        height: Get.width * 0.4,
                        padding: EdgeInsets.all(3),
                        child: Column(
                          children: [
                            Image.asset('images/pulsareguler.png'),
                            Padding(padding: EdgeInsets.only(top: 11)),
                            Text('Pulsa Reguler',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Warna.grey,
                                    fontWeight: FontWeight.w600))
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      c.pulsadetail.value = 'Pulsa Data';
                      Get.to(() => PulsaData());
                    },
                    child: Card(
                      child: Container(
                        width: Get.width * 0.27,
                        height: Get.width * 0.4,
                        padding: EdgeInsets.all(3),
                        child: Column(
                          children: [
                            Image.asset('images/pulsadata.png'),
                            Padding(padding: EdgeInsets.only(top: 11)),
                            Text('Pulsa Data',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Warna.grey,
                                    fontWeight: FontWeight.w600))
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      c.pulsadetail.value = 'Paket SMS & Telepon';
                      Get.to(() => PulsaPaket());
                    },
                    child: Card(
                      child: Container(
                        width: Get.width * 0.27,
                        height: Get.width * 0.4,
                        padding: EdgeInsets.all(3),
                        child: Column(
                          children: [
                            Image.asset('images/pulsasms.png'),
                            Padding(padding: EdgeInsets.only(top: 11)),
                            Text('Paket SMS & Telepon',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Warna.grey,
                                    fontWeight: FontWeight.w600))
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 28)),
              Text(
                'Pulsa Luar Negeri',
                style: TextStyle(
                    fontSize: 18,
                    color: Warna.grey,
                    fontWeight: FontWeight.w600),
              ),
              Padding(padding: EdgeInsets.only(top: 11)),
              Text(
                'Kami juga menyediakan pengisian pulsa bagi kamu yang sedang berada di luar negeri',
                style: TextStyle(
                  fontSize: 14,
                  color: Warna.grey,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(top: 11)),
              Row(
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          c.pulsadetail.value = 'Pulsa Singapore';
                          Get.to(() => PulsaSingapore());
                        },
                        child: Card(
                          child: Container(
                            width: Get.width * 0.27,
                            padding: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Image.asset('images/sing.png',
                                    width: Get.width * 0.2),
                                Text('Singapore',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Warna.grey,
                                        fontWeight: FontWeight.w600))
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 12)),
                      GestureDetector(
                        onTap: () {
                          c.pulsadetail.value = 'Pulsa China';
                          Get.to(() => PulsaChina());
                        },
                        child: Card(
                          child: Container(
                            width: Get.width * 0.27,
                            padding: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Image.asset('images/chin.png',
                                    width: Get.width * 0.2),
                                Text('China',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Warna.grey,
                                        fontWeight: FontWeight.w600))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          c.pulsadetail.value = 'Pulsa Malaysia';
                          Get.to(() => PulsaMalaysia());
                        },
                        child: Card(
                          child: Container(
                            width: Get.width * 0.27,
                            padding: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Image.asset('images/mal.png',
                                    width: Get.width * 0.2),
                                Text('Malaysia',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Warna.grey,
                                        fontWeight: FontWeight.w600))
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 12)),
                      GestureDetector(
                        onTap: () {
                          c.pulsadetail.value = 'Pulsa Vietnam';
                          Get.to(() => PulsaVietnam());
                        },
                        child: Card(
                          child: Container(
                            width: Get.width * 0.27,
                            padding: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Image.asset('images/viet.png',
                                    width: Get.width * 0.2),
                                Text('Vietnam',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Warna.grey,
                                        fontWeight: FontWeight.w600))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          c.pulsadetail.value = 'Pulsa Philippines';
                          Get.to(() => PulsaPhilipines());
                        },
                        child: Card(
                          child: Container(
                            width: Get.width * 0.27,
                            padding: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Image.asset('images/phil.png',
                                    width: Get.width * 0.2),
                                Text('Philippines',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Warna.grey,
                                        fontWeight: FontWeight.w600))
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 12)),
                      GestureDetector(
                        onTap: () {
                          c.pulsadetail.value = 'Pulsa Thailand';
                          Get.to(() => ThailandTopup());
                        },
                        child: Card(
                          child: Container(
                            width: Get.width * 0.27,
                            padding: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Image.asset(
                                  'images/thai.png',
                                  width: Get.width * 0.2,
                                ),
                                Text('Thailand',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Warna.grey,
                                        fontWeight: FontWeight.w600))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ));
  }
}
