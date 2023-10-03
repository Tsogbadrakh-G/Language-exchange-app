import 'dart:developer';

import 'package:degree/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home.dart';
import '../service/database.dart';
import '../service/shared_pref.dart';
import 'package:random_string/random_string.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  String email = "", password = "", name = "", confirmPassword = "";

  TextEditingController mailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController confirmPasswordcontroller = new TextEditingController();

  final _formkey = GlobalKey<FormState>();

  registration() async {
    if (password != null && password == confirmPassword) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.toLowerCase(), password: password);

        String Id = randomAlphaNumeric(10);
        String user = mailcontroller.text.replaceAll("@gmail.com", "");
        String updateusername =
            user.replaceFirst(user[0], user[0].toUpperCase());
        String firstletter = user.substring(0, 1).toUpperCase();

        Map<String, dynamic> userInfoMap = {
          "Name": namecontroller.text,
          "E-mail": mailcontroller.text.toLowerCase(),
          "username": updateusername.toUpperCase(),
          "SearchKey": firstletter,
          "Photo":
              "https://firebasestorage.googleapis.com/v0/b/barberapp-ebcc1.appspot.com/o/icon1.png?alt=media&token=0fad24a5-a01b-4d67-b4a0-676fbc75b34a",
          "Id": Id,
        };
        await DatabaseMethods().addUserDetails(userInfoMap, Id);
        await SharedPreferenceHelper().saveUserId(Id);
        await SharedPreferenceHelper().saveUserDisplayName(namecontroller.text);
        await SharedPreferenceHelper().saveUserEmail(mailcontroller.text);
        await SharedPreferenceHelper().saveUserPic(
            "https://firebasestorage.googleapis.com/v0/b/barberapp-ebcc1.appspot.com/o/icon1.png?alt=media&token=0fad24a5-a01b-4d67-b4a0-676fbc75b34a");
        await SharedPreferenceHelper().saveUserName(
            mailcontroller.text.replaceAll("@gmail.com", "").toUpperCase());

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
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                      height: 50,
                    ),
                    Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: Text(
                          "Lets Register Account",
                          style: const TextStyle(
                            fontFamily: "Outfit",
                            fontSize: 37,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff000000),
                            height: 37 / 37,
                          ),
                          textAlign: TextAlign.left,
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(0, 0, 50, 0),
                      child: Text(
                        "Hello user, you have a greatful journey",
                        style: const TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff000000),
                          height: 47 / 37,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    )
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.0, color: Color(0xff8E8383)),
                            borderRadius: BorderRadius.circular(5)),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          controller: namecontroller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Name",
                            border: InputBorder.none,
                            // prefixIcon: Icon(
                            //   Icons.person_outline,
                            //   color: Color(0xFF7f30fe),
                            // ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.0, color: Color(0xff8E8383)),
                            borderRadius: BorderRadius.circular(5)),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          controller: mailcontroller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter E-mail';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Email",
                            border: InputBorder.none,
                            // prefixIcon: Icon(
                            //   Icons.mail_outline,
                            //   color: Color(0xFF7f30fe),
                            // ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.0, color: Color(0xff8E8383)),
                            borderRadius: BorderRadius.circular(5)),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          controller: passwordcontroller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Password",
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
                        height: 15.0,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.0, color: Color(0xff8E8383)),
                            borderRadius: BorderRadius.circular(5)),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          controller: confirmPasswordcontroller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Confirm Password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Confirm password",
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
              GestureDetector(
                onTap: () {
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
                child: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.0),
                    width: MediaQuery.of(context).size.width,
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Color(0xFF000000),
                            borderRadius: BorderRadius.circular(5)),
                        child: Center(
                            child: Text(
                          "SIGN UP",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(LogIn()),
                    child: Text(
                      " Login",
                      style: TextStyle(
                          color: Color(0xFf000000),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
