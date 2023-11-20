import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreen();
}

class _UserScreen extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back_ios)),
          title: const Text(
            "User",
            style: TextStyle(
                fontFamily: 'Nunito',
                color: Color(0Xff2675EC),
                fontSize: 17.0,
                fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),
        body: const SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [Text('data')],
          ),
        ));
  }
}
