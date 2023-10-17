import 'dart:io';
import 'package:degree/firebase_options.dart';
import 'package:degree/pages/chat_more_screen.dart';
import 'package:degree/pages/splash_screen.dart';
import 'package:degree/service/auth.dart';
import 'package:degree/service/model/Customer.dart';
import 'package:degree/util/firebase.dart';
import 'package:degree/util/global_boxes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:degree/pages/home.dart';
import 'package:degree/pages/login.dart';
import 'package:degree/pages/register.dart';
import 'package:degree/service/Controller.dart';
import 'package:hive/hive.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'DataAPI.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  var appDir = await getApplicationSupportDirectory();
  Hive.init(appDir.path);
  Hive.registerAdapter(CustomerAdapter());
  usersBox = await Hive.openBox('testBox');
  //Data.addUser('English', 'Halh Mongolian', 'English', 'Halh Mongolian');

  // await Firebase.initializeApp(
  //     name: 'App', options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());

  Get.put(DataController());

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
      //  home: Chat_more_screen('k', 'l', ['o', 'op'], ['k', 'kl']),
      home: LogIn(),
    );
  }
}
