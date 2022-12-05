import 'dart:async';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import 'package:intl/intl.dart' as intl;
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import '/base/warna.dart';

class TTcetakPOS extends StatefulWidget {
  @override
  _TTcetakPOSState createState() => _TTcetakPOSState();
}

class _TTcetakPOSState extends State<TTcetakPOS> {
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
            title: const Text('Cetak Struk Transaksi POS'),
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

    var namaOutlet = c.namaTokoPOS;
    var tagLine = dbbox.get('taglineTS');
    var alamatToko = c.alamatOutletTSKU.value;

    var footer = dbbox.get('footerTS');
    var footer2 = dbbox.get('footerTS2');

    if (namaOutlet == null) {
      namaOutlet = 'SATU-AJA';
    }
    if (tagLine == null) {
      tagLine = ' --APLIKASI MULTIFUNGSI-- ';
    }

    if (footer == null) {
      footer = 'Terima kasih telah bertransaksi di outlet ${c.namaTokoPOS}';
    }
    if (footer2 == null) {
      footer2 = 'Barang yang sudah dibeli tidak dapat dikembalikan/ditukar';
    }

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
        content: alamatToko,
        weight: 1,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: tagLine,
        weight: 1,
        align: LineText.ALIGN_CENTER,
        linefeed: 2));
    list.add(LineText(linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '${c.nomorTransaksiPOS}',
        weight: 1,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(linefeed: 1));
    //---------transaksi pos
    //belanjaan
    var listTemporary = [];

    for (var a = 0; a < c.dataCetakStruk.length; a++) {
      var ord = c.dataCetakStruk[a];
      if (listTemporary.contains(ord)) {
      } else {
        //==================hitung jumlah quantity
        var quantity = 0;
        for (var b = 0; b < c.dataCetakStruk.length; b++) {
          var orB = c.dataCetakStruk[b];
          if (orB == ord) {
            quantity = quantity + 1;
          }
        }
        //===================sub jumlah
        var subjumlah = ord[7] * quantity;
        var rpSubJumlah = intl.NumberFormat.decimalPattern().format(subjumlah);

        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: ord[1],
            weight: 2,
            align: LineText.ALIGN_LEFT,
            linefeed: 0));

        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: '  $quantity x ${ord[7]}',
            weight: 2,
            align: LineText.ALIGN_LEFT,
            linefeed: 0));
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: '$rpSubJumlah',
            weight: 2,
            align: LineText.ALIGN_LEFT,
            linefeed: 2));
      }
      listTemporary.add(ord);
    }

    //end belanjaan
    //----------end transaksi pos

    list.add(LineText(linefeed: 2));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Total Rp.',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        linefeed: 0));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: c.totalRp,
        weight: 6,
        height: 2,
        align: LineText.ALIGN_RIGHT,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Bayar',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        linefeed: 0));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: c.bayarRp,
        weight: 6,
        height: 2,
        align: LineText.ALIGN_RIGHT,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Kembali ',
        weight: 1,
        align: LineText.ALIGN_LEFT,
        linefeed: 0));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: c.kembaliRp,
        weight: 6,
        height: 2,
        align: LineText.ALIGN_RIGHT,
        linefeed: 1));

    //-------------foter
    list.add(LineText(linefeed: 2));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: footer,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));
    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: footer2,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));

    list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: c.tanggalPOS,
        align: LineText.ALIGN_CENTER,
        linefeed: 1));

    list.add(LineText(linefeed: 2));
    await bluetoothPrint.printReceipt(config, list1);
    await bluetoothPrint.printReceipt(config, list);
  }
}
