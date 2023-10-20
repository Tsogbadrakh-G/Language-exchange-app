import 'package:degree/DataAPI.dart';
import 'package:degree/service/Controller.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

List<String> voice_in_lans = [
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

final List<String> input_lans = [
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

class Chat_more_screen extends StatefulWidget {
  final usrId, name, profileUrl, native_lans, channel;
  const Chat_more_screen(
      this.usrId, this.name, this.profileUrl, this.native_lans, this.channel,
      {Key? key})
      : super(key: key);

  @override
  State<Chat_more_screen> createState() => _Chat_more_screen();
}

class _Chat_more_screen extends State<Chat_more_screen> {
  DataController _dataController = Get.find();
  String? selectedValueFrom1;
  String? selectedValueTo1;
  String? selectedValueFrom2;
  String? selectedValueTo2;
  String key = '';
  @override
  void initState() {
    key = widget.channel + _dataController.myusername;
    print('init key: $key');
    if (usersBox.get(key) != null) {
      print('users box is not null');
      selectedValueFrom1 = usersBox.get(key)!.trans_from_voice;
      selectedValueTo1 = usersBox.get(key)!.trans_to_voice;
      selectedValueFrom2 = usersBox.get(key)!.trans_from_msg;
      selectedValueTo2 = usersBox.get(key)!.trans_to_msg;
      print(
          'selected vals: from1: $selectedValueFrom1 to1:$selectedValueTo1 from2: $selectedValueFrom2 to2: $selectedValueTo2');
    } else
      print('users box is null');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'name: ${widget.name}, profile url:  ${widget.profileUrl}, native lans: ${widget.native_lans}, input lans: ${input_lans}');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SelectLanguage(),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xffF9F9F9F0),
                        //  border: Border.all(),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                  width: 70,
                                  height: 70,
                                  child: widget.profileUrl != null
                                      ? ClipOval(
                                          child: Image.network(
                                          widget.profileUrl,
                                          fit: BoxFit.fill,
                                          width: 40,
                                        ))
                                      : Offstage(),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.name,
                                      style: const TextStyle(
                                        fontFamily: "Inter",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xff000000),
                                        height: 25 / 16,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(
                                      "America",
                                      style: const TextStyle(
                                        fontFamily: "Inter",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff000000),
                                        height: 22 / 14,
                                      ),
                                      textAlign: TextAlign.left,
                                    )
                                  ],
                                ),
                              ),
                              Expanded(child: Text(''))
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Wrap(
                                    direction: Axis.horizontal,
                                    children: [
                                      Text(
                                        "Speaks: ",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff000000),
                                          height: 22 / 14,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      for (var i = 0;
                                          i < (widget.native_lans).length - 1;
                                          i++)
                                        Text(
                                          "${widget.native_lans[i]}, ",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xff000000),
                                            height: 22 / 14,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      Text(
                                        "${widget.native_lans[(widget.native_lans).length - 1]}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff000000),
                                          height: 22 / 14,
                                        ),
                                        textAlign: TextAlign.left,
                                      )
                                    ],
                                  )),
                              Expanded(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Ready",
                                    style: const TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff000000),
                                      height: 22 / 14,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ))
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xffF9F9F9F0),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.chat_bubble),
                              Spacer(
                                flex: 2,
                              ),
                              Text(
                                "Your language ",
                                style: const TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff000000),
                                  height: 17 / 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Spacer(
                                flex: 3,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Text(
                                      selectedValueFrom2 ?? 'Halh Mongolian',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              items: List<String>.from(input_lans)
                                  .map(
                                      (String item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Container(
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )))
                                  .toList(),
                              //   value: selectedValueFrom2,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedValueFrom2 = value;
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.black26,
                                    ),
                                    color: Colors.white),
                                elevation: 2,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white,
                                ),
                                offset: const Offset(0, 0),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(40),
                                  thickness:
                                      MaterialStateProperty.all<double>(6),
                                  thumbVisibility:
                                      MaterialStateProperty.all<bool>(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Text(
                            "will be transated to",
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff000000),
                              height: 17 / 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Text(
                                      selectedValueTo2 ?? widget.native_lans[0],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              items: List<String>.from(widget.native_lans)
                                  .map(
                                      (String item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Container(
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )))
                                  .toList(),
                              //   value: selectedValueTo2,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedValueTo2 = value;
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.black26,
                                    ),
                                    //color: Color(0xffC6E2EE),
                                    color: Colors.white),
                                elevation: 2,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white,
                                ),
                                offset: const Offset(-20, 0),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(40),
                                  thickness:
                                      MaterialStateProperty.all<double>(6),
                                  thumbVisibility:
                                      MaterialStateProperty.all<bool>(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xffF9F9F9F0),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.keyboard_voice),
                              // Image.asset("assets/images/ic_chat_translation.png",
                              //     color: Get.theme.colorScheme.secondary,
                              //     width: 20,
                              //     height: 20),
                              Spacer(
                                flex: 2,
                              ),
                              Text(
                                "Your language ",
                                style: const TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff000000),
                                  height: 17 / 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Spacer(
                                flex: 3,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Text(
                                      selectedValueFrom1 ?? 'Halh Mongolian',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              items: List<String>.from(input_lans)
                                  .map(
                                      (String item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Container(
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )))
                                  .toList(),
                              //  value: selectedValueFrom1,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedValueFrom1 = value;
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.black26,
                                    ),
                                    //color: Color(0xffC6E2EE),
                                    color: Colors.white),
                                elevation: 2,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white,
                                ),
                                offset: const Offset(0, 0),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(40),
                                  thickness:
                                      MaterialStateProperty.all<double>(6),
                                  thumbVisibility:
                                      MaterialStateProperty.all<bool>(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Text(
                            "will be transated to",
                            style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff000000),
                              height: 17 / 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Text(
                                      selectedValueTo1 ?? widget.native_lans[0],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              items: List<String>.from(widget.native_lans)
                                  .map(
                                      (String item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Container(
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )))
                                  .toList(),
                              //value: 'Bengali',
                              onChanged: (String? value) {
                                setState(() {
                                  selectedValueTo1 = value;
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.black26,
                                    ),
                                    //color: Color(0xffC6E2EE),
                                    color: Colors.white),
                                elevation: 2,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: Colors.white,
                                ),
                                offset: const Offset(0, 0),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(40),
                                  thickness:
                                      MaterialStateProperty.all<double>(6),
                                  thumbVisibility:
                                      MaterialStateProperty.all<bool>(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black26))),
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(),
                child: ElevatedButton(
                  onPressed: () {
                    print('key: $key');
                    Data.addUser(
                        key,
                        selectedValueFrom1 ?? 'Halh Mongolian', //voice from
                        selectedValueTo1 ??
                            List<String>.from(widget.native_lans)[0], //voice to
                        selectedValueFrom2 ?? 'Halh Mongolian', // msg from
                        selectedValueTo2 ??
                            List<String>.from(widget.native_lans)[0]); //msg to

                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Color(0xff2675EC),
                  ),
                  child: const Text(
                    'Хадгалах',
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.white,
                        fontSize: 17),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget SelectLanguage() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios)),
      title: Text(
        "МЭДЭЭЛЭЛ",
        style: TextStyle(
            color: Color(0Xff2675EC),
            fontSize: 22.0,
            fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }
}
