import 'package:degree/service/Controllers/listenController.dart';
import 'package:degree/service/data_api.dart';
import 'package:degree/service/Controllers/dataController.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

List<String> voiceInLans = [
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

final List<String> inputLans = [
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

class ChatMoreScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
  final usrId, name, profileUrl, native_lans, channel;
  const ChatMoreScreen(
      this.usrId, this.name, this.profileUrl, this.native_lans, this.channel,
      {Key? key})
      : super(key: key);

  @override
  State<ChatMoreScreen> createState() => _ChatMoreScreen();
}

class _ChatMoreScreen extends State<ChatMoreScreen> {
  final DataController _dataController = Get.find();
  final ListenerController _listenerController = Get.find();
  String? selectedValueFrom1;
  String? selectedValueTo1;
  String? selectedValueFrom2;
  String? selectedValueTo2;
  String key = '';
  @override
  void initState() {
    key = widget.channel + _dataController.myUserName;
    // print('init key: $key');
    if (usersBox.get(key) != null) {
      // print('users box is not null');
      selectedValueFrom1 = usersBox.get(key)!.transFromVoice;
      selectedValueTo1 = usersBox.get(key)!.transToVoice;
      selectedValueFrom2 = usersBox.get(key)!.transFromMsg;
      selectedValueTo2 = usersBox.get(key)!.transToMsg;
      // print(
      //     'selected vals: from1: $selectedValueFrom1 to1:$selectedValueTo1 from2: $selectedValueFrom2 to2: $selectedValueTo2');
    }
    // else
    //   print('users box is null');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(
    //     'name: ${widget.name}, profile url:  ${widget.profileUrl}, native lans: ${widget.native_lans}, input lans: ${input_lans}');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: selectLanguage(),
      body: SizedBox(
        //padding: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xffF9F9F9),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30)),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ),
                                width: 65,
                                height: 65,
                                child: widget.profileUrl != null
                                    ? ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(30)),
                                        child: Image.network(
                                          widget.profileUrl,
                                          fit: BoxFit.fill,
                                        ))
                                    : const Offstage(),
                              ),
                              const SizedBox(
                                width: 15,
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
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      widget.native_lans[0],
                                      style: const TextStyle(
                                        fontFamily: "Nunito",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff000000),
                                        height: 15 / 14,
                                      ),
                                      textAlign: TextAlign.left,
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  child: Image.asset(
                                    'assets/images/flags/Halh Mongolian.png',
                                    width: 45,
                                    height: 40,
                                  )),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Wrap(
                                    direction: Axis.horizontal,
                                    children: [
                                      const Text(
                                        "Speaks: ",
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
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
                                            fontFamily: 'Nunito',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff000000),
                                            height: 17 / 14,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      Text(
                                        "${widget.native_lans[(widget.native_lans).length - 1]}",
                                        style: const TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff000000),
                                          height: 17 / 14,
                                        ),
                                        textAlign: TextAlign.left,
                                      )
                                    ],
                                  )),
                              const SizedBox(
                                width: 20,
                              ),
                              Obx(() {
                                print('more sc');
                                //if (
                                return !_listenerController.channelUsrIsActive
                                        .containsKey(widget.channel)
                                    ?
                                    //) {
                                    const Text('Undefined')
                                    : _listenerController
                                            .channelUsrIsActive[widget.channel]!
                                        ?
                                        // } else {
                                        //   return

                                        //     ?
                                        Expanded(
                                            child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Image.asset(
                                                'assets/images/img_online.png',
                                                scale: 1.7,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              const Text(
                                                "Ready",
                                                style: TextStyle(
                                                  fontFamily: "Inter",
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xff000000),
                                                  height: 22 / 14,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          ))
                                        : Expanded(
                                            flex: 2,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Image.asset(
                                                  'assets/images/img_online.png',
                                                  scale: 1.7,
                                                  color: Colors.red,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                const Text(
                                                  "Unavailable",
                                                  style: TextStyle(
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
                                            ));
                              })
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xfff9f9f9f0),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.chat_bubble),
                              Spacer(
                                flex: 2,
                              ),
                              Text(
                                "Your language ",
                                style: TextStyle(
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
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Text(
                                      selectedValueFrom2 ?? 'Halh Mongolian',
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
                              items: List<String>.from(inputLans)
                                  .map(
                                      (String item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
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
                          const Text(
                            "will be transated to",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff000000),
                              height: 17 / 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Text(
                                      selectedValueTo2 ?? widget.native_lans[0],
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
                              items: List<String>.from(widget.native_lans)
                                  .map(
                                      (String item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
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
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xfff9f9f9f0),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Row(
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
                                style: TextStyle(
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
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Text(
                                      selectedValueFrom1 ?? 'Halh Mongolian',
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
                              items: List<String>.from(inputLans)
                                  .map(
                                      (String item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
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
                          const Text(
                            "will be transated to",
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff000000),
                              height: 17 / 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Text(
                                      selectedValueTo1 ?? widget.native_lans[0],
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
                              items: List<String>.from(widget.native_lans)
                                  .map(
                                      (String item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
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
                  ],
                ),
              ),
            ),

            // Container(
            //   decoration: BoxDecoration(
            //       border: Border(top: BorderSide(color: Colors.black26))),
            //   width: double.infinity,
            //   padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            //   child: Container(
            //     margin: EdgeInsets.symmetric(horizontal: 30),
            //     decoration: BoxDecoration(),
            //     child: ElevatedButton(
            //       onPressed: () {},
            //       style: ElevatedButton.styleFrom(
            //         shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(30)),
            //         padding: EdgeInsets.symmetric(vertical: 15),
            //         backgroundColor: Color(0xff2675EC),
            //       ),
            //       child: const Text(
            //         'Хадгалах',
            //         style: TextStyle(
            //             decoration: TextDecoration.none,
            //             color: Colors.white,
            //             fontSize: 17),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget selectLanguage() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
          onPressed: () {
            //print('key: $key');
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
          icon: const Icon(Icons.arrow_back_ios)),
      title: const Text(
        "МЭДЭЭЛЭЛ",
        style: TextStyle(
            fontFamily: 'Nunito',
            color: Color(0Xff2675EC),
            fontSize: 17.0,
            fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
    );
  }
}
