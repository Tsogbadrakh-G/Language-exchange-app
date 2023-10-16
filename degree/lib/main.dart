import 'dart:io';
import 'package:degree/firebase_options.dart';
import 'package:degree/pages/splash_screen.dart';
import 'package:degree/service/auth.dart';
import 'package:degree/util/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:degree/pages/home.dart';
import 'package:degree/pages/login.dart';
import 'package:degree/pages/register.dart';
import 'package:degree/service/Controller.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var appDoc = await path_provider.getApplicationDocumentsDirectory();
  // Hive.init(appDoc.path);
  // Hive.registerAdapter(CustomerAdapter());
  // userBox = await Hive.openBox('myBox');

  await Firebase.initializeApp(
      name: 'App', options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseUtils.main();

  runApp(const MyApp());

  Get.put(DataController());

  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();

//   print("Handling a background message: ${message.messageId}");
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
      home: SplashScreen(),
      // home: LogIn(),
    );
  }
}
