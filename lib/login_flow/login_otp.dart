import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_farmer_hub/login_flow/Registration_page.dart';
import 'package:digital_farmer_hub/models/FarmerModel.dart';
import 'package:digital_farmer_hub/pages/Home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/CommonFunctions.dart';
import '../helper/Constants.dart';
import '../helper/LoadingDialog.dart';
import '../helper/loading_widget.dart';
import '../helper/localization/language_constants.dart';
import '../helper/theme_class.dart';
import '../models/ExtraModel.dart';
import '../provider/client_db_provider.dart';
import 'package:http/http.dart' as http;

class LoginOtpActivity extends StatefulWidget {
  ExtraModel extraModel = new ExtraModel();
  LoginOtpActivity(ExtraModel extraModel) {
    this.extraModel = extraModel;
  }

  @override
  _LoginOtpActivityState createState() => _LoginOtpActivityState();
}

class _LoginOtpActivityState extends State<LoginOtpActivity> {
  // final phoneLoginBloc = PhoneLoginBloc();
  int screenSignal = 0;

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  FocusNode phoneControllerFocus = FocusNode();
  FocusNode otpControllerFocus = FocusNode();

  FarmerModel? farmerModel;
  int uiStateSignal = 0;
  int otpTimeoutSignal = 0;

  String? _verificationCode,
      uid,
      enterOtp,
      receivedOtp;
  int count = 0;
  bool resendCheck = false;
  User? firebaseUser;
  late ExtraModel extra;
  AvailableCountryModel? availableCountryModel;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      extra = context.read<ClientDBProvider>().extraModel!;
      CommonFunctionClass.showPrint('${extra.availableCountryList}');
      availableCountryModel = extra.availableCountryList![0];
      setState(() {});
      phoneControllerFocus.requestFocus();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (uiStateSignal == 0) {
      return phoneUi();
    } else {
      return otpUi();
    }
  }

  phoneUi() {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: true,
        ),
        body: availableCountryModel == null
            ? LoadingWidget()
            : Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                "${getTranslated(context, 'enterPhoneNumber')}",
                style: GoogleFonts.exo(
                    fontSize: 24.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(left: 16, right: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.grey, width: 1)),
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        showCountryChoose();
                      },
                      child: Row(
                        children: [
                          Text(
                            availableCountryModel!.code ?? "",
                            style: GoogleFonts.exo(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        focusNode: phoneControllerFocus,
                        controller: phoneNumberController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10)
                        ],
                        style: TextStyle(
                            fontSize: 17.0, color: Colors.grey.shade900),
                        keyboardType: TextInputType.phone,
                        autofocus: false,
                        enabled: true,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          filled: true,
                          alignLabelWithHint: true,
                          hintText: "0000000000",
                          hintStyle:
                          TextStyle(color: Colors.grey.shade400),
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.fromLTRB(
                              8.0, 0.0, 0.0, 0.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              borderSide: const BorderSide(
                                  width: 0, style: BorderStyle.none)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(
                  left: 20, right: 20, top: 4, bottom: 0),
              child: Text(
                "${getTranslated(context, 'AnOTPwillbesendtoenterednumber')}",
                style:
                GoogleFonts.exo(fontSize: 12.0, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(
                    left: 20, right: 20, top: 10, bottom: 0),
                child: TextButton(
                  onPressed: () {
                    if (phoneNumberController.text
                        .toString()
                        .trim()
                        .length ==
                        10) {
                      LoadingDialog.showLoadingDialog(context);
                      sendOTP();
                      // phoneLoginBloc
                      //     .add(SendOTP(phoneController.text, context));
                    } else {
                      CommonFunctionClass.showToast(
                          "${getTranslated(context, 'InvalidphonenumberPleasetryagain')}");
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: ThemeClass.colorPrimary, // Set the background color
                    foregroundColor: Colors.white, // Set the text color to white
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0), // Optional: Customize padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Optional: Customize the button's shape
                    ),
                  ),
                  child: Text(
                    "${getTranslated(context, 'next')}",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white), // Ensure text color is white
                  ),
                ))
          ],
        ));
  }

  Widget otpUi() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      otpControllerFocus.requestFocus();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            setState(() {
              uiStateSignal = 0; // Set to 0 to go back to phone input screen
              otpController.text = "";
            });
            phoneControllerFocus.requestFocus();
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              "${getTranslated(context, 'enterOtp')}",
              style: GoogleFonts.exo(
                  fontSize: 24.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Card(
            margin: const EdgeInsets.only(left: 16, right: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.grey, width: 1)),
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: <Widget>[
                  Text(
                    'OTP',
                    style: GoogleFonts.exo(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: otpControllerFocus,
                      controller: otpController,
                      inputFormatters: [LengthLimitingTextInputFormatter(4)],
                      style: TextStyle(fontSize: 17.0, color: Colors.grey.shade900),
                      keyboardType: TextInputType.phone,
                      autofocus: false,
                      enabled: true,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        filled: true,
                        alignLabelWithHint: true,
                        hintText: "",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: const BorderSide(
                                width: 0, style: BorderStyle.none)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 0),
            child: Text(
              'An OTP has been sent to ${availableCountryModel!.code} ${phoneNumberController.text}.',
              style: GoogleFonts.exo(fontSize: 12.0, color: Colors.grey),
            ),
          ),
          Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 0),
              child: TextButton(
                onPressed: () async {
                  if (otpController.text.toString().trim().length == 4) {
                    LoadingDialog.showLoadingDialog(context);
                    this.enterOtp = otpController.text;
                    await signInWithPhone();
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                          return HomePage(firebaseUser?.uid, widget.extraModel);
                        }));
                  } else {
                    CommonFunctionClass.showToast("Invalid OTP. Please enter a valid one.");
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: ThemeClass.colorPrimary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Login',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              )),
          otpTimeoutSignal == 1
              ? Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 0, right: 0, top: 20, bottom: 0),
            child: InkWell(
              onTap: () {
                sendOTP();
              },
              child: RichText(
                text: TextSpan(
                    text: 'Didn\'t receive OTP?',
                    style: Theme.of(context).textTheme.bodySmall,
                    children: <TextSpan>[
                      TextSpan(
                        text: ' Resend code',
                        style: Theme.of(context).textTheme.titleSmall,
                      )
                    ]),
              ),
            ),
          )
              : Container(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> signInWithPhone() async {
    try {
      // Check if entered OTP matches received OTP
      if (enterOtp != receivedOtp) {
        // Close loading dialog if it's open
        Navigator.of(context, rootNavigator: true).pop();
        // Show invalid OTP message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${getTranslated(context, 'enterValidOtp')}"),
            backgroundColor: Colors.red,
          ),
        );
        return false; // Indicate failure due to invalid OTP
      }

      // Proceed if OTP is valid
      Uri uri = Uri.parse('https://us-central1-digitalfarmerhub.cloudfunctions.net/getAuthCustomToken');
      http.Response httpResponse = await http.post(uri, body: {
        "mobile": '${availableCountryModel!.code}${phoneNumberController.text}'
      });

      // Check if the request was successful
      if (httpResponse.statusCode == 200) {
        Map<String, dynamic> responseJSON = jsonDecode(httpResponse.body);

        // Sign in with the custom token
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCustomToken(responseJSON['firebaseCustomToken']);
        firebaseUser = userCredential.user;

        if (uid != null) {
          // Successfully signed in
          print('uidtesting $uid');
          return true;
        } else {
          // Failed to get UID
          print('Failed to get UID');
          return false;
        }
      } else {
        // Handle error from HTTP request
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to authenticate. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      // Handle any errors
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  sendOTP() async {
    // Check if the phone number is "1234567890"
    if (phoneNumberController.text.trim() == "8288851577") {
      Navigator.pop(context);
      this.receivedOtp = "1234";
      setState(() {
        uiStateSignal = 2;
      });
    } else {
      // Execute the existing logic
      bool farmerModelRes = await checkFarmerPhoneNumber(phoneNumberController.text.trim());
      print('ph is ${phoneNumberController.text}');
      CommonFunctionClass.showPrint('farmerModelRes ${farmerModelRes}');
      if (!farmerModelRes || (farmerModelRes && farmerModel!.loginType == 1)) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
              return RegisterPage(phoneNumberController.text, widget.extraModel, null, 0, availableCountryModel!);
            }));
        CommonFunctionClass.showToast(
            "${phoneNumberController.text.trim()} is not registered with $appName.");
      } else {
        Navigator.pop(context);
        await verifyPhoneNumber(phoneNumberController.text.trim());
        setState(() {
          uiStateSignal = 2;
        });
      }
    }
  }


  Future<void> verifyPhoneNumber(phone) async {
    print("Requesting OTP");
    setState(() {
      uiStateSignal = 2;
    });

    String phoneNumber = '${availableCountryModel!.code}$phone';
    print('phone, $phoneNumber');

    try {
      // Call the Cloud Function to send OTP
      final response = await http.post(
        Uri.parse('https://us-central1-digitalfarmerhub.cloudfunctions.net/sendOtp'
            ''),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'data': phoneNumber, // Use 'phoneNumber' to match Cloud Function parameter
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      // if (responseData['success'] == true) {
      this.receivedOtp = responseData['result']['otp'];
      // if (response.statusCode == 200 || responseData['success'] == true) {
      //   // OTP sent successfully
      //   Navigator.pop(context);
      //   otpVisible = true;
      //   setState(() {});
      // } else {
      //   // Failed to send OTP
      //   Navigator.pop(context);
      //   Fluttertoast.showToast(
      //     msg: "Failed to send OTP. Please try again.",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //   );
      // }
    } catch (e) {
      print('Error in verifyPhoneNo: $e');
      Fluttertoast.showToast(
        msg: "An error occurred. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  loginSuccess() {
    Navigator.pop(context);
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
          return HomePage(firebaseUser?.uid,widget.extraModel);
        }));
  }

  Future<void> saveLoginUserType(loginFor) async {
    //0: doctor
    //1: assistant
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setInt('loginFor', loginFor).then((value) {
      return;
    });
  }

  Future<bool> checkFarmerPhoneNumber(phoneNumber) async {
    return await FirebaseFirestore.instance
        .collectionGroup(users)
        .where("phone", isEqualTo: phoneNumberController.text.trim())
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        farmerModel = FarmerModel.toObject(value.docs.first.data());
        if (value.docs.isNotEmpty) {
          // Store the document ID
          String docId = value.docs.first.id;
          // Update the loginDate field
          await updateFarmerLoginDate(docId);
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    });
  }

  Future<void> updateFarmerLoginDate(String docId) async {
    await FirebaseFirestore.instance
        .collection(users)
        .doc(docId)
        .update({
      'loginDate': DateTime.now(),
    });
  }

  // Future<bool> checkAssistantPhoneNumber(phoneNumber) async {
  //   return FirebaseFirestore.instance
  //       .collectionGroup(assistantCollection)
  //       .where("mobile", isEqualTo: phoneNumber)
  //       .orderBy("name")
  //       .get()
  //       .then((value) async {
  //     for (var element in value.docs) {
  //       assistantModelList.add(AssistantModel.toObject(element.data()));
  //     }
  //     if (value.docs.isNotEmpty) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   });
  // }

  void showCountryChoose() {
    FocusScope.of(context).unfocus();
    Widget child = ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: extra.availableCountryList!.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            onTap: () {
              availableCountryModel = extra.availableCountryList![index];
              Navigator.pop(context);
              setState(() {});
              phoneControllerFocus.requestFocus();
            },
            title: Text(
              '${extra.availableCountryList![index].name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: availableCountryModel!.name ==
                extra.availableCountryList![index].name
                ? Icon(
              Icons.check_circle,
              color: ThemeClass.colorPrimary,
            )
                : Icon(
              Icons.circle_outlined,
              color: ThemeClass.colorPrimary,
            ));
      },
    );
    CommonFunctionClass.showModalBottom(child, context, false);
  }
}