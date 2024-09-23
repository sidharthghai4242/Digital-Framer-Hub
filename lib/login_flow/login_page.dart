import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_farmer_hub/pages/Home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digital_farmer_hub/models/ExtraModel.dart';
import 'package:digital_farmer_hub/helper/AppColors.dart';
import 'package:digital_farmer_hub/helper/Constants.dart';
import 'package:digital_farmer_hub/models/FarmerModel.dart';
import 'package:provider/provider.dart';
import '../helper/AppColors.dart';
import '../helper/CommonFunctions.dart';
import '../helper/LoadingDialog.dart';
import '../helper/localization/language_constants.dart';
import '../helper/theme_class.dart';
import '../provider/client_db_provider.dart';
import 'Registration_page.dart';

class LoginPage extends StatefulWidget {
  ExtraModel extraModel = new ExtraModel();
  LoginPage(ExtraModel extraModel){
    this.extraModel = extraModel;
  }
  // const LoginPage({super.key});

  @override
  State<LoginPage> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController? phoneNumberController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  FirebaseMessaging _fcm = FirebaseMessaging.instance;
  StreamSubscription? iosSubscription;
  bool otpVisible=false;
  String countryCode = "+91";
  String? verificationId, uid,name='Next',mobileNumber,smsCode;
  var _key = GlobalKey<FormState>();
  FocusNode _focusNode = new FocusNode();
  FarmerModel farmerModel = new FarmerModel();
  FocusNode phoneControllerFocus = FocusNode();
  AvailableCountryModel? availableCountryModel;
  ExtraModel? extra;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      extra = context.read<ClientDBProvider>().extraModel;
      CommonFunctionClass.showPrint('${extra?.availableCountryList}');
      availableCountryModel = extra?.availableCountryList![0];
      setState(() {});
      phoneControllerFocus.requestFocus();
    });
    // TODO: implement initState
    super.initState();
    otpVisible = false;
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: colorWhite,
          body: loginUi(),
        ),
      ),
    );
  }

  Future<void> verifyPhoneNo() async {
    verificationCompleted(AuthCredential credential) {
      FirebaseAuth.instance.signInWithCredential(credential).then((onValue) {
//        autoSignInUser(onValue.user.uid);
        setState(() {
          // CommonFunctionClass.showToast('Error-6');
          otpVisible = true;
          autoSignInUser(onValue.user!.uid);
        });
      }).catchError((onError){
        // CommonFunctionClass.showToast('Error-7'+onError.toString());
      });
    }

    verificationFailed(Exception authException) {
      setState(() {
        // CommonFunctionClass.showToast('Error-8');
        // CommonFunctionClass.showToast('PhoneVerificationFailed:-> ${authException.code}, Message${authException.message}');
        Navigator.pop(context);
      });
    }

    phoneCodeSent(String? verificationId, [int? forceResendingToken]) {
      this.verificationId = verificationId;
      print('Phone Code Sent : ${this.verificationId}');
      // CommonFunctionClass.showToast('phone code sent');
      setState(() {
        otpVisible = true;
        name = "Continue";
        Navigator.pop(context);
      });
    }

    phoneCodeAutoRetrievalTimeout(String verificationId) {
      this.verificationId = verificationId;
      // print('CodeAutoRetrieve is : ${this.verificationId}');
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "${availableCountryModel!.code!}${phoneNumberController!.text!}",
        timeout: Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: phoneCodeSent,
        codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout);
  }

  signIn(BuildContext context) {
    LoadingDialog.showLoadingDialog(context);
    AuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: verificationId!, smsCode: smsCode!);

    FirebaseAuth.instance.signInWithCredential(authCredential).then((user) async {
      print("signed in " + user.toString());
      // if(farmerModel.reminderList==null){
      //   await updatePatientReminders();
      // }
      _saveDeviceToken(user.user!.uid);
      Navigator.pop(context);

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) {
            return HomePage(user.user!.uid,widget.extraModel);
          }));
    }).catchError((onError){
      Navigator.pop(context);
      CommonFunctionClass.showToast("${getTranslated(context, 'invalidCode')}");
    });
  }

  autoSignInUser(String uid) async {
    print('Auto Login : ${uid}');
    // if(farmerModel.reminderList==null){
    //   await updatePatientReminders();
    // }
    _saveDeviceToken(uid);
    Navigator.pop(context);
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
          return HomePage(uid,widget.extraModel);
        }));
  }

  checkUser(context) {
    FirebaseFirestore.instance.collection(prod).doc(prod)
        .collection(users)
        .where('phone',isEqualTo:phoneNumberController!.text)
        .get()
        .then((snapshot) async {
      if (snapshot.docs.isEmpty) {
        // CommonFunctionClass.showToast('Error-3');
//        Navigator.pop(context);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
              return RegisterPage(phoneNumberController!.text,widget.extraModel,null,0, availableCountryModel!);
            }));
      }else{
        farmerModel = FarmerModel.toObject(snapshot.docs[0].data());
        loginedFarmer = FarmerModel.toObject(snapshot.docs[0].data());
        verifyPhoneNo();
      }
    });
  }

  Widget loginUi() {
    return SingleChildScrollView(
        child: Center(
          child: Container(
            color: colorWhite,
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                ),
                const Image(image: AssetImage('assets/icon_app_1.png'),
                  height: 130,
                  width: 150,),
                Container(
                  margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20,top: 10),
                  child:  Column(
                    children: [
                      Text(
                        "${getTranslated(context, 'enterYourMobileNumberToGetOtp')}",
                        style: TextStyle(fontSize: 20, color: Colors.black,fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
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
                                availableCountryModel?.code ?? "",
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
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20), // Adjust horizontal padding as needed
                //   child: TextFormField(
                //     controller: phoneNumberController,
                //     autofocus: true,
                //     enabled: true,
                //     maxLength: 10,
                //     keyboardType: TextInputType.number,
                //     inputFormatters: <TextInputFormatter>[
                //       FilteringTextInputFormatter.digitsOnly,
                //     ],
                //     cursorColor: Colors.black,
                //     decoration: InputDecoration(
                //       counterText: "",
                //       labelText: "${getTranslated(context, 'enterPhoneNumber')}",
                //       labelStyle: GoogleFonts.openSans(fontSize: 16, color: darkGrey),
                //       contentPadding:
                //       const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                //       border: OutlineInputBorder(
                //         borderSide:
                //         BorderSide(color: Colors.grey.shade200, width: 0.7),
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //       focusedBorder: OutlineInputBorder(
                //         borderSide:
                //         const BorderSide(color: darkGrey, width: 1),
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //       errorBorder: OutlineInputBorder(
                //         borderSide:
                //         const BorderSide(color: Colors.red, width: 0.7),
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //     ),
                //   ),
                // ),

                // SizedBox(
                //   height: 15,
                // ),
                otpVisible? otpFieldWidget() : Container(),
                Padding(
                  padding: EdgeInsets.only(
                      top: 20.0, left: 20.0, right: 20.0),
                  child: Row(
                    children: <Widget>[
                      !otpVisible
                          ? nextButton()
                          : buttonProceedWidget(context),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0), // Adjust left padding as needed
                      child: Text(
                        "${getTranslated(context, 'byClickingIAcceptTheTermsConditions')}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.exo(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        )
    );
  }

  void showCountryChoose() {
    FocusScope.of(context).unfocus();
    Widget child = ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: extra?.availableCountryList!.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            onTap: () {
              availableCountryModel = extra?.availableCountryList![index];
              Navigator.pop(context);
              setState(() {});
              phoneControllerFocus.requestFocus();
            },
            title: Text(
              '${extra?.availableCountryList![index].name}',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            trailing: availableCountryModel?.name ==
                extra?.availableCountryList![index].name
                ? const Icon(
              Icons.check_circle,
              color: ThemeClass.colorPrimary,
            )
                : const Icon(
              Icons.circle_outlined,
              color: ThemeClass.colorPrimary,
            ));
      },
    );
    CommonFunctionClass.showModalBottom(child, context, false);
  }

  Widget otpFieldWidget() {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 16),
      child: Column(
        children: [
          Theme(
            data: ThemeData(primaryColor: colorPrimary),
            child: TextFormField(
              textAlign: TextAlign.left,
              keyboardType: TextInputType.phone,
              maxLines: 1,
              inputFormatters: [LengthLimitingTextInputFormatter(6)],
              controller: otpController,
              // cursorColor: colorGreen,
              decoration: InputDecoration(
                counterText: "",
                labelText: "${getTranslated(context, 'enterOtp')}",
                labelStyle: GoogleFonts.openSans(fontSize: 16, color: darkGrey),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                border: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.grey.shade200, width: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                  const BorderSide(color: darkGrey, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide:
                  const BorderSide(color: Colors.red, width: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 2, left: 2),
            alignment: Alignment.centerLeft,
            child: Text(
              "${getTranslated(context, 'enter6DigitsOtpSentOnYourMobile')}",
              style: GoogleFonts.exo(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget nextButton() {
    return Expanded(
      child: TextButton(
        onPressed: (){
          mobileNumber = phoneNumberController?.text;
          FocusScope.of(context).unfocus();
          if (phoneNumberController!.text.length < 10) {
            CommonFunctionClass.showToast("${getTranslated(context, 'enterValidPhoneNumber')}"
            );
            // LoadingDialog.stopLoadingDialog(context);
          } else {
            // CommonFunctionClass.showToast('Error-2');
            LoadingDialog.showLoadingDialog(context);
            checkUser(context);
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: ThemeClass.colorGreenDark,
          padding: const EdgeInsets.all(16.0), // Button padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                12.0), // Button border radius
          ),
        ),
        child: Text(
          "${getTranslated(context, 'getOtp')}",
          style: GoogleFonts.exo(
            color: Colors.white,
            fontSize: 16,
          ),
        ),

      ),
    );
  }

  Widget buttonProceedWidget(context) {
    return Expanded(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: TextButton(
          onPressed: (){
            this.smsCode = otpController.text;
            if (otpController.text == null || otpController.text.isEmpty || otpController.text.length<6) {
              print("SMS Code Null !");
            } else {
              print("Button Proceed pressed");
              // if (Platform.isIOS) {
              //   iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
              //     // save the token  OR subscribe to a topic here
              //   });
              //   _fcm.requestNotificationPermissions(IosNotificationSettings());
              // }
              signIn(context);
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: ThemeClass.colorGreenDark ,
            padding: const EdgeInsets.all(16.0), // Button padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  12.0), // Button border radius
            ),
          ),
          child: Text("${getTranslated(context, 'continue')}"
            ,
            style: GoogleFonts.exo(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  _saveDeviceToken(uid) async {
    String? fcmToken = await _fcm.getToken();
    if (fcmToken != null) {
      var tokens = FirebaseFirestore.instance
          .collection(users)
          .doc(farmerModel.uid);

      await tokens.update({
        'token': fcmToken,
        'platform': Platform.operatingSystem
      });
    }
  }

}