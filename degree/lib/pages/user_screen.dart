import 'package:cached_network_image/cached_network_image.dart';
import 'package:degree/service/Controllers/dataController.dart';
import 'package:degree/service/Controllers/helpChatMainController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreen();
}

class _UserScreen extends State<UserScreen> {
  final DataController _dataController = Get.find();
  final HelperChatMainController _helperChatMainController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
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
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(border: Border.all()),
                child: Stack(children: [
                  Align(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30)),
                          border:
                              Border.all(color: Colors.black.withOpacity(0.5))),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Obx(() {
                          return CachedNetworkImage(
                            imageUrl: _dataController.picUrl.value,
                            width: 90,
                            height: 90,
                          );
                        }),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 209, 204, 204),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: InkWell(
                        onTap: _helperChatMainController.selectedImage,
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ));
  }
}
