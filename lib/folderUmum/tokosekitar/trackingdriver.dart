import 'dart:async';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as https;
// ignore: import_of_legacy_library_into_null_safe
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/warna.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../folderUmum/chat/view/chatDetailPage.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;

class TrackingDriverTS extends StatefulWidget {
  @override
  _TrackingDriverTSState createState() => _TrackingDriverTSState();
}

class _TrackingDriverTSState extends State<TrackingDriverTS> {
  Box dbbox = Hive.box<String>('sasukaDB');

  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  BitmapDescriptor kuriricon;

  List<Marker> _markers = [];

  LatLng currentLocation;
  LatLng destinationLocation;

  final c = Get.find<ApiService>();
  var latPenerima = -7.7;
  var longPenerima = 110.4;
  var latKurir = 0.0;
  var longKurir = 0.0;
  var latOutlet = 0.0;
  var longOutlet = 0.0;
  var dataSiap = false.obs;
  var trackingDriver = false;
  var iddriver = 0.obs;
  var outlet = ''.obs;
  var keterangan = 'Mohon tunggu'.obs;
  var gambarDriver = ''.obs;
  var namaDriver = ''.obs;
  var kendaraanDriver = ''.obs;
  var platNomorDriver = ''.obs;
  var ratingDriver = 0.0.obs;
  Timer timer;
  Timer timerCekStatus;
  Timer timeLokasiGpsDriver;
  var statusDriver = ''.obs;
  var latDriver = 0.0;
  var longDriver = 0.0;
  var tahapan = 0;
  var btnSelesai = false;
  var driverAda = false;
  var idChatDriver = '0';
  var idChatOutlet = '0';
  var fotoOutlet = '';

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;

  @override
  void initState() {
    super.initState();
    cekLokasidanOutlet();
    polylinePoints = PolylinePoints();
    // timer = Timer.periodic(
    //     Duration(seconds: 8), (Timer t) => cekStatusPerPeriode());
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    timerCekStatus?.cancel();
    timeLokasiGpsDriver?.cancel();
  }

  void setSourceAndDestinationMarkerIcon() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'images/JEMPUT.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'images/OUTLET.png');
    kuriricon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'images/mapDRIVER.png');
  }

  void setInitialLocation() {
    currentLocation = LatLng(latPenerima, longPenerima);
    destinationLocation = LatLng(latOutlet, longOutlet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (AppBar(
        backgroundColor: Warna.warnautama,
        title: Text('Pengiriman Paket'),
      )),
      body: (Stack(
        children: [
          LinearProgressIndicator(),
          (dataSiap.value == false)
              ? Container()
              : Container(
                  child: GoogleMap(
                      compassEnabled: false,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        showPinonMaps();
                        setPolylines();
                      },
                      markers: _markers.toSet(),
                      polylines: _polylines,
                      initialCameraPosition: CameraPosition(
                          zoom: CAMERA_ZOOM,
                          tilt: CAMERA_TILT,
                          bearing: CAMERA_BEARING,
                          target: currentLocation)),
                ),
          Container(
            margin: EdgeInsets.fromLTRB(11, 11, 11, 1),
            // height: Get.height * 0.35,
            child: Column(
              children: [
                (driverAda == true)
                    ? Card(
                        elevation: 1.0,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Obx(() => Container(
                                                width: Get.width * 0.15,
                                                height: Get.width * 0.15,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          gambarDriver.value),
                                                      fit: BoxFit.cover),
                                                ),
                                              )),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 12)),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text('Pesanan diantar oleh :',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Warna.grey)),
                                              Obx(() => Text(namaDriver.value,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Warna.grey))),
                                              Obx(() => Text(
                                                  kendaraanDriver.value,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Warna.grey))),
                                              Obx(() => Text(
                                                  platNomorDriver.value,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Warna.grey))),
                                            ],
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 1)),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 1)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      c.idChatLawan.value = idChatDriver;
                                      c.namaChatLawan.value = namaDriver.value;
                                      c.fotoChatLawan.value =
                                          gambarDriver.value;

                                      Get.to(() => ChatDetailPage());
                                    },
                                    child: Icon(Icons.chat,
                                        size: 28, color: Warna.warnautama),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                Padding(padding: EdgeInsets.only(top: 12)),
                Text('Pengantaran Paket Dari :',
                    style: TextStyle(fontSize: 14, color: Warna.grey)),
                Obx(() => Text(c.namaOutletTracking.value,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Warna.grey))),
              ],
            ),
          )
        ],
      )),
    );
  }

  cekLokasidanOutlet() async {
    var cekin = await cekInternet();
    if (cekin == true) {
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var kodetrx = c.kodetransaksiTOSEK.value;

      var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
      var bytes = utf8.encode(datarequest + '$token');
      var signature = md5.convert(bytes).toString();
      var user = dbbox.get('loginSebagai');

      var url = Uri.parse('${c.baseURL}/sasuka/showmapTS');

      final response = await https.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });

      // EasyLoading.dismiss();
      //print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'success') {
          latPenerima = hasil['latPenerima'];
          longPenerima = hasil['longPenerima'];
          latOutlet = hasil['latOutlet'];
          longOutlet = hasil['longOutlet'];
          latKurir = hasil['latKurir'];
          longKurir = hasil['longKurir'];
          keterangan.value = hasil['keterangan'];
          outlet.value = hasil['outlet'];
          iddriver.value = hasil['iddriver'];

          if (iddriver.value == 0) {
          } else {
            setState(() {
              var detDriver = hasil['detailDriver'];
              gambarDriver.value = detDriver[3];
              namaDriver.value = detDriver[0];
              kendaraanDriver.value = detDriver[1];
              platNomorDriver.value = detDriver[2];

              idChatDriver = hasil['iddriver'];
              //  idChatOutlet = hasil['idchatOutlet'];
              // fotoOutlet = hasil['fotoOutlet'];

              trackingDriver = true;
              driverAda = true;
            });
            timeLokasiGpsDriver = Timer.periodic(
                Duration(seconds: 10), (Timer t) => trackingGpsDriver());
          }

          setState(() {
            setSourceAndDestinationMarkerIcon();
            setInitialLocation();
            dataSiap.value = true;
          });
        } else if (hasil['status'] == 'failed') {
          Get.back();
          Get.snackbar('Tidak ada pengantaran',
              'Opps.. sepertinya tidak ada yang ditampilkan');
        }
      }
    }
  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyDDjqHtIUkj8UebTWpEmlbPexH8GZXoWOI',
        PointLatLng(latPenerima, longPenerima),
        PointLatLng(latOutlet, longOutlet));
    if (result.status == 'OK') {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {
        _polylines.add(Polyline(
            width: 10,
            color: Colors.blue,
            polylineId: PolylineId('polyline'),
            points: polylineCoordinates));
      });
    }
  }

  Future cekInternet() async {
    bool conn = true;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if ((connectivityResult == ConnectivityResult.mobile) ||
        (connectivityResult == ConnectivityResult.wifi)) {
      conn = true;
    } else {
      conn = false;
      AwesomeDialog(
        context: Get.context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        title: '',
        desc: '',
        body: Column(
          children: [
            Image.asset('images/nointernet.png'),
            Text('Opps..sepertinya internet tidak ditemukan',
                style: TextStyle(
                    fontSize: 20,
                    color: Warna.grey,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            Container(
              padding: EdgeInsets.fromLTRB(22, 7, 22, 11),
              child: Text(
                'periksa kembali koneksi internet kamu agar ${c.namaAplikasi} bisa mencari data yang kamu perlukan',
                style: TextStyle(fontSize: 14, color: Warna.grey),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 16)),
          ],
        ),
      )..show();
    }
    return conn;
  }

  void showPinonMaps() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId('sourcepin'),
          position: currentLocation,
          icon: sourceIcon));

      _markers.add(Marker(
          markerId: MarkerId('kurirpin'),
          position: destinationLocation,
          icon: kuriricon));

      _markers.add(Marker(
          markerId: MarkerId('destinationpin'),
          position: destinationLocation,
          icon: destinationIcon));
    });
  }

  trackingGpsDriver() async {
    // print('tracking driver');
    var cekin = await cekInternet();
    if (!mounted) {
      timeLokasiGpsDriver.cancel();
    }

    if (cekin == true) {
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var kodetrx = c.kodetransaksiTOSEK.value;

      var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
      var bytes = utf8.encode(datarequest + '$token');
      var signature = md5.convert(bytes).toString();
      var user = dbbox.get('loginSebagai');

      var url = Uri.parse('${c.baseURL}/sasuka/cekStatusdanLokasiTS');

      final response = await https.post(url, body: {
        "user": user,
        "appid": c.appid,
        "data_request": datarequest,
        "sign": signature
      });

      // EasyLoading.dismiss();
      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> hasil = jsonDecode(response.body);
        if (hasil['status'] == 'success') {
          statusDriver.value = hasil['alasan'];
          latDriver = hasil['latDriver'];
          longDriver = hasil['longDriver'];
          tahapan = hasil['tahapan'];
          var statusTrx = hasil['statusTrx'];

          moveMapTo(latDriver, longDriver);
          setState(() {
            _markers.remove(_markers.firstWhere(
                (Marker marker) => marker.markerId.value == 'kurirpin'));
            _markers.add(Marker(
                markerId: MarkerId('kurirpin'),
                position: LatLng(latDriver, longDriver),
                icon: kuriricon));
          });

          if ((statusTrx == 'Sukses')) {
            timeLokasiGpsDriver.cancel();
            // alertPerjalananSelesai();
          }
        } else if (hasil['status'] == 'failed') {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.warning,
            animType: AnimType.rightSlide,
            title: 'PERHATIAN !',
            desc: hasil['message'],
          )..show();
        } else if (hasil['status'] == 'Order Selesai') {
          AwesomeDialog(
            context: Get.context,
            dialogType: DialogType.success,
            animType: AnimType.rightSlide,
            dismissOnBackKeyPress: false,
            dismissOnTouchOutside: false,
            btnOkOnPress: () {
              Get.back();
            },
            title: 'Order Telah Selesai',
            desc: hasil['message'],
          )..show();
        }
      }
    }
  }

  moveMapTo(moveLat, moveLong) async {
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(moveLat, moveLong),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  }

  // cekStatusPengantaran() async {
  //   var cekin = await cekInternet();
  //   if (cekin == true) {
  //     var token = dbbox.get('token');
  //     var pid = dbbox.get('person_id');
  //     var kodetrx = c.kodetransaksiTOSEK.value;

  //     var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
  //     var bytes = utf8.encode(datarequest + '$token');
  //     var signature = md5.convert(bytes).toString();
  //     var user = dbbox.get('loginSebagai');

  //     var url = Uri.parse(
  //         '${c.baseURL}/sasuka/cekStatusPengantaranMP');

  //     final response = await https.post(url,
  //         body: {"user": user, "appid":c.appid, "data_request": datarequest, "sign": signature});

  //     print(response.body);
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> hasil = jsonDecode(response.body);
  //       if (hasil['status'] == 'success') {
  //         // terhubung dengan driver
  //         timer.cancel();
  //         timerCekStatus.cancel();

  //         cekLokasidanOutlet();

  //         //trackingGpsDriver();
  //       } else if (hasil['status'] == 'Driver tidak siap') {
  //         timer.cancel();
  //         timerCekStatus.cancel();
  //       }
  //     }
  //   }
  // }
}
