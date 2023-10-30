import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/firebase_options.dart';
import 'package:degree/pages/home.dart';
import 'package:degree/pages/login.dart';
import 'package:degree/pages/onboard_screen.dart';
import 'package:degree/pages/register.dart';
import 'package:degree/pages/select_languages.dart';
import 'package:degree/pages/splash_screen.dart';
import 'package:degree/service/auth.dart';
import 'package:degree/service/model/Customer.dart';
import 'package:degree/service/Controller.dart';
import 'package:degree/util/firebase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'DataAPI.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  //FirebaseUtils.main();
  var appDir = await getApplicationSupportDirectory();
  Hive.init(appDir.path);
  Hive.registerAdapter(CustomerAdapter());
  usersBox = await Hive.openBox('testBox');

  // await Firebase.initializeApp(
  //     name: 'App', options: DefaultFirebaseOptions.currentPlatform);

  print(DateTime.now());

  runApp(const MyApp());

  Get.put(DataController()).getChatRoomIds();
  await FirebaseMessaging.instance.requestPermission();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  // String? token = await FirebaseMessaging.instance.getAPNSToken();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      // home: FutureBuilder(
      //     future: AuthMethods().getcurrentUser(),
      //     builder: (context, AsyncSnapshot<dynamic> snapshot) {
      //       if (snapshot.hasData) {
      //         return Home();
      //       } else {
      //         return Register();
      //       }
      //     }),
      //home: Select_languages(),
      //home: SplashScreen(),

      home: LogIn(),
    );
  }
}
