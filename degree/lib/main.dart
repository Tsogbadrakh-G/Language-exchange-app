import 'package:degree/Video_call_screen.dart';
import 'package:degree/pages/forgotpassword.dart';
import 'package:degree/pages/signin.dart';
import 'package:degree/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // name: "com.example.degree",
      //  options: DefaultFirbaseOptions.currentPlatform,

      );
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Registration Form',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const SignIn(),
    );
  }
}
