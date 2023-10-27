import 'package:degree/pages/login.dart';
import 'package:degree/pages/select_languages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({Key? key}) : super(key: key);

  @override
  State<OnboardScreen> createState() => _OnboardScreen();
}

class _OnboardScreen extends State<OnboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              // decoration: BoxDecoration(
              //     border: Border.all(color: Colors.black12),
              //     color: const Color.fromARGB(31, 220, 216, 216),
              //     borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Text(
                'Сайн байна уу! Би бол Jonsh!',
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Nunito',
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Image.asset(
              'assets/images/ic_splash.png',
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Сомни',
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 30,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: Color(0xff2675EC)),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Хаана ч хэзээ ч өөрийн хүссэн нэгэнтэйгээ хэл хамаарахгүй харилц.',
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.black54,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(Select_languages());
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Color(0xff2675EC),
                ),
                child: const Text(
                  'ЭХЛҮҮЛЭХ',
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.white,
                      fontSize: 15),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(LogIn());
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Color.fromARGB(255, 223, 212, 227),
                ),
                child: const Text(
                  'ШУУД НЭВТРЭХ',
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Color(0xff2675EC),
                      fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future callDelay(BuildContext context) async {
    print("call dellay21");
    await Future.delayed(const Duration(milliseconds: 5000), () {});
    Get.to(LogIn());
  }
}
