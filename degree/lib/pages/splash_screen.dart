import 'package:degree/pages/onboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    callDelay(context);
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ic_splash.png',
            ),
            const SizedBox(
              height: 10,
            ),
            // Text(
            //   "mono",
            //   style: TextStyle(
            //       decoration: TextDecoration.none,
            //       fontSize: 32.0,
            //       color: Colors.black54),
            // ),
          ],
        ),
      ),
    );
  }

  Future callDelay(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 3000), () {});

    Get.to(const OnboardScreen());
  }
}
