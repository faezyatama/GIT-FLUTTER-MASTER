import 'dart:async';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as https;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import '/base/conn.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;

class SetLokasiOutletMakan extends StatefulWidget {
  @override
  _SetLokasiOutletMakanState createState() => _SetLokasiOutletMakanState();
}

class _SetLokasiOutletMakanState extends State<SetLokasiOutletMakan> {
  Box dbbox = Hive.box<String>('sasukaDB');
  final controllerHp = TextEditingController();
  var alamat = ''.obs;

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
        ImageConfiguration(devicePixelRatio: 2.0), 'images/OUTLET.png');
  }

  void setInitialLocation() {
    destinationLocation = LatLng(c.latitude.value, c.longitude.value);
    c.tempLat.value = c.latitude.value;
    c.tempLong.value = c.longitude.value;
  }

  @override
  Widget build(BuildContext context) {
    return (Stack(
      children: [
        (dataSiap.value == false)
            ? Container()
            : GoogleMap(
                compassEnabled: false,
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
          margin: EdgeInsets.fromLTRB(12, 55, 12, 12),
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: TextField(
                    style: TextStyle(fontSize: 25),
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
                            }),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11))),
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          c.latOutletMakanku.value = c.tempLat.value;
                          c.longOutletMakanku.value = c.tempLong.value;
                          Get.back();
                        },
                        child: Text('Pilih lokasi ini')),
                    Padding(padding: EdgeInsets.only(left: 11)),
                    SizedBox(
                      width: Get.width * 0.5,
                      child: Obx(() => Text(
                            alamat.value,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            style: TextStyle(fontSize: 15, color: Colors.blue),
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    ));
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
              title: 'Pilih lokasi Kamu', snippet: 'Tap dan geser penanda ya'),
          icon: destinationIcon));
    });
  }

  void onDragEnd(ltng) async {
    alamat.value = 'Alamat ditentukan pada koordinat peta';
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
    var cari = (controllerHp.text);
    var user = dbbox.get('loginSebagai');

    var datarequest =
        '{"pid":"$pid","lat":"$latitude","long":"$longitude","cari":"$cari"}';
    var bytes = utf8.encode(datarequest + '$token' + user);
    var signature = md5.convert(bytes).toString();

    var url = Uri.parse('${c.baseURLmakan}/mobileAppsOutlet/cekalamatgoogle');

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
        c.tempLat.value = hasil['latitude'];
        c.tempLong.value = hasil['longitude'];
        alamat.value = hasil['alamat'];
        setState(() {
          _markers.remove(_markers.firstWhere(
              (Marker marker) => marker.markerId.value == 'destinationpin'));

          _markers.add(Marker(
              markerId: MarkerId('destinationpin'),
              draggable: true,
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
        alamat.value = hasil['alamat'];
      }
    }
  }
}
