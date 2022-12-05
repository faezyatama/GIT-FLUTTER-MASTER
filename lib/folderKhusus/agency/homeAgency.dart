import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/base/api_service.dart';
import '/base/warna.dart';

import 'PerformaAgensi.dart';
import 'dataAgen.dart';
import 'tambahAgen.dart';

class HomeAgency extends StatefulWidget {
  @override
  _HomeAgencyState createState() => _HomeAgencyState();
}

class _HomeAgencyState extends State<HomeAgency> {
  final c = Get.find<ApiService>();
  var tampilkan = 'DataAgen'.obs;
  var listKategori = [
    'Agen Driver & Kurir',
    'Agen Outlet Mitra',
    'Agen Pulsa & PPOB',
    'Agen My School',
    'Agen Toko Sekitar'
  ];
  var pilihanKategori = '';
  final controllerSS = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Dashboard Agensi'), backgroundColor: Colors.amber),
      bottomNavigationBar: SizedBox(
        height: Get.height * 0.1,
        child: Container(
          padding: EdgeInsets.fromLTRB(22, 4, 22, 4),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(
              children: [
                Center(
                  child: Text(
                    c.jumlahAgen.value,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber),
                  ),
                ),
                Center(
                  child: Text(
                    'Agen',
                    style: TextStyle(fontSize: 11, color: Warna.grey),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Center(
                  child: Text(
                    c.akumulasiPendapatanAgensi.value,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber),
                  ),
                ),
                Center(
                  child: Text(
                    'Total Akumulasi Pendapatan Agensi',
                    style: TextStyle(fontSize: 11, color: Warna.grey),
                  ),
                ),
              ],
            )
          ]),
        ),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(22, 22, 22, 22),
        child: ListView(children: [
          Column(
            children: [
              Center(
                child: Text(
                  c.namaAgensi.value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Warna.grey),
                ),
              ),
              Center(
                child: Text(
                  c.kodeAgensi.value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w200,
                      color: Warna.grey),
                ),
              ),
              Center(
                child: Text(
                  c.alamatAgensi.value,
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
              ),
              Center(
                child: Text(
                  c.kotaAgensi.value,
                  style: TextStyle(fontSize: 12, color: Warna.grey),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 22)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(() => DataAgenku());
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'images/agensi/AgenGrey.png',
                          width: Get.width * 0.15,
                        ),
                        Center(
                          child: Text(
                            'Data Agen',
                            style: TextStyle(fontSize: 12, color: Warna.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => TambahAgen());
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'images/agensi/TambahAgenGrey.png',
                          width: Get.width * 0.15,
                        ),
                        Center(
                          child: Text(
                            'Tambah Agen',
                            style: TextStyle(fontSize: 12, color: Warna.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => PerformaAgensi());
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'images/agensi/PerformaGrey.png',
                          width: Get.width * 0.15,
                        ),
                        Center(
                          child: Text(
                            'Performa',
                            style: TextStyle(fontSize: 12, color: Warna.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(33)),
              Text(
                'Selamat Datang di Agensi',
                style: TextStyle(
                    color: Warna.grey,
                    fontSize: 22,
                    fontWeight: FontWeight.w600),
              ),
              Padding(padding: EdgeInsets.all(12)),
              Text(
                'Saatnya kembangkan bisnis ${c.namaAplikasi} di daerahmu,',
                style: TextStyle(
                  color: Warna.grey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Berbagai fitur menarik dan generator income yang berkelanjutan untuk mendukung agensi ${c.namaAplikasi} lebih berkembang.',
                style: TextStyle(
                  color: Warna.grey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

void cekKelengkapanData() {}
