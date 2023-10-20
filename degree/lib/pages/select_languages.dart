import 'package:degree/pages/register.dart';
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
  List<RxBool> isSelected =
      List.generate(out_lans.length, (index) => false.obs, growable: false);
  List<String> retval = [];

  @override
  Widget build(BuildContext context) {
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
                height: 15,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  Image.asset('assets/images/ic_somni.png',
                      width: (MediaQuery.of(context).size.width - 40) * 2 / 7),
                  // SizedBox(
                  //   width: (MediaQuery.of(context).size.width - 40) * 1 / 5,
                  // ),
                  Spacer(),
                  Container(
                    width: (MediaQuery.of(context).size.width - 40) * 4 / 7,
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        color: const Color.fromARGB(31, 220, 216, 216),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Text(
                      'Та ямар хэлээр ярьж чаддаг вэ?',
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.5),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Spacer(
                    flex: 2,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(color: Colors.black12),
                width: double.infinity,
                height: 3,
              ),
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
                      fontWeight: FontWeight.w500),
                ),
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
                                        width: isSelected[index].value ? 3 : 1,
                                        color: isSelected[index].value
                                            ? Color(0xff2675EC)
                                            : Color(0xff8E8383)),
                                    color: isSelected[index].value
                                        ? Color(0xff2675EC).withOpacity(0.3)
                                        : Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                padding: EdgeInsets.symmetric(
                                    vertical: 18, horizontal: 15),
                                child: Row(
                                  children: [
                                    Text(
                                      out_lans[index],
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                              ),
                            ));
                      })),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Color(0xff8E8383), width: 1))),
                padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black38, // Shadow color
                      //     offset: Offset(2, 2), // Shadow position (x, y)
                      //     blurRadius: 4, // Spread of the shadow
                      //     spreadRadius: 0, // How much the shadow should expand
                      //   ),
                      // ],
                      ),
                  child: ElevatedButton(
                    onPressed: () {
                      for (var i = 0; i < out_lans.length; i++) {
                        if (isSelected[i].value) retval.add(out_lans[i]);
                      }

                      Get.to(Register(), arguments: retval);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Color(0xff2675EC),
                    ),
                    child: const Text(
                      'Үргэлжлүүлэх',
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.white,
                          fontSize: 17),
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
            color: Color(0Xff2675EC),
            fontSize: 22.0,
            fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }
}
