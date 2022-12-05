import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '/base/api_service.dart';
import 'initialize.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  //FIREBASE APP
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //HIVE BOX
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  Directory document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox<String>("sasukaDB");
  //END HIVE BOX
  final c = Get.put(ApiService());
  c.appid = await _getId(); // device id
  Hive.box<String>('sasukaDB').put('appid', c.appid);

  //print(appid);

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) {});

  // AwesomeNotifications().actionStream.listen((receivedNotification) {
  //   if (receivedNotification.id == 1) {
  //     Get.to(() => ChatPage());
  //   } else if (receivedNotification.id == 2) {
  //     Get.to(() => DashboardOutlet());
  //   } else if (receivedNotification.id == 3) {
  //     Get.to(() => DashboardOutletFM());
  //   } else if (receivedNotification.id == 4) {
  //     Get.to(() => DashboardOutletMP());
  //   } else if (receivedNotification.id == 5) {
  //     Get.to(() => Dashboardku());
  //   } else if (receivedNotification.id == 6) {
  //     Get.to(() => Dashboardku());
  //   } else if (receivedNotification.id == 7) {
  //     Get.to(() => Dashboardku());
  //   } else if (receivedNotification.id == 8) {
  //     Get.to(() => Dashboardku());
  //   } else if (receivedNotification.id == 9) {
  //     Get.to(() => PaymentPoint());
  //   } else if (receivedNotification.id == 10) {
  //     Get.to(() => NotifikasiAplikasi());
  //   }
  // });

  runApp(
    new InitializeApp(),
  );
}

Future<String> _getId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId; // unique ID on Android
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return //App();
        InitializeApp();
  }
}
