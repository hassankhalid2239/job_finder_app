// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Widgets/snackbar.dart';
import '../main_page.dart';

class Otp extends StatelessWidget {
  const Otp({super.key, required this.otpController});
  final TextEditingController otpController;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextFormField(
        cursorColor: const Color(0xff5800FF),
        style: Theme.of(context).textTheme.displayMedium,
        controller: otpController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },
        decoration: InputDecoration(
          hintStyle: Theme.of(context).textTheme.displaySmall,
          hintText: ('_'),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.grey,
          )),
          focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.redAccent,
          )),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Color(0xff5800FF),
          )),
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.redAccent,
          )),
        ),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  final String name;
  final String mail;
  final String phone;
  final String pass;
  final EmailOTP myauth;
  const OtpScreen(
      {super.key,
      required this.myauth,
      required this.name,
      required this.mail,
      required this.pass,
      required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otp1Controller = TextEditingController();
  TextEditingController otp2Controller = TextEditingController();
  TextEditingController otp3Controller = TextEditingController();
  TextEditingController otp4Controller = TextEditingController();
  final Snack snack = Snack();
  bool _isLoading = false;
  String otpController = "1234";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future submitDetail() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _auth
          .createUserWithEmailAndPassword(
              email: widget.mail, password: widget.pass)
          .then((signedInUser) async {
        String uid = FirebaseAuth.instance.currentUser!.uid;
        FirebaseFirestore.instance
            .collection("Users")
            .doc(signedInUser.user?.uid)
            .set({
          "Id": uid,
          "Name": widget.name,
          "Email": widget.mail,
          "Phone Number": widget.phone,
          "User Image": "",
          "Gender": "",
          "About Me": "",
          "Resume Url": "",
          "Resume Name": "",
          "User Type": true,
          "Location": "",
          "Availability": true,
          "Created At": Timestamp.now()
        }).then((signedInUser) async {
          String uid = FirebaseAuth.instance.currentUser!.uid;
          await FirebaseMessaging.instance.getToken().then((token) async {
            await FirebaseFirestore.instance
                .collection('UserTokens')
                .doc(uid)
                .set({'token': token, 'id': uid});
          });
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
              (route) => false);
        });
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = true;
      });
      if (e.message ==
          'The email address is already in use by another account.') {
        ScaffoldMessenger.of(context).showSnackBar(
            snack.errorSnackBar('On Snap!', 'This email is already exit'));
      } else if (e.message ==
          'A network error (such as timeout, interrupted connection or unreachable host) has occurred.') {
        ScaffoldMessenger.of(context).showSnackBar(
            snack.errorSnackBar('On Error!', 'No Internet Connection'));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            snack.errorSnackBar('On Error!', e.message.toString()));
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Future submitDetail() async {
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     String uid = FirebaseAuth.instance.currentUser!.uid;
  //     FirebaseFirestore.instance.collection("Users").doc(uid).set({
  //       "Id": uid,
  //       "Name": widget.name,
  //       "Email": widget.mail,
  //       "Phone Number": widget.phone,
  //       "User Image": "",
  //       "Gender": "",
  //       "About Me": "",
  //       "Resume Url": "",
  //       "Created At": Timestamp.now()
  //     }).then((signedInUser) async {
  //       String uid = FirebaseAuth.instance.currentUser!.uid;
  //       await FirebaseMessaging.instance.getToken().then((token) async {
  //         await FirebaseFirestore.instance
  //             .collection('UserTokens')
  //             .doc(uid)
  //             .set({'token': token, 'id': uid});
  //       });
  //       Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(builder: (context) => const MainPage()),
  //           (route) => false);
  //     });
  //   } on FirebaseAuthException catch (e) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     if (e.message ==
  //         'The email address is already in use by another account.') {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           snack.errorSnackBar('On Snap!', 'This email is already exit'));
  //     } else if (e.message ==
  //         'A network error (such as timeout, interrupted connection or unreachable host) has occurred.') {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           snack.errorSnackBar('On Error!', 'No Internet Connection'));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           snack.errorSnackBar('On Error!', e.message.toString()));
  //     }
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).colorScheme.onSurface,
            statusBarIconBrightness: Theme.of(context).brightness),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verification Code',
                    style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(
                  height: 8,
                ),
                Text(
                    'We send the Verification OTP code to your email account ${widget.mail} input to complete the last stage of registering',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: Wrap(
                    runSpacing: 25,
                    children: [
                      Otp(
                        otpController: otp1Controller,
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      Otp(
                        otpController: otp2Controller,
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      Otp(
                        otpController: otp3Controller,
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      Otp(
                        otpController: otp4Controller,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 53,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff5800FF),
                          foregroundColor: Colors.black,
                          splashFactory: InkRipple.splashFactory,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onPressed: () async {
                        if (await widget.myauth.verifyOTP(
                                otp: otp1Controller.text +
                                    otp2Controller.text +
                                    otp3Controller.text +
                                    otp4Controller.text) ==
                            true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              snack.successSnackBar(
                                  'Congratulations!', 'OTP is verified'));
                          submitDetail();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              snack.errorSnackBar('On Snap!', 'Invalid OTP'));
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Invalid OTP"),
                          ));
                        }
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              'Confirm',
                              style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
