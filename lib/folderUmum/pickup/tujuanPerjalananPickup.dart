import 'dart:async';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import '../../base/notifikasiBuatAkun.dart';
import '/base/api_service.dart';
import '/base/conn.dart';
import 'penjemputanPickup.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;

class TujuanPerjalananPickup extends StatefulWidget {
  @override
  _TujuanPerjalananPickupState createState() => _TujuanPerjalananPickupState();
}

class _TujuanPerjalananPickupState extends State<TujuanPerjalananPickup> {
  Box dbbox = Hive.box<String>('sasukaDB');
  final controllerHp = TextEditingController();

  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor destinationIcon;

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
    dataSiap.value = true;
    // timer = Timer.periodic(
    //     Duration(seconds: 8), (Timer t) => cekStatusPerPeriode());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void setSourceAndDestinationMarkerIcon() async {
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0), 'images/TUJUAN.png');
  }

  void setInitialLocation() {
    c.alamatTujuanPickup.value = '';
    destinationLocation = LatLng(c.latitude.value, c.longitude.value);
    c.tempLat.value = c.latitude.value;
    c.tempLong.value = c.longitude.value;
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text(
            'Tujuan Perjalanan Pickup ?',
          ),
          backgroundColor: Colors.green,
        ),
        bottomNavigationBar: SizedBox(
          height: Get.height * 0.13,
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 7)),
              Row(
                children: [
                  Padding(padding: EdgeInsets.only(left: 11)),
                  SizedBox(
                    width: Get.width * 0.9,
                    child: Obx(() => Row(
                          children: [
                            (c.alamatTujuanPickup.value == '')
                                ? Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: Colors.grey, size: 30),
                                      Text(
                                        'Tujuan Belum ditentukan',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.grey),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: Colors.blue[900], size: 30),
                                      SizedBox(
                                        width: Get.width * 0.75,
                                        child: Text(
                                          c.alamatTujuanPickup.value,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.blue[900]),
                                        ),
                                      ),
                                    ],
                                  )
                          ],
                        )),
                  ),
                ],
              ),
              SizedBox(
                width: Get.width * 0.8,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side: BorderSide(color: Colors.white)))),
                    onPressed: () {
                      //TAMU OR MEMBER
                      if (c.loginAsPenggunaKita.value == 'Member') {
                        if (c.alamatTujuanPickup.value != '') {
                          c.latTujuanPickup.value = c.tempLat.value;
                          c.longTujuanPickup.value = c.tempLong.value;
                          Get.to(() => DimanaDijemputPickup());
                        } else {
                          Get.snackbar('Alamat Belum Ditentukan',
                              'Tentukan alamat tujuan kamu, Gunakan pencarian atau geser penanda pada peta',
                              snackPosition: SnackPosition.BOTTOM);
                        }
                      } else {
                        var judulF = 'Akun ${c.namaAplikasi} Dibutuhkan ?';
                        var subJudul =
                            'Yuk Buka akun ${c.namaAplikasi} sekarang, hanya beberapa langkah akun kamu sudah aktif loh...';
                        bukaLoginPage(judulF, subJudul);
                      }
                      //END TAMU OR MEMBER
                    },
                    child: Text('Pilih alamat ini')),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            (dataSiap.value == false)
                ? Container()
                : Container(
                    padding: EdgeInsets.only(top: Get.height * 0.11),
                    child: GoogleMap(
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
                  ),
            Container(
              margin: EdgeInsets.fromLTRB(12, 5, 12, 12),
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: TextField(
                        style: TextStyle(fontSize: 22),
                        controller: controllerHp,
                        decoration: InputDecoration(
                            labelText: 'Cari lokasi ?',
                            labelStyle: TextStyle(fontSize: 15),
                            prefixIcon: Icon(Icons.map),
                            suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.search,
                                  size: 33,
                                ),
                                onPressed: () {
                                  carilokasigoogle();
                                  Focus.of(Get.context).unfocus();
                                }),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(45))),
                      ),
                    ),
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
            print('woke');
            onDragEnd(ltng);
          },
          position: destinationLocation,
          infoWindow: InfoWindow(
              title: 'Pilih lokasi Tujuan',
              snippet: 'Tap dan geser penanda ya'),
          icon: destinationIcon));
    });
  }

  void onDragEnd(ltng) async {
    c.alamatTujuanPickup.value = 'Alamat ditentukan pada koordinat peta';
    c.tempLat.value = ltng.latitude;
    c.tempLong.value = ltng.longitude;
    controllerHp.text = '';

    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(c.tempLat.value, c.tempLong.value),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  }

  void carilokasigoogle() async {
    bool conn = await cekInternet();
    if (!conn) {
      return noInternetConnection();
    }
    Box dbbox = Hive.box<String>('sasukaDB');
    var token = dbbox.get('token');
    var pid = dbbox.get('person_id');
    var latitude = c.latitude.value;
    var longitude = c.longitude.value;
    var cari = controllerHp.text;
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","lat":"$latitude","long":"$longitude","cari":"$cari"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLdriver}/mobileAppsUser/cekTujuanPickup');

    final response = await https.post(url, body: {
      "user": user,
      "appid": c.appid,
      "data_request": datarequest,
      "sign": signature,
      "package": c.packageName
    });

    // EasyLoading.dismiss();

    if (response.statusCode == 200) {
      Map<String, dynamic> hasil = jsonDecode(response.body);
      if (hasil['status'] == 'success') {
        c.tempLat.value = hasil['latitude'];
        c.tempLong.value = hasil['longitude'];

        c.ketTujuanPickup.value = controllerHp.text;
        c.alamatTujuanPickup.value = hasil['alamat'];

        setState(() {
          _markers.remove(_markers.firstWhere(
              (Marker marker) => marker.markerId.value == 'destinationpin'));

          _markers.add(Marker(
              markerId: MarkerId('destinationpin'),
              position: LatLng(c.tempLat.value, c.tempLong.value),
              icon: destinationIcon));
        });
        CameraPosition cPosition = CameraPosition(
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING,
          target: LatLng(c.tempLat.value, c.tempLong.value),
        );
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
      } else if (hasil['status'] == 'not found') {
        c.alamatTujuanPickup.value = '';
      }
    }
  }
}
