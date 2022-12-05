//ROUTE SUDAH DIPERIKSA
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
import '/base/conn.dart';
import '/base/warna.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:smooth_star_rating/smooth_star_rating.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;

class PetaPengantaranOjek extends StatefulWidget {
  @override
  _PetaPengantaranOjekState createState() => _PetaPengantaranOjekState();
}

class _PetaPengantaranOjekState extends State<PetaPengantaranOjek> {
  Box dbbox = Hive.box<String>('sasukaDB');

  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  BitmapDescriptor kuriricon;

  List<Marker> _markers = [];

  LatLng currentLocation;
  LatLng destinationLocation;

  final c = Get.find<ApiService>();
  var latJemput = -7.7;
  var longJemput = 110.4;
  var latDriver = 0.0;
  var longDriver = 0.0;
  var latTujuan = 0.0;
  var longTujuan = 0.0;
  var dataSiap = false.obs;
  var trackingDriver = false.obs;
  var btnSelesai = false.obs;
  var iddriver = '0'.obs;
  var gambarDriver = ''.obs;
  var namaDriver = ''.obs;
  var kendaraanDriver = ''.obs;
  var platNomorDriver = ''.obs;
  var alamatTujuan = ''.obs;
  var alamatJemput = ''.obs;
  var ketTujuan = ''.obs;
  var ketJemput = ''.obs;
  var ratingDriver = 5.0.obs;
  var statusDriver = ''.obs;
  var outlet = ''.obs;
  var keterangan = 'Mohon tunggu'.obs;
  var tahapan = 0;
  var rating = 5.0;

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;

  Timer timer;
  Timer timerCekStatus;
  Timer timeLokasiGpsDriver;

  @override
  void initState() {
    super.initState();
    cekLokasidanOutlet();
    polylinePoints = PolylinePoints();
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
        ImageConfiguration(devicePixelRatio: 2.0), 'images/TUJUAN.png');
    kuriricon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'images/mapDRIVER.png');
  }

  void setInitialLocation() {
    currentLocation = LatLng(latJemput, longJemput);
    destinationLocation = LatLng(latTujuan, longTujuan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pengantaran penumpang'),
          backgroundColor: Warna.warnautama,
        ),
        bottomNavigationBar: Obx(() => Container(
              margin: EdgeInsets.fromLTRB(22, 8, 22, 8),
              height: Get.height * 0.06,
              child: (c.buttonTerimaOrderKurir.value == true)
                  ? RawMaterialButton(
                      onPressed: () {
                        c.buttonTerimaOrderKurir.value = false;

                        if (c.tahapanOjek.value == '1') {
                          driverMenujuKePenjemputan();
                        } else if (c.tahapanOjek.value == '2') {
                          sampaiDiLokasiPenjemputan();
                        } else if (c.tahapanOjek.value == '3') {
                          menujuLokasiTujuan();
                        } else if (c.tahapanOjek.value == '4') {
                          alertSelesaiPengantaran();
                        } else if (c.tahapanOjek.value == '5') {}
                      },
                      constraints: BoxConstraints(),
                      elevation: 1.0,
                      fillColor: Warna.warnautama,
                      child: Obx(() => Text(
                            c.keteranganButtonOjek.value,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          )),
                      padding: EdgeInsets.fromLTRB(22, 6, 22, 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(33)),
                      ),
                    )
                  : RawMaterialButton(
                      onPressed: () {
                        Get.snackbar('Menunggu...',
                            'Silahkan menuju lokasi untuk tahapan selanjutnya',
                            snackPosition: SnackPosition.BOTTOM);
                      },
                      constraints: BoxConstraints(),
                      elevation: 0.0,
                      fillColor: Colors.grey[300],
                      child: Obx(() => Text(
                            c.keteranganButtonOjek.value,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          )),
                      padding: EdgeInsets.fromLTRB(22, 6, 22, 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(33)),
                      ),
                    ),
            )),
        body: Stack(
          children: [
            (dataSiap.value == false)
                ? Container()
                : Container(
                    // margin: EdgeInsets.only(top: Get.height * 0.15),
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
                            target: destinationLocation)),
                  ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 11, 5, 1),
              child: Column(
                children: [
                  Card(
                    child: RawMaterialButton(
                      onPressed: () async {
                        CameraPosition cPosition = CameraPosition(
                          zoom: CAMERA_ZOOM,
                          tilt: CAMERA_TILT,
                          bearing: CAMERA_BEARING,
                          target: LatLng(latJemput, longJemput),
                        );
                        final GoogleMapController controller =
                            await _controller.future;
                        controller.animateCamera(
                            CameraUpdate.newCameraPosition(cPosition));
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_city,
                              size: 25,
                              color: Colors.redAccent,
                            ),
                            Padding(padding: EdgeInsets.only(left: 11)),
                            SizedBox(
                              width: Get.width * 0.8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lokasi Penjemputan :',
                                    style: TextStyle(
                                        color: Warna.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Obx(() => Text(
                                        alamatJemput.value,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        style: TextStyle(
                                            color: Warna.grey, fontSize: 12),
                                      )),
                                  Obx(() => Text(
                                        'Ket : ${ketJemput.value}',
                                        style: TextStyle(
                                            color: Warna.grey, fontSize: 12),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: RawMaterialButton(
                      onPressed: () async {
                        CameraPosition cPosition = CameraPosition(
                          zoom: CAMERA_ZOOM,
                          tilt: CAMERA_TILT,
                          bearing: CAMERA_BEARING,
                          target: LatLng(latTujuan, longTujuan),
                        );
                        final GoogleMapController controller =
                            await _controller.future;
                        controller.animateCamera(
                            CameraUpdate.newCameraPosition(cPosition));
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Icon(
                              Icons.map,
                              size: 25,
                              color: Colors.green,
                            ),
                            Padding(padding: EdgeInsets.only(left: 11)),
                            SizedBox(
                              width: Get.width * 0.8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tujuan Perjalanan :',
                                    style: TextStyle(
                                        color: Warna.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Obx(() => Text(
                                        alamatTujuan.value,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        style: TextStyle(
                                            color: Warna.grey, fontSize: 12),
                                      )),
                                  Obx(() => Text(
                                        'Ket : ${ketTujuan.value}',
                                        style: TextStyle(
                                            color: Warna.grey, fontSize: 12),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
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

  cekLokasidanOutlet() async {
    var cekin = await cekInternet();
    if (cekin == true) {
      var token = dbbox.get('token');
      var pid = dbbox.get('person_id');
      var kodetrx = c.kodeTransaksiOjek.value;
      var user = dbbox.get('loginSebagai');

      var datarequest = '{"pid":"$pid","kodetrx":"$kodetrx"}';
      var bytes = utf8.encode(datarequest + '$token' + user);
      var signature = md5.convert(bytes).toString();

      var url = Uri.parse(
          '${c.baseURLdriver}/mobileAppsMitraDriver/cekPetaPerjalananDriverOjek');

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
          latJemput = hasil['latJemput'];
          longJemput = hasil['longJemput'];
          latTujuan = hasil['latTujuan'];
          longTujuan = hasil['longTujuan'];
          latDriver = hasil['latDriver'];
          longDriver = hasil['longDriver'];
          alamatJemput.value = hasil['alamatJemput'];
          alamatTujuan.value = hasil['alamatTujuan'];
          ketJemput.value = hasil['ketJemput'];
          ketTujuan.value = hasil['ketTujuan'];
          c.kodeTransaksiMotor.value = hasil['kodetrx'];

          iddriver.value = hasil['idDriver'];
          if (iddriver.value == '0') {
          } else {
            var detDriver = hasil['detailDriver'];
            gambarDriver.value = detDriver[3];
            namaDriver.value = detDriver[0];
            kendaraanDriver.value = detDriver[1];
            platNomorDriver.value = detDriver[2];
            setState(() {
              trackingDriver.value = true;
            });
          }

          setState(() {
            setSourceAndDestinationMarkerIcon();
            setInitialLocation();
            dataSiap.value = true;
          });
        } else if (hasil['status'] == 'failed') {
          // Get.back();
          Get.snackbar('Tidak ada pengantaran',
              'Opps.. sepertinya tidak ada yang ditampilkan');
        }
      }
    }
  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyDDjqHtIUkj8UebTWpEmlbPexH8GZXoWOI',
        PointLatLng(latJemput, longJemput),
        PointLatLng(latTujuan, longTujuan));
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

  void alertSelesaiPengantaran() {
    AwesomeDialog(
      context: Get.context,
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      title: '',
      desc: '',
      body: Column(
        children: [
          Image.asset(
            'images/secure.png',
            width: Get.width * 0.3,
          ),
          Text('Selesai Pengantaran',
              style: TextStyle(
                  fontSize: 18,
                  color: Warna.warnautama,
                  fontWeight: FontWeight.w600)),
          Padding(padding: EdgeInsets.only(top: 16)),
          Text('Terima kasih telah mengantarkan pelanggan ke tempat tujuannya',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center),
          Text(
            'Berikan ratting kepada pelanggan yuk',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Warna.grey),
            textAlign: TextAlign.center,
          ),
          Padding(padding: EdgeInsets.only(top: 9)),
          SmoothStarRating(
              allowHalfRating: false,
              onRated: (v) {
                rating = v;
              },
              starCount: 5,
              rating: rating,
              size: 45.0,
              isReadOnly: false,
              color: Colors.green,
              borderColor: Colors.green,
              spacing: 0.0),
          Padding(padding: EdgeInsets.only(top: 16)),
          RawMaterialButton(
            constraints: BoxConstraints(minWidth: Get.width * 0.7),
            elevation: 1.0,
            fillColor: Warna.warnautama,
            child: Text(
              'Selesaikan Pengantaran',
              style: TextStyle(color: Warna.putih, fontSize: 14),
            ),
            padding: EdgeInsets.fromLTRB(18, 9, 18, 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            onPressed: () {
              selesaikanPengantaran();
            },
          ),
        ],
      ),
    )..show();
  }

  void selesaikanPengantaran() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kj = c.kodeTransaksiOjek.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodetrx":"$kj","rating":"$rating"}';

    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURL}/driverKurir/SelesaikanPengantaranOjekViaDriver');

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
        AwesomeDialog(
          context: Get.context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Pengantaran Selesai',
          desc: 'Pengantaran telah berhasil diselesaikan',
          btnCancelText: 'OK',
          btnCancelColor: Colors.green,
          btnCancelOnPress: () {
            Get.back();
            Get.back();
            Get.back();
          },
        )..show();
      }
    }
  }

  void driverMenujuKePenjemputan() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kj = c.kodeTransaksiOjek.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodetrx":"$kj"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/driverMenujuKePenjemputan');

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
        setState(() {
          c.tahapanOjek.value = '2';
          c.keteranganButtonOjek.value = 'Sampai di Lokasi Penjemputan';
          //move to penjemputan
        });
        CameraPosition cPosition = CameraPosition(
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING,
          target: LatLng(latJemput, longJemput),
        );
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
      }
    }
  }

  void sampaiDiLokasiPenjemputan() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kj = c.kodeTransaksiOjek.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodetrx":"$kj"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/sampaiDiLokasiPenjemputan');

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
        setState(() {
          c.tahapanOjek.value = '3';
          c.keteranganButtonOjek.value = 'Menuju ke Lokasi Tujuan';
          //move to penjemputan
        });
        CameraPosition cPosition = CameraPosition(
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING,
          target: LatLng(latJemput, longJemput),
        );
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
      }
    }
  }

  void menujuLokasiTujuan() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var kj = c.kodeTransaksiOjek.value;
    var user = dbbox.get('loginSebagai');

    var datarequest = '{"pid":"$pid","kodetrx":"$kj"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse(
        '${c.baseURLdriver}/mobileAppsMitraDriver/menujuLokasiTujuan');

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
        setState(() {
          c.tahapanOjek.value = '4';
          c.keteranganButtonOjek.value = 'Pengantaran Selesai';
          //move to penjemputan
        });
        CameraPosition cPosition = CameraPosition(
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING,
          target: LatLng(latTujuan, longTujuan),
        );
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
      }
    }
  }
}
