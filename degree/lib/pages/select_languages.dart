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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                width: double.infinity,
                child: Text(
                  'Өөрийн ярьдаг хэлээ сонгоно уу:',
                  style: TextStyle(
                    color: Color(0xff434347),
                    fontFamily: 'Nunito',
                    fontSize: 17,
                  ),
                ),
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: out_lans.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            isSelected[index].value = !isSelected[index].value;
                          },
                          child: Obx(
                            () => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Container(
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
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
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
                                          color: Color(0xff434347),
                                          fontSize: 15,
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w500),
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
                            ),
                          ),
                        );
                      })),
              Container(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 20),
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
                      padding: EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Color(0xff0057ff),
                    ),
                    child: const Text(
                      'Үргэлжлүүлэх',
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontFamily: 'Nunito',
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
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
            fontFamily: 'Nunito',
            color: Color(0xff0057ff),
            fontSize: 25.0,
            fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
    );
  }
}
