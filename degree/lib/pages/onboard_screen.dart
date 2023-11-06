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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 1 / 5,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 80),
              width: double.infinity,
              child: Text(
                'Санаа амар харилц!',
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Nunito',
                    color: Color(0xff434347)),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Image.asset(
                'assets/images/ic_splash.png',
                scale: 1.5,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Сомни',
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 25,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      color: Color(0xff0057ff)),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // SizedBox(
            //   height: MediaQuery.of(context).size.height * 1 / 5,
            // ),
            SizedBox(
              height: 80,
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
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: Color(0xff0057ff),
                ),
                child: const Text(
                  'ЭХЛҮҮЛЭХ',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                      color: Colors.white,
                      fontSize: 14),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
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
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: Color(0xfff1eff6),
                ),
                child: const Text(
                  'ШУУД НЭВТРЭХ',
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      color: Color(0xff0057ff),
                      fontSize: 14),
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
