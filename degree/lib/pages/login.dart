import 'package:degree/pages/register.dart';
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
  DataController _dataController = Get.find();

  final _formkey = GlobalKey<FormState>();

  userLogin() async {
    try {
      print('1');
      // await FirebaseAuth.instance.
      email = email.trim().toLowerCase();
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
      //    appBar: PreferredSizeWidget()
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: Text(
                          "Lets Sign you in",
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
                        "Welcome Back ,You have been missed",
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
              const SizedBox(
                height: 50,
              ),
              Container(
                width: double.infinity,
                child: Form(
                  key: _formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.0, color: Color(0xff8E8383)),
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          controller: usermailcontroller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter e-mail';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Please enter e-mail',
                            border: InputBorder.none,
                            // prefixIcon: Icon(
                            //   Icons.alternate_email,
                            //   color: Color(0xFF7f30fe),
                            // ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            border:
                                Border.all(width: 1.0, color: Colors.black38),
                            borderRadius: BorderRadius.circular(5)),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          controller: userpasswordcontroller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
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
                        height: 20.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              email = usermailcontroller.text;
                              password = userpasswordcontroller.text;
                              //log('email: $email, pass: $password');
                            });
                          }
                          userLogin();
                        },
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            child: Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 15),
                                decoration: BoxDecoration(
                                    color: Color(0xFF000000),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Center(
                                    child: Text(
                                  "Sign in",
                                  style: const TextStyle(
                                    fontFamily: "Outfit",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    height: 23 / 18,
                                  ),
                                  textAlign: TextAlign.left,
                                )),
                              ),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 2 * MediaQuery.of(context).size.width / 5,
                    height: 1,
                    color: Color(0xff585858),
                  ),
                  Text(
                    "or ",
                    style: const TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff000000),
                      height: 23 / 18,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Container(
                    width: 2 * MediaQuery.of(context).size.width / 5,
                    height: 1,
                    color: Color(0xff585858),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/ic_google.png",
                      width: 35, height: 35),
                  SizedBox(
                    width: 30,
                  ),
                  Image.asset("assets/images/ic_facebook.png",
                      width: 35, height: 35),
                  SizedBox(
                    width: 30,
                  ),
                  Image.asset("assets/images/ic_apple.png",
                      width: 40, height: 40),
                ],
              ),
              SizedBox(
                height: 35,
              ),
              Container(
                  child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    "Don’t have an account ?",
                    style: const TextStyle(
                      fontSize: 16,
                      height: 34 / 16,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(Register());
                    },
                    child: Text(
                      " Register Now ",
                      style: const TextStyle(
                          fontSize: 16,
                          height: 34 / 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black),
                      textAlign: TextAlign.left,
                    ),
                  )
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
