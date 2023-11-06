import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:degree/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:degree/service/controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Helper extends GetxController {
  final DataController _dataController = Get.find();

  void selectedImage() async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    File img = File(file.path);
    var time = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      await FirebaseStorage.instance
          .ref('${_dataController.myusername}/$time.png')
          .putFile(img);
    } catch (e) {
      log('image select: $e');
    }

    _dataController.picUrl.value = await FirebaseStorage.instance
        .ref('${_dataController.myusername}/$time.png')
        .getDownloadURL();

    // await DefaultCacheManager().emptyCache();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_dataController.id)
        .update({"Photo": _dataController.picUrl.value});
  }

  Widget drawerBuilder(String name, BuildContext context) {
    return Drawer(
      width: 300,
      elevation: 30,
      backgroundColor: const Color(0xFfFFFFFF),
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(0))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Settings",
                        style: TextStyle(
                          fontFamily: "Gilroy",
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff2675ec),
                          height: 27 / 22,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xff2675ec),
                          size: 25,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 90,
                        height: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onLongPress: selectedImage,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30)),
                                    border: Border.all(
                                        color: Colors.black.withOpacity(0.5))),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Obx(() {
                                    return CachedNetworkImage(
                                      imageUrl: _dataController.picUrl.value,
                                      width: 100,
                                      height: 100,
                                    );
                                    // return Image.network(
                                    //   _dataController.picUrl.value,
                                    //   fit: BoxFit.cover,
                                    //   height: 100,
                                    //   width: 100,
                                    // );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontFamily: "Manrope",
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff2675ec),
                            height: 30 / 23,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  DrawerItem(
                    title: 'Хэрэглэгчийн булан',
                    icon: Icons.supervised_user_circle_outlined,
                    myFunction: () {},
                  ),
                  DrawerItem(
                    title: 'Тусламж',
                    icon: Icons.help_outline,
                    myFunction: () {},
                  ),
                  DrawerItem(
                    title: 'Найзаа урих',
                    icon: Icons.people_outline,
                    myFunction: () {},
                  ),
                  DrawerItem(
                    title: 'Утасны жагсаалт',
                    icon: Icons.contact_mail_outlined,
                    myFunction: () {},
                  ),
                ],
              ),
              // TableCalendar(
              //   headerVisible: true,
              //   headerStyle: HeaderStyle(
              //     formatButtonVisible: false,
              //     titleTextStyle: TextStyle(
              //         fontSize: 18,
              //         color: Color(0xff2675ec),
              //         fontFamily: 'Manrope',
              //         fontWeight: FontWeight.w500),
              //   ),
              //   daysOfWeekHeight: 20,
              //   firstDay: DateTime.utc(2010, 10, 16),
              //   lastDay: DateTime.utc(2030, 3, 14),
              //   focusedDay: DateTime.now(),
              //   calendarStyle: CalendarStyle(
              //       weekendTextStyle: TextStyle(
              //           color: Color(0xff2675ec),
              //           fontFamily: 'Nunito',
              //           fontWeight: FontWeight.w400),
              //       defaultTextStyle: TextStyle(
              //           color: Color(0xff2675ec),
              //           fontFamily: 'Nunito',
              //           fontWeight: FontWeight.w400)),
              // ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              DrawerItem(
                title: 'Log out',
                icon: Icons.logout,
                myFunction: () async {
                  await FirebaseAuth.instance.signOut();

                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LogIn()),
                      (Route<dynamic> route) => false);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function() myFunction;
  const DrawerItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.myFunction});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: myFunction,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25, left: 10),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xff2675ec),
              size: 30,
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                    fontFamily: "Manrope",
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff2675ec),
                    height: 23 / 19,
                  ),
                  textAlign: TextAlign.left),
            ),
          ],
        ),
      ),
    );
  }
}
