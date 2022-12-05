//ROUTE SUDAH DIPERIKSA
import 'dart:async';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import '/base/warna.dart';
import 'pengaturanDriver.dart';
import 'riwayatAntaranIntegrasi.dart';

import 'daftarAntaranIntegrasi.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 85;
const double CAMERA_BEARING = 30;

class DashboardIntegrasi extends StatefulWidget {
  @override
  _DashboardIntegrasiState createState() => _DashboardIntegrasiState();
}

class _DashboardIntegrasiState extends State<DashboardIntegrasi> {
  Box dbbox = Hive.box<String>('sasukaDB');

  final controllerHp = TextEditingController();

  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor destinationIcon;

  List<Marker> _markers = [];

  LatLng currentLocation;
  LatLng destinationLocation;

  final c = Get.find<ApiService>();

  var dataSiap = false.obs;
  var outlet = ''.obs;
  var keterangan = 'Mohon tunggu'.obs;

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];

  Timer timer;
  @override
  void initState() {
    super.initState();
    setSourceAndDestinationMarkerIcon();
    setInitialLocation();
    cekstatusOnOff();
    dataSiap.value = true;
    c.alamatJemput.value = '';
    timer = Timer.periodic(
        Duration(seconds: 8), (Timer t) => cekOrderBerlangsung());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void setSourceAndDestinationMarkerIcon() async {
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'images/mapDRIVER.png');
  }

  void setInitialLocation() {
    destinationLocation = LatLng(c.latitude.value, c.longitude.value);
    c.tempLat.value = c.latitude.value;
    c.tempLong.value = c.longitude.value;
  }

  //parameter
  var pilihanAntaran = '';

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text('Kurir Integrasi'),
          backgroundColor: Warna.warnautama,
          actions: [
            IconButton(
                onPressed: () {
                  Get.to(() => DaftarAntaran());
                },
                icon: Icon(Icons.shopping_cart)),
            GestureDetector(
              onTap: () {
                Get.to(() => DaftarAntaran());
              },
              child: Center(
                child: Obx(() => Text(
                      c.antaranIntegrasi.value.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w300),
                    )),
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => DaftarAntaran());
              },
              child: Center(
                child: Text(
                  ' Antaran',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w300),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(8))
          ],
        ),
        bottomNavigationBar: Container(
          margin: EdgeInsets.fromLTRB(22, 8, 22, 8),
          height: Get.height * 0.06,
          child: Obx(() => RawMaterialButton(
                onPressed: () {
                  onlineOffline();
                },
                constraints: BoxConstraints(),
                elevation: 1.0,
                fillColor: (c.btnOnlineOffline.value == 'Online')
                    ? Warna.warnautama
                    : Colors.grey,
                child: Text(
                  c.btnOnlineOffline.value,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                padding: EdgeInsets.fromLTRB(22, 6, 22, 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(33)),
                ),
              )),
        ),
        body: Stack(
          children: [
            (dataSiap.value == false)
                ? Container()
                : GoogleMap(
                    compassEnabled: false,
                    mapType: MapType.normal,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      showPinonMaps();
                    },
                    markers: _markers.toSet(),
                    polylines: _polylines,
                    initialCameraPosition: CameraPosition(
                        zoom: CAMERA_ZOOM,
                        tilt: CAMERA_TILT,
                        bearing: CAMERA_BEARING,
                        target: destinationLocation)),
            Container(
              child: Container(
                margin: EdgeInsets.fromLTRB(22, Get.height * 0.03, 22, 33),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(() => DaftarAntaran());
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'images/iconmitra/UmumOrder.png',
                            width: Get.width * 0.15,
                          ),
                          Text('Order Masuk', style: TextStyle(fontSize: 11))
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => RiwayatAntaran());
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'images/iconmitra/UmumHistory.png',
                            width: Get.width * 0.15,
                          ),
                          Text('Riwayat Antaran',
                              style: TextStyle(fontSize: 11))
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => PengaturanDriver());
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'images/iconmitra/UmumPengaturan.png',
                            width: Get.width * 0.15,
                          ),
                          Text('Pengaturan', style: TextStyle(fontSize: 11))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        )));
  }

  void showPinonMaps() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('destinationpin'),
          draggable: true,
          onDragEnd: (LatLng ltng) async {
            onDragEnd(ltng);
          },
          position: destinationLocation,
          infoWindow: InfoWindow(
              title: 'Pilih lokasi penjemputan',
              snippet: 'Tap dan geser penanda ya'),
          icon: destinationIcon));
    });
  }

  void onDragEnd(ltng) async {
    c.alamatJemput.value = 'Alamat ditentukan pada koordinat peta';
    c.tempLatJemput.value = ltng.latitude;
    c.tempLongJemput.value = ltng.longitude;
    controllerHp.text = '';

    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(c.tempLatJemput.value, c.tempLongJemput.value),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  }

  void onlineOffline() async {
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var onoff = c.btnOnlineOffline.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","onoff":"$onoff"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/onlineOffline');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.btnOnlineOffline.value = hasil['onoff'];
      }
    }
  }

  void cekstatusOnOff() async {
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url =
        Uri.parse('${c.baseURLdriver}/mobileAppsMitraDriver/cekStatusOnOff');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });
    print('CEKONOFF==========================');
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.btnOnlineOffline.value = hasil['onoff'];
      }
    }
  }

  cekOrderBerlangsung() async {
    bool conn = await cekInternet();
    if (!conn) {
      return;
    }
    if (c.timerDashboardDriver.value == false) {
      return;
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/AntaranKurirStatus');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    // EasyLoading.dismiss();
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        if (c.antaranIntegrasi.value < hasil['jumlahOrder']) {
          FlutterRingtonePlayer.play(
            android: AndroidSounds.notification,
            ios: IosSounds.glass,
            looping: false, // Android only - API >= 28
            volume: 1, // Android only - API >= 28
            asAlarm: false, // Android only - all APIs
          );
        }
        c.antaranIntegrasi.value = hasil['jumlahOrder'];
        c.btnOnlineOffline.value = hasil['onoff'];
      }
    }
  }
}
