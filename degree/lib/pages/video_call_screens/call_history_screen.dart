import 'dart:developer';
import 'package:degree/pages/video_call_screens/history_list_screen.dart';
import 'package:degree/service/Controllers/dataController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreen();
}

class _CallHistoryScreen extends State<CallHistoryScreen> {
  final DataController _dataController = Get.find();

  String myUserName = '';

  @override
  void initState() {
    myUserName = _dataController.myUserName;
    _dataController.fetchCallHistories();
    log('init call history page');
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
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Container(
                width: 200,
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xff767680).withOpacity(0.12),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: const TabBar(
                  tabs: [
                    Tab(
                      text: "Бүгд",
                    ),
                    Tab(
                      text: "Алдсан",
                    ),
                  ],
                  unselectedLabelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Nunito'),
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(10)), // Creates border
                      color: Colors.white),
                ),
              ),
            ),
            centerTitle: true,
          ),
          body: TabBarView(
            children: [
              HistoryListScreen(
                calls: _dataController.audioMessages,
                isAll: true,
              ),
              HistoryListScreen(
                  calls: _dataController.missedMessages, isAll: false),
            ],
          ),
        ),
      ),
    );
  }
}
