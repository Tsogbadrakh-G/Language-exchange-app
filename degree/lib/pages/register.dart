import 'dart:developer';
import 'package:degree/service/Controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home.dart';
import '../service/database.dart';
import 'package:random_string/random_string.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  DataController _dataController = Get.find();
  String email = "", password = "", name = "", confirmPassword = "";

  TextEditingController mailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController confirmPasswordcontroller = new TextEditingController();
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();

  final _formkey = GlobalKey<FormState>();
  var args;

  @override
  void initState() {
    // args = ModalRoute.of(context)!.settings.arguments;
    //
    super.initState();
  }

  registration() async {
    if (password != "" && password == confirmPassword) {
      try {
        email = email.toLowerCase().trim();

        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        String Id = randomAlphaNumeric(10);
        String user = email.replaceAll("@gmail.com", "");
        String updateusername =
            user.replaceFirst(user[0], user[0].toUpperCase());
        String firstletter = user.substring(0, 1).toUpperCase();

        Map<String, dynamic> userInfoMap = {
          "Name": namecontroller.text,
          "E-mail": email.toLowerCase(),
          "username": updateusername.toUpperCase(),
          "SearchKey": firstletter,
          "Photo":
              "https://firebasestorage.googleapis.com/v0/b/barberapp-ebcc1.appspot.com/o/icon1.png?alt=media&token=0fad24a5-a01b-4d67-b4a0-676fbc75b34a",
          "Id": Id,
          "native_lans": _dataController.native_lans
        };

        await DatabaseMethods().addUserDetails(userInfoMap, Id);

        _dataController.SaveUser(
            Id,
            namecontroller.text,
            updateusername.toUpperCase(),
            userInfoMap["Photo"],
            firstletter,
            email);
        // await SharedPreferenceHelper().saveUserId(Id);
        // await SharedPreferenceHelper().saveUserDisplayName(namecontroller.text);
        // await SharedPreferenceHelper().saveUserEmail(mailcontroller.text);
        // await SharedPreferenceHelper().saveUserPic(
        //     "https://firebasestorage.googleapis.com/v0/b/barberapp-ebcc1.appspot.com/o/icon1.png?alt=media&token=0fad24a5-a01b-4d67-b4a0-676fbc75b34a");
        // await SharedPreferenceHelper().saveUserName(
        //     mailcontroller.text.replaceAll("@gmail.com", "").toUpperCase());

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Registered Successfully",
          style: TextStyle(fontSize: 20.0),
        )));

        Get.to(Home());
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too Weak",
                style: TextStyle(fontSize: 18.0),
              )));
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 18.0),
              )));
        }
        log('sign up exception: $e');
      }
    }
    log('diiferent pass');
  }

  @override
  Widget build(BuildContext context) {
    // args = ModalRoute.of(context)!.settings.arguments;
    print('args ${_dataController.native_lans}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              _dataController.native_lans = [];
              Get.back();
            },
            icon: Icon(Icons.arrow_back)),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          if (focusNode1.hasFocus) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
          if (focusNode2.hasFocus) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
          if (focusNode3.hasFocus) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
          if (focusNode4.hasFocus) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
        },
        child: Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                          child: Text(
                            "Бүртгүүлэх ✌️",
                            style: const TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff000000),
                              height: 37 / 37,
                            ),
                            textAlign: TextAlign.left,
                          )),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  child: Form(
                    key: _formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Container(

                        //   padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
                        //   width: double.infinity,
                        //   child: Text(
                        //     'Нэр',
                        //     style: TextStyle(fontWeight: FontWeight.w600),
                        //   ),
                        // ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            focusNode: focusNode1,
                            textAlignVertical: TextAlignVertical.center,
                            controller: namecontroller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                //<-- SEE HERE
                                borderSide:
                                    BorderSide(width: 2, color: Colors.black38),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                //<-- SEE HERE
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xff2675EC),
                                ),
                              ),
                              hintText: "Нэр",
                              border: InputBorder.none,
                              // prefixIcon: Icon(
                              //   Icons.person_outline,
                              //   color: Color(0xFF7f30fe),
                              // ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        // Container(
                        //
                        //   padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
                        //   width: double.infinity,
                        //   child: Text(
                        //     'Имэйл',
                        //     style: TextStyle(fontWeight: FontWeight.w600),
                        //   ),
                        // ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          // decoration: BoxDecoration(
                          //     border: Border.all(
                          //         width: 1.0, color: Color(0xff8E8383)),
                          //     borderRadius: BorderRadius.circular(5)),
                          child: TextFormField(
                            focusNode: focusNode2,
                            textAlignVertical: TextAlignVertical.center,
                            controller: mailcontroller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter E-mail';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                //<-- SEE HERE
                                borderSide:
                                    BorderSide(width: 2, color: Colors.black38),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                //<-- SEE HERE
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xff2675EC),
                                ),
                              ),
                              hintText: "Имэйл",
                              border: InputBorder.none,
                              // prefixIcon: Icon(
                              //   Icons.mail_outline,
                              //   color: Color(0xFF7f30fe),
                              // ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        // Container(

                        //   padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
                        //   width: double.infinity,
                        //   child: Text(
                        //     'Нууц үг',
                        //     style: TextStyle(fontWeight: FontWeight.w600),
                        //   ),
                        // ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          // decoration: BoxDecoration(
                          //     border: Border.all(
                          //         width: 1.0, color: Color(0xff8E8383)),
                          //     borderRadius: BorderRadius.circular(5)),
                          child: TextFormField(
                            focusNode: focusNode3,
                            textAlignVertical: TextAlignVertical.center,
                            controller: passwordcontroller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                //<-- SEE HERE
                                borderSide:
                                    BorderSide(width: 2, color: Colors.black38),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                //<-- SEE HERE
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xff2675EC),
                                ),
                              ),
                              hintText: "Нууц үг",
                              border: InputBorder.none,
                              // prefixIcon: Icon(
                              //   Icons.password,
                              //   color: Color(0xFF7f30fe),
                              // )
                            ),
                            obscureText: true,
                          ),
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        // Container(

                        //   padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
                        //   width: double.infinity,
                        //   child: Text(
                        //     'Нууц үг баталгаажуулах',
                        //     style: TextStyle(fontWeight: FontWeight.w600),
                        //   ),
                        // ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          // decoration: BoxDecoration(
                          //     border: Border.all(
                          //         width: 1.0, color: Color(0xff8E8383)),
                          //     borderRadius: BorderRadius.circular(5)),
                          child: TextFormField(
                            focusNode: focusNode4,
                            textAlignVertical: TextAlignVertical.center,
                            controller: confirmPasswordcontroller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Confirm Password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                //<-- SEE HERE
                                borderSide:
                                    BorderSide(width: 2, color: Colors.black38),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                //<-- SEE HERE
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xff2675EC),
                                ),
                              ),
                              hintText: "Нууц үг баталгаажуулах",
                              border: InputBorder.none,
                              // prefixIcon: Icon(
                              //   Icons.password,
                              //   color: Color(0xFF7f30fe),
                              // ),
                            ),
                            obscureText: true,
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Divider(),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
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
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            email = mailcontroller.text;
                            name = namecontroller.text;
                            password = passwordcontroller.text;
                            confirmPassword = confirmPasswordcontroller.text;
                          });
                        }

                        registration();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Color(0xff2675EC),
                      ),
                      child: const Text(
                        'Бүртгүүлэх',
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
        ),
      ),
    );
  }
}
