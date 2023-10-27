import 'package:degree/pages/register.dart';
import 'package:degree/service/Controller.dart';
import 'package:degree/service/model/somni_alert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

List<String> out_lans = [
  'Halh Mongolian',
  'Bengali',
  'Catalan',
  'Czech',
  'Danish',
  'Dutch',
  'English',
  'Estonian',
  'Finnish',
  'French',
  'German',
  'Hindi',
  'Indonesian',
  'Italian',
  'Japanese',
  'Korean',
  'Maltese',
  'Mandarin Chinese',
  'Modern Standard Arabic',
  'Northern Uzbek',
  'Polish',
  'Portuguese',
  'Romanian',
  'Russian',
  'Slovak',
  'Spanish',
  'Swahili',
  'Swedish',
  'Tagalog',
  'Telugu',
  'Thai',
  'Turkish',
  'Ukrainian',
  'Urdu',
  'Vietnamese',
  'Welsh',
  'Western Persian'
];

class Select_languages extends StatefulWidget {
  const Select_languages({Key? key}) : super(key: key);

  @override
  State<Select_languages> createState() => _OnboardScreen();
}

class _OnboardScreen extends State<Select_languages> {
  DataController _dataController = Get.find();
  List<RxBool> isSelected =
      List.generate(out_lans.length, (index) => false.obs, growable: false);
  List<String> retval = [];

  @override
  void initState() {
    print('init select languages page $retval');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build select');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SelectLanguage(),
      body: Container(
          // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     Spacer(),
              //     Image.asset('assets/images/ic_somni.png',
              //         width: (MediaQuery.of(context).size.width - 40) * 2 / 7),
              //     // SizedBox(
              //     //   width: (MediaQuery.of(context).size.width - 40) * 1 / 5,
              //     // ),
              //     Spacer(),
              //     Container(
              //       width: (MediaQuery.of(context).size.width - 40) * 4 / 7,
              //       padding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
              //       margin: EdgeInsets.symmetric(horizontal: 10),
              //       // decoration: BoxDecoration(
              //       //     border: Border.all(color: Colors.black12),
              //       //     color: const Color.fromARGB(31, 220, 216, 216),
              //       //     borderRadius: BorderRadius.all(Radius.circular(20))),
              //       child: Text(
              //         'Та ямар хэлээр ярьж чаддаг вэ?',
              //         style: TextStyle(
              //             decoration: TextDecoration.none,
              //             fontSize: 18,
              //             fontWeight: FontWeight.w600,
              //             fontFamily: 'Rubik',
              //             color: Colors.black,
              //             height: 1.5),
              //         textAlign: TextAlign.start,
              //       ),
              //     ),
              //     Spacer(
              //       flex: 2,
              //     ),
              //   ],
              // ),
              // SizedBox(
              //   height: 20,
              // ),

              Container(
                // decoration: BoxDecoration(
                //   border: Border(
                //       bottom: BorderSide(color: Color(0xff8E8383), width: 1)),
                // ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                width: double.infinity,
                child: Text(
                  'Өөрийн ярьдаг хэлээ сонгоно уу:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                //decoration: BoxDecoration(color: Colors.black12),
                width: double.infinity,
                child: Divider(),
                // height: 3,
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: out_lans.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              isSelected[index].value =
                                  !isSelected[index].value;
                            },
                            child: Obx(
                              () => Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: isSelected[index].value ? 1 : 1,
                                        color: isSelected[index].value
                                            ? Color(0xff2675EC)
                                            : Color(0xff8E8383)),
                                    color: isSelected[index].value
                                        ? Color(0xff2675EC).withOpacity(0.3)
                                        : Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                padding: EdgeInsets.symmetric(
                                    vertical: 18, horizontal: 15),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.asset(
                                        'assets/images/flags/German.png',
                                        width: 30,
                                        height: 25,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 14,
                                    ),
                                    Text(
                                      out_lans[index],
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Spacer(),
                                    isSelected[index].value
                                        ? Icon(
                                            Icons.check_circle_outline,
                                            color: Color(0xff2675EC),
                                            size: 23,
                                          )
                                        : Offstage()
                                  ],
                                ),
                              ),
                            ));
                      })),
              Container(
                decoration: BoxDecoration(
                    // border: Border(
                    //   top: BorderSide(color: Color(0xff8E8383), width: 1),
                    // ),
                    ),
                padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(),
                  child: ElevatedButton(
                    onPressed: () {
                      for (var i = 0; i < out_lans.length; i++) {
                        if (isSelected[i].value)
                          _dataController.native_lans.add(out_lans[i]);
                      }

                      if (_dataController.native_lans.length == 0)
                        SomniAlerts.showMyDialog(context,
                            'Та өөрийн ярьж чаддаг хэлээ сонгоогүй байна.');
                      else
                        Get.to(Register());
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Color(0xff2675EC),
                    ),
                    child: const Text(
                      'Үргэлжлүүлэх',
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  PreferredSizeWidget SelectLanguage() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
          onPressed: () {
            retval = [];
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios)),
      title: Text(
        "Ярих хэлээ сонгох",
        style: TextStyle(
            fontFamily: 'Rubik',
            color: Color(0Xff2675EC),
            fontSize: 22.0,
            fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
    );
  }
}
