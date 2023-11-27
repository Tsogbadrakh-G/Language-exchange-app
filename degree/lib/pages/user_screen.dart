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
        backgroundColor: const Color(0xffF7F7F7),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: Stack(children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.5))),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Obx(() {
                              return CachedNetworkImage(
                                imageUrl: _dataController.picUrl.value,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              );
                            }),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 209, 204, 204),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
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
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      _dataController.myName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: Color(0xff2675EC).withOpacity(0.5)))),
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    children: [
                      // Divider(
                      //   color: Color(0xff2675EC).withOpacity(0.5),
                      // ),
                      Row(
                        children: [
                          const Icon(Icons.supervised_user_circle_outlined),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            _dataController.myUserName,
                            style: const TextStyle(fontFamily: 'Nunito'),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.language_outlined),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(_dataController.myNativeLan)
                        ],
                      ),
                      // RichText(
                      //   text: TextSpan(
                      //     text: 'Speaks: ',
                      //     style: const TextStyle(
                      //       fontFamily: 'Manrope',
                      //       fontSize: 15,
                      //       fontWeight: FontWeight.w600,
                      //       color: Color(0xff000000),
                      //     ),
                      //     children: <TextSpan>[
                      //       for (var i = 0;
                      //           i < (_dataController.nativeLans).length - 1;
                      //           i++)
                      //         TextSpan(
                      //             text: '${_dataController.nativeLans[i]}, ',
                      //             style: const TextStyle(
                      //               fontWeight: FontWeight.w400,
                      //               color: Color(0xff000000),
                      //             )),
                      //       // TextSpan(
                      //       //     text:
                      //       //         '${_dataController.nativeLans[(_dataController.nativeLans).length - 1]}',
                      //       //     style: const TextStyle(
                      //       //       fontWeight: FontWeight.w400,
                      //       //       color: Color(0xff000000),
                      //       //     )),
                      //     ],
                      //   ),
                      // )
                      //TextField(),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ));
  }
}
