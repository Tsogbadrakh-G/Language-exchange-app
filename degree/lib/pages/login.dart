import 'package:degree/pages/onboard_screen.dart';
import 'package:degree/service/Controller.dart';
import 'package:degree/service/somni_alert.dart';
import 'package:degree/util/firebase.dart';
import 'package:flutter/material.dart';
import '../service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'home.dart';
import 'package:degree/pages/forgotpassword.dart';
import 'package:email_validator/email_validator.dart';

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
  bool _isEmptyMail = false;
  bool _isEmptyPass = false;
  bool isValidMail = false;
  bool isValidPass = false;
  final _formkey = GlobalKey<FormState>();

  Validator() {
    if (usermailcontroller.text.isEmpty) {
      _isEmptyMail = true;
      setState(() {});
    } else
      _isEmptyMail = false;
    if (userpasswordcontroller.text.isEmpty) {
      _isEmptyPass = true;
      setState(() {});
    } else
      _isEmptyPass = false;

    if (_isEmptyMail && _isEmptyPass)
      SomniAlerts.showMyDialog(context, 'Та майл болон нууц үгээ оруулна уу!');
    else if (_isEmptyMail)
      SomniAlerts.showMyDialog(context, 'Та майл-ээ оруулна уу!');
    else if (_isEmptyPass)
      SomniAlerts.showMyDialog(context, 'Та нууц үгээ оруулна уу!');

    print('validation mail: $_isEmptyMail, pass: $_isEmptyPass');
  }

  userLogin() async {
    try {
      print('1');
      // await FirebaseAuth.instance.
      email = email.toLowerCase();
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
      FirebaseUtils.main();
      _dataController.getCallHistories();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        SomniAlerts.showMyDialog(
            context, 'Таны оруулсан бүтгэлтэй хэрэглэгч байхгүй байна!');
      } else if (e.code == 'wrong-password') {
        SomniAlerts.showMyDialog(context, 'Таны оруулсан нууц үг буруу байна!');
      } else if (e.code == 'invalid-email') {
        SomniAlerts.showMyDialog(
            context, 'Таны оруулсан имэйл хаяг буруу байна!');
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        SomniAlerts.showMyDialog(context,
            'Та өөрийн оруулсан нууц үг болон мэйлээ зөв эсэхийг шалгана уу!');
      } else if (e.code == 'network-request-failed') {
        SomniAlerts.showMyDialog(
            context, 'Та интернетэд холбогдсон эсэхээ шалгана уу!');
      }

      print('sign in exception: ${e.toString()}, code: ${e.code}');
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
          //  child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ic_splash.png',
                scale: 1.5,
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
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              //   Validator();
                              isValidMail = EmailValidator.validate(value);
                              print('valid: $isValidMail ');
                            });
                          },
                          focusNode: focusNode1,
                          textAlignVertical: TextAlignVertical.center,
                          controller: usermailcontroller,
                          decoration: InputDecoration(
                            suffixIcon: isValidMail
                                ? Icon(
                                    Icons.check_circle_outline,
                                    color: Color(
                                      0xff48D68A,
                                    ),
                                    size: 23,
                                  )
                                : Image.asset(
                                    'assets/images/img_login_exclamation.png',
                                    scale: 1.9,
                                  ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black38),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 1,
                                color: Color(0xff434347),
                              ),
                            ),
                            hintText: 'Имэйл',
                            hintStyle: TextStyle(
                                color: Color(0xff434347),
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.normal,
                                fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: TextFormField(
                          onChanged: (value) {},
                          focusNode: focusNode2,
                          textAlignVertical: TextAlignVertical.center,
                          controller: userpasswordcontroller,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black38),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 1.5,
                                color: Color(0xff434347),
                              ),
                            ),
                            border: InputBorder.none,
                            hintText: 'Нууц үг',
                            hintStyle: TextStyle(
                                color: Color(0xff434347),
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.normal,
                                fontSize: 14),
                          ),
                          obscureText: true,
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 35),
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: ElevatedButton(
                          onPressed: () {
                            Validator();
                            if (!_isEmptyMail && !_isEmptyPass) {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  email = usermailcontroller.text;
                                  password = userpasswordcontroller.text;
                                  //log('email: $email, pass: $password');
                                });
                              }
                              userLogin();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: Color(0xff0057ff),
                          ),
                          child: const Text(
                            'Нэвтрэх',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.normal,
                                fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 35,
                          ),
                          GestureDetector(
                            onTap: () => Get.to(ForgotPassword()),
                            child: Container(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                    color: Color(0xff434347),
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                              ),
                            ),
                          ),
                        ],
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
          // ),
        ),
      ),
    );
  }
}
