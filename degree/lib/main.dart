import 'package:degree/pages/select_languages.dart';
import 'package:degree/pages/splash_screen.dart';
import 'package:degree/service/model/Customer.dart';
import 'package:degree/pages/login.dart';
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
  // Map<String, String> val = Map();
  // val['ts'] = '12:20 , 10/24/2023';
  // int year = int.parse(val['ts'].toString().substring(14, 18));
  // int month = int.parse(val['ts'].toString().substring(8, 10));
  // int day = int.parse(val['ts'].toString().substring(11, 13));
  // int hour = int.parse(val['ts'].toString().substring(0, 2));
  // int min = int.parse(val['ts'].toString().substring(3, 5));
  // print('time: $year,');
  // print('month: $month,');
  // print('day: $day');
  // print('hour: $hour');
  // print('min: $min');

  // await Firebase.initializeApp(
  //     name: 'App', options: DefaultFirebaseOptions.currentPlatform);

  print(DateTime.now());

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
      home: SplashScreen(),
      //home: LogIn(),
    );
  }
}
