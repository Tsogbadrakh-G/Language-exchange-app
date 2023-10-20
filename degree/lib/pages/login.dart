import 'package:degree/pages/onboard_screen.dart';
import 'package:degree/service/Controller.dart';
import 'package:flutter/material.dart';
import '../service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'home.dart';
import 'dart:developer';
import 'package:degree/pages/forgotpassword.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "", name = "", pic = "", username = "", id = "";
  TextEditingController usermailcontroller = new TextEditingController();
  TextEditingController userpasswordcontroller = new TextEditingController();
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  DataController _dataController = Get.find();

  final _formkey = GlobalKey<FormState>();

  userLogin() async {
    try {
      print('1');
      // await FirebaseAuth.instance.
      email = email.trim().toLowerCase();
      print('email $email, pass: $password');
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      QuerySnapshot querySnapshot =
          await DatabaseMethods().getUserbyemail(email);

      name = "${querySnapshot.docs[0]["Name"]}";

      username = "${querySnapshot.docs[0]["username"]}";
      pic = "${querySnapshot.docs[0]["Photo"]}";
      id = querySnapshot.docs[0].id;

      _dataController.SaveUser(id, name, username, pic,
          "${querySnapshot.docs[0]["SearchKey"]}", email);

      print('object: ${FirebaseAuth.instance.currentUser}');
      print('name $name, usrname: $username, pic: $pic, id: $id');

      Get.to(Home());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No User Found for that Email",
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Wrong Password Provided by User",
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            )));
      }
      log('sign in exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Get.to(OnboardScreen());
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
        },
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          height: double.infinity,
          //  decoration: BoxDecoration(border: Border.all()),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                          child: Text(
                            "Сайн уу 👋",
                            style: const TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 37,
                              fontWeight: FontWeight.w500,
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
                const SizedBox(
                  height: 30,
                ),
                Container(
                  width: double.infinity,
                  child: Form(
                    key: _formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
                          width: double.infinity,
                          child: Text('И-мэйл'),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.black38),
                              // border: Border(
                              //   bottom: BorderSide(color: Colors.black, width: 1),
                              // ),
                              borderRadius: BorderRadius.circular(5)),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            focusNode: focusNode1,
                            textAlignVertical: TextAlignVertical.center,
                            controller: usermailcontroller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter e-mail';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Имэйл-ээ оруулна уу',
                              border: InputBorder.none,
                              // prefixIcon: Icon(
                              //   Icons.alternate_email,
                              //   color: Color(0xFF7f30fe),
                              // ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
                          width: double.infinity,
                          child: Text(
                            'Нууц үг',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.0, color: Colors.black38),
                              borderRadius: BorderRadius.circular(5)),
                          child: TextFormField(
                            focusNode: focusNode2,
                            textAlignVertical: TextAlignVertical.center,
                            controller: userpasswordcontroller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Нууц үгээ оруулна уу.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'нууц үг',
                              // prefixIcon: Icon(
                              //   Icons.password,
                              //   color: Color(0xFF7f30fe),
                              // ),
                            ),
                            obscureText: true,
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => Get.to(ForgotPassword()),
                              child: Container(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 50.0,
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
                                    email = usermailcontroller.text;
                                    password = userpasswordcontroller.text;
                                    //log('email: $email, pass: $password');
                                  });
                                }
                                userLogin();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                backgroundColor: Color(0xff2675EC),
                              ),
                              child: const Text(
                                'Нэвтрэх',
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
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
