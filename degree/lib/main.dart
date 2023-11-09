import 'package:degree/util/firebase_options.dart';
import 'package:degree/pages/onboard_screen.dart';
import 'package:degree/models/customer.dart';
import 'package:degree/service/controller.dart';
import 'package:degree/util/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'service/data_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      name: 'App', options: DefaultFirebaseOptions.currentPlatform);

  var appDir = await getApplicationSupportDirectory();
  Hive.init(appDir.path);
  Hive.registerAdapter(CustomerAdapter());
  usersBox = await Hive.openBox('testBox');

  runApp(const MyApp());

  Get.put(DataController());
  Get.put(Helper());
  //FirebaseUtils.main();
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
      home: const OnboardScreen(),
      // home: LogIn(),
    );
  }
}
