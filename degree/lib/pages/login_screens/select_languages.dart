import 'package:degree/pages/login_screens/register.dart';
import 'package:degree/service/Controllers/dataController.dart';
import 'package:degree/service/somni_alert.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectLanguages extends StatefulWidget {
  const SelectLanguages({Key? key}) : super(key: key);

  @override
  State<SelectLanguages> createState() => _OnboardScreen();
}

class _OnboardScreen extends State<SelectLanguages> {
  final DataController _dataController = Get.find();
  late List<RxBool> isSelected;
  List<String> retval = [];

  String? selectedValue;

  @override
  void initState() {
    selectedValue = 'English';
    _dataController.inputLans.remove(selectedValue);
    // print('init select languages page $retval');
    isSelected = List.generate(
        _dataController.inputLansLength, (index) => false.obs,
        growable: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //print('build select');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: selectLanguageAppBar(),
      body: SizedBox(
          // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                width: double.infinity,
                child: const Text(
                  'Өөрийн төрөлх хэлээ сонгоно уу:',
                  style: TextStyle(
                    color: Color(0xff434347),
                    fontFamily: 'Nunito',
                    fontSize: 17,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Row(
                      children: [
                        selectedValue == null
                            ? Container(
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Image.asset(
                                  'assets/images/flags/English.png',
                                  width: 30,
                                  height: 30,
                                ),
                              )
                            : Container(
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Image.asset(
                                  'assets/images/flags/$selectedValue.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            selectedValue ?? 'English',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    items: List<String>.from(_dataController.inputLans)
                        .map((String item) => DropdownMenuItem<String>(
                              value: item,
                              child: Row(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Image.asset(
                                      'assets/images/flags/$item.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedValue = value;
                        _dataController.inputLans.remove(selectedValue);
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      height: 50,
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black26,
                          ),
                          color: Colors.white),
                      elevation: 2,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 250,
                      width: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                      ),
                      offset: const Offset(0, 0),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: MaterialStateProperty.all<double>(6),
                        thumbVisibility: MaterialStateProperty.all<bool>(true),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.only(left: 14, right: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                width: double.infinity,
                child: const Text(
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
                      itemCount: _dataController.inputLansLength,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            isSelected[index].value = !isSelected[index].value;
                          },
                          child: Obx(
                            () => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: isSelected[index].value ? 1 : 1,
                                      color: isSelected[index].value
                                          ? const Color(0xff2675EC)
                                          : const Color(0xff8E8383)),
                                  color: isSelected[index].value
                                      ? const Color(0xff2675EC).withOpacity(0.3)
                                      : Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.asset(
                                        'assets/images/flags/${_dataController.inputLans[index]}.png',
                                        width: 30,
                                        height: 25,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 14,
                                    ),
                                    Text(
                                      _dataController.inputLans[index],
                                      style: const TextStyle(
                                          color: Color(0xff434347),
                                          fontSize: 15,
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const Spacer(),
                                    isSelected[index].value
                                        ? const Icon(
                                            Icons.check_circle_outline,
                                            color: Color(0xff2675EC),
                                            size: 23,
                                          )
                                        : const Offstage()
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      })),
              Container(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                width: double.infinity,
                child: Container(
                  decoration: const BoxDecoration(),
                  child: ElevatedButton(
                    onPressed: () {
                      for (var i = 0;
                          i < _dataController.inputLansLength;
                          i++) {
                        if (isSelected[i].value) {
                          _dataController.nativeLans
                              .add(_dataController.inputLans[i]);
                        }
                      }
                      _dataController.myNativeLan = selectedValue ?? 'English';

                      if (_dataController.nativeLans.isEmpty) {
                        SomniAlerts.showMyDialog(context,
                            'Та өөрийн ярьж чаддаг хэлээ сонгоогүй байна.');
                      } else {
                        Get.to(const Register());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: const Color(0xff0057ff),
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

  PreferredSizeWidget selectLanguageAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
          onPressed: () {
            retval = [];
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios)),
      title: const Text(
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
