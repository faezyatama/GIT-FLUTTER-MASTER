import 'dart:async';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '/base/api_service.dart';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import '/base/warna.dart';

class TTcetak extends StatefulWidget {
  @override
  _TTcetakState createState() => _TTcetakState();
}

class _TTcetakState extends State<TTcetak> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  BluetoothDevice _device;
  String tips = 'Tidak ada perangkat terkoneksi';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool isConnected = await bluetoothPrint.isConnected;

    bluetoothPrint.state.listen((state) {
      print('cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'Terhubung Ke Printer';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'Tidak Terhubung';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
            title: const Text('Cetak Struk Transaksi'),
            backgroundColor: Warna.warnautama),
        body: RefreshIndicator(
          onRefresh: () =>
              bluetoothPrint.startScan(timeout: Duration(seconds: 4)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text(tips),
                    ),
                  ],
                ),
                Divider(),
                StreamBuilder<List<BluetoothDevice>>(
                  stream: bluetoothPrint.scanResults,
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data
                        .map((d) => ListTile(
                              title: Text(d.name ?? ''),
                              subtitle: Text(d.address),
                              onTap: () async {
                                setState(() {
                                  _device = d;
                                });
                              },
                              trailing: _device != null &&
                                      _device.address == d.address
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : null,
                            ))
                        .toList(),
                  ),
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlinedButton(
                            child: Text('Hubungkan'),
                            onPressed: _connected
                                ? null
                                : () async {
                                    if (_device != null &&
                                        _device.address != null) {
                                      await bluetoothPrint.connect(_device);
                                    } else {
                                      setState(() {
                                        tips = 'please select device';
                                      });
                                      print('please select device');
                                    }
                                  },
                          ),
                          SizedBox(width: 10.0),
                          OutlinedButton(
                            child: Text('Putuskan'),
                            onPressed: _connected
                                ? () async {
                                    await bluetoothPrint.disconnect();
                                  }
                                : null,
                          ),
                          SizedBox(width: 10.0),
                          OutlinedButton(
                            child: Text('Cetak'),
                            onPressed: _connected
                                ? () async {
                                    cetakNow();
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: bluetoothPrint.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () => bluetoothPrint.stopScan(),
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                  child: Icon(Icons.search),
                  backgroundColor: Warna.warnautama,
                  onPressed: () =>
                      bluetoothPrint.startScan(timeout: Duration(seconds: 4)));
            }
          },
        ),
      ),
    );
  }

  void cetakNow() async {
    final c = Get.find<ApiService>();
    Box dbbox = Hive.box<String>('sasukaDB');

    var namaOutlet = dbbox.get('namaOutlet');
    var tagLine = dbbox.get('tagLine');
    var hargaDiatur = dbbox.get('hargaDiatur');
    var footer = dbbox.get('footer');

    if (namaOutlet == null) {
      namaOutlet = 'SATU-AJA';
    }
    if (tagLine == null) {
      tagLine = ' --APLIKASI MULTIFUNGSI-- ';
    }
    if (hargaDiatur == null) {
      hargaDiatur = 'SATUAJA';
    } else {
      hargaDiatur = 'SENDIRI';
    }
    if (footer == null) {
      footer = 'Terima Kasih telah bertransaksi bersama Satu-Aja';
    }
    var trxx = 'Trx: ${c.kodeCetak.value}';

    Map<String, dynamic> config = Map();
    List<LineText> list = [];
    List<LineText> list1 = [];
    //----------------------BARIS DATA

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: namaOutlet,
        weight: 6,
        height: 2,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: tagLine,
        weight: 1,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: trxx,
        weight: 1,
        align: LineText.ALIGN_CENTER,
        linefeed: 2));
    list.add(LineText(linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Produk :',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: c.barisCetak1.value,
        weight: 1,
        align: LineText.ALIGN_LEFT,
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: c.barisCetak2.value,
        weight: 1,
        align: LineText.ALIGN_LEFT,
        linefeed: 1));
    list.add(LineText(linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Status Transaksi :',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: c.barisCetak3.value,
        weight: 1,
        align: LineText.ALIGN_LEFT,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: c.barisCetak4.value,
        weight: 1,
        align: LineText.ALIGN_LEFT,
        linefeed: 1));
    if (c.barisCetak5.value != '') {
      list.add(LineText(linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: 'Detail :',
          weight: 1,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: c.barisCetak5.value,
          weight: 1,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
    }
    if (c.barisCetak6.value != '') {
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: c.barisCetak6.value,
          weight: 1,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
    }
    if (c.barisCetak7.value != '') {
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: c.barisCetak7.value,
          weight: 1,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
    }
    if (c.barisCetak8.value != '') {
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: c.barisCetak8.value,
          weight: 1,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
    }
    list.add(LineText(linefeed: 2));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Harga',
        weight: 2,
        align: LineText.ALIGN_RIGHT,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: c.hargaCetak.value,
        weight: 6,
        height: 2,
        align: LineText.ALIGN_RIGHT,
        linefeed: 1));

    list.add(LineText(linefeed: 2));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: footer,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));

    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy H:m');
    final String timestamp = formatter.format(now);
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: timestamp,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));

    list.add(LineText(linefeed: 2));
    await bluetoothPrint.printReceipt(config, list1);
    await bluetoothPrint.printReceipt(config, list);
  }
}
