import 'package:degree/pages/login_screens/login.dart';
import 'package:degree/pages/login_screens/select_languages.dart';
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
              width: double.infinity,
              child: const Text(
                'Communicate with ease!',
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Nunito',
                    color: Color(0xff434347)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Image.asset(
              'assets/images/ic_splash.png',
              scale: 1.5,
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Somni',
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
            // SizedBox(
            //   height: MediaQuery.of(context).size.height * 1 / 5,
            // ),
            const SizedBox(
              height: 80,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(const SelectLanguages());
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: const Color(0xff0057ff),
                ),
                child: const Text(
                  'START',
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
              margin: const EdgeInsets.symmetric(horizontal: 40),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(const LogIn());
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: const Color(0xfff1eff6),
                ),
                child: const Text(
                  'SIGN IN',
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
    // print("call dellay21");
    await Future.delayed(const Duration(milliseconds: 5000), () {});
    Get.to(const LogIn());
  }
}
