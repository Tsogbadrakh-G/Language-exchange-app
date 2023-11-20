import 'package:degree/service/Controllers/dataController.dart';
import 'package:degree/service/somni_alert.dart';
import 'package:degree/util/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home.dart';
import '../../service/database.dart';
import 'package:random_string/random_string.dart';
import 'package:email_validator/email_validator.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  final DataController _dataController = Get.find();
  String email = "", password = "", name = "", confirmPassword = "";

  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController confirmPasswordcontroller = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();

  bool _isValidMail = true;
  bool _isEmptyName = false;
  bool _isEmptyPass = false;
  bool _isEmptyPassConfirm = false;

  final _formkey = GlobalKey<FormState>();
  var args;

  @override
  void initState() {
    // args = ModalRoute.of(context)!.settings.arguments;
    //
    super.initState();
  }

  void validation() {
    _isValidMail = EmailValidator.validate(mailcontroller.text);
    if (namecontroller.text.isEmpty) {
      _isEmptyName = true;
    } else {
      _isEmptyName = false;
    }
    if (passwordcontroller.text.isEmpty) {
      _isEmptyPass = true;
    } else {
      _isEmptyPass = false;
    }
    if (confirmPasswordcontroller.text.isEmpty) {
      _isEmptyPassConfirm = true;
    } else {
      _isEmptyPassConfirm = false;
    }

    //print(
    //  'validation name $_isEmptyName, pass: $_isEmptyPass, cpass: $_isEmptyPassConfirm, mail: $_isValidMail');
  }

  registration() async {
    if (password == confirmPassword) {
      // print('register');
      try {
        email = email.toLowerCase().trim();

        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        String id = randomAlphaNumeric(10);
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
              "https://firebasestorage.googleapis.com/v0/b/language-exchange-app-cf264.appspot.com/o/images%2Fimg_profile.png?alt=media&token=82d48d53-f2d7-4c3c-8daa-930ce1253b72&_gl=1*1c3e9ai*_ga*MTAwMzU1OTkzMi4xNjc4OTc2OTE3*_ga_CW55HF8NVT*MTY5ODQ1ODE1OS41MC4xLjE2OTg0NjM0MTEuMjAuMC4w",
          "Id": id,
          "native_lans": _dataController.nativeLans,
          'myNativeLanguage': _dataController.myNativeLan
        };

        await DatabaseMethods().addUserDetails(userInfoMap, id);

        _dataController.saveUser(
            id,
            namecontroller.text,
            updateusername.toUpperCase(),
            userInfoMap["Photo"],
            firstletter,
            email,
            _dataController.myNativeLan);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          "Registered Successfully",
          style: TextStyle(fontSize: 15.0),
        )));

        Get.to(const Home());
        FirebaseUtils.main();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too Weak",
                style: TextStyle(fontSize: 18.0),
              )));
        } else if (e.code == 'email-already-in-use') {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 18.0),
              )));
        }
        // print('sign up exception: ${e.code}');
      }
    } else {
      SomniAlerts.showMyDialog(context,
          'Make sure the password you entered and the password you confirmed are the same !');
    }
  }

  @override
  Widget build(BuildContext context) {
    // args = ModalRoute.of(context)!.settings.arguments;
    // print('args ${_dataController.native_lans}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              _dataController.nativeLans = [];
              _dataController.myNativeLan = '';
              Get.back();
            },
            icon: const Icon(Icons.arrow_back)),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container(
                //   width: double.infinity,
                //   child: Column(
                //     children: [
                //       SizedBox(
                //         height: 10,
                //       ),
                //       Container(
                //           margin: EdgeInsets.symmetric(horizontal: 20),
                //           width: double.infinity,
                //           padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                //           child: Text(
                //             "Бүртгүүлэх ✌️",
                //             style: const TextStyle(
                //               fontFamily: "Outfit",
                //               fontSize: 27,
                //               fontWeight: FontWeight.w600,
                //               color: Color(0xff000000),
                //               height: 37 / 37,
                //             ),
                //             textAlign: TextAlign.left,
                //           )),
                //       SizedBox(
                //         height: 20,
                //       ),
                //     ],
                //   ),
                // ),
                Image.asset(
                  'assets/images/ic_splash.png',
                  scale: 1.5,
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  child: Form(
                    key: _formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            focusNode: focusNode1,
                            textAlignVertical: TextAlignVertical.center,
                            controller: namecontroller,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1,
                                    color: const Color(0xff434347)
                                        .withOpacity(0.5)),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                              hintText: "Name",
                              hintStyle: const TextStyle(
                                  color: Color(0xff434347),
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_isEmptyName)
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                            width: double.infinity,
                            child: const Text(
                              'Enter your name',
                              style: TextStyle(color: Colors.red, fontSize: 10),
                            ),
                          ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            focusNode: focusNode2,
                            textAlignVertical: TextAlignVertical.center,
                            controller: mailcontroller,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1,
                                    color: const Color(0xff434347)
                                        .withOpacity(0.5)),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                              hintText: "Email",
                              hintStyle: const TextStyle(
                                  color: Color(0xff434347),
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (!_isValidMail)
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                            width: double.infinity,
                            child: const Text(
                              'Enter your email',
                              style: TextStyle(color: Colors.red, fontSize: 10),
                            ),
                          ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            focusNode: focusNode3,
                            textAlignVertical: TextAlignVertical.center,
                            controller: passwordcontroller,
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'Please Enter Password';
                            //   }
                            //   return null;
                            // },
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1,
                                    color: const Color(0xff434347)
                                        .withOpacity(0.5)),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                              hintText: "Password",
                              hintStyle: const TextStyle(
                                  color: Color(0xff434347),
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14),
                              border: InputBorder.none,
                            ),
                            obscureText: true,
                          ),
                        ),
                        if (_isEmptyPass)
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                            width: double.infinity,
                            child: const Text(
                              'Enter your password',
                              style: TextStyle(color: Colors.red, fontSize: 10),
                            ),
                          ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextFormField(
                            focusNode: focusNode4,
                            textAlignVertical: TextAlignVertical.center,
                            controller: confirmPasswordcontroller,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1,
                                    color: const Color(0xff434347)
                                        .withOpacity(0.5)),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                              hintText: "Confirm password",
                              hintStyle: const TextStyle(
                                  color: Color(0xff434347),
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14),
                              border: InputBorder.none,
                            ),
                            obscureText: true,
                          ),
                        ),
                        if (_isEmptyPassConfirm)
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                            width: double.infinity,
                            child: const Text(
                              'Enter your confirmation password',
                              style: TextStyle(color: Colors.red, fontSize: 10),
                            ),
                          ),
                        const SizedBox(
                          height: 30.0,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                  child: Container(
                    decoration: const BoxDecoration(),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          validation();
                        });

                        if (!_isEmptyName &&
                            !_isEmptyPass &&
                            !_isEmptyPassConfirm &&
                            _isValidMail) {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              email = mailcontroller.text;
                              name = namecontroller.text;
                              password = passwordcontroller.text;
                              confirmPassword = confirmPasswordcontroller.text;
                            });
                          }
                          // print('object');
                          registration();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: const Color(0xff0057ff),
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.normal,
                            fontSize: 14),
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
