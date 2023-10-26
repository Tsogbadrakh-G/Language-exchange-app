import 'package:degree/pages/history_list_screen.dart';
import 'package:degree/pages/home.dart';
import 'package:degree/service/Controller.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

class Call_history_screen extends StatefulWidget {
  const Call_history_screen({Key? key}) : super(key: key);

  @override
  State<Call_history_screen> createState() => _Call_history_screen();
}

class _Call_history_screen extends State<Call_history_screen> {
  DataController _dataController = Get.find();

  String myUserName = '';

  @override
  void initState() {
    myUserName = _dataController.myusername;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            // title: Text('hi'),
            // actions: [
            //   const TabBar(
            //     tabs: [
            //       Tab(
            //         text: "Бүгд",
            //       ),
            //       Tab(
            //         text: "Алдсан",
            //       ),
            //     ],
            //     unselectedLabelStyle:
            //         TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            //     indicatorColor: Color(0xff79D6FB),
            //     labelColor: Color(0xff79D6FB),
            //   ),
            // ],
            title: const TabBar(
              tabs: [
                Tab(
                  text: "Бүгд",
                  
                ),
                Tab(
                  text: "Алдсан",
                ),
              ],
              unselectedLabelStyle:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              indicatorColor: Color(0xff2675EC),
              labelColor: Color(0xff2675EC),
            ),
            centerTitle: true,
          ),
          body: TabBarView(
            children: [
              History_list_screen(
                calls: _dataController.audioMessages,
                isAll: true,
              ),
              History_list_screen(
                calls: _dataController.missedMessages,
                isAll: true,
              ),
              // Center(
              //   child: Text("Calls"),
              // ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            child: Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(Call_history_screen());
                    },
                    child: Image.asset('assets/images/ic_call.png',
                        width: 80, height: 80, color: Color(0xff007AFF)),
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(Home());
                    },
                    child: Image.asset(
                      'assets/images/ic_chat.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
