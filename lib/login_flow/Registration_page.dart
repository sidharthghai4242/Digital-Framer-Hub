import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_farmer_hub/helper/CommonFunctions.dart';
import 'package:digital_farmer_hub/models/FarmerModel.dart';
import 'package:digital_farmer_hub/pages/Home_page.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../helper/AppColors.dart';
import '../helper/Constants.dart';
import '../helper/LoadingDialog.dart';
import '../helper/localization/language_constants.dart';
import '../helper/theme_class.dart';
import '../models/ExtraModel.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  String? phone;
  int? signal; // 0--> When new user sign up, 1--> on update details
  ExtraModel? extraModel = new ExtraModel();
  FarmerModel? farmerModel = FarmerModel();
  AvailableCountryModel availableCountryModel = AvailableCountryModel();

  RegisterPage(this.phone, this.extraModel, this.farmerModel, this.signal, this.availableCountryModel);

  @override
  State<RegisterPage> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController fatherNameController = TextEditingController();
  TextEditingController villageNameController = TextEditingController();
  TextEditingController districtNameController = TextEditingController();
  bool loading = false, otpVisible = false, boolEditProfile = false;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  String countryCode = "+91";
  String? verificationId,
      uid,uidP,
      farmerName = 'Next',
      fatherName = 'Next',
      mobileNumber,
      enterOtp,
      receivedOtp,
      smsCode,
      otpCode,
      villageName,
      districtName;
  bool? isStaffCheck;
  FarmerModel farmerModel = new FarmerModel();
  int? signal;
  File? file;
  File? _image;
  bool localImage = false;
  String imageUrl = "";
  DocumentReference? documentReference;
  FirebaseMessaging? _fcm = FirebaseMessaging.instance;
  StreamSubscription? iosSubscription;
  bool isPhoto = false, isCamera=false;
  StateSetter? resendOtpState;
  bool timerColorBool= false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    otpVisible = false;
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    print('Phone is :' + widget.phone.toString());
    if (widget.phone == '' || widget.phone == null || widget.phone!.isEmpty) {
      widget.phone = 'eg:1234567890';
    }
    signal = widget.signal;
    if (signal == 1) {
      farmerModel = widget.farmerModel!;
      phoneNumberController.text = farmerModel.phone!;
      nameController.text = farmerModel.farmerName!;
      fatherNameController.text = farmerModel.fatherName!;
      villageNameController.text = farmerModel.villageName!;
      districtNameController.text = farmerModel.districtName!;
      boolEditProfile = true;
      if(farmerModel.profileImage!=null||farmerModel.profileImage!=''){

      }
      // if (farmerModel.gender == 'Male') {
      //   selectedGender = 0;
      // } else {
      //   selectedGender = 1;
      // }
      setState(() {});
    }
    mobileNumber = widget.phone.toString();
    phoneNumberController.text = widget!.phone!;
  }

  // Future<void> verifyPhoneNo() async {
  //   verificationCompleted(AuthCredential credential) {
  //     print("verifyphonenumber");
  //     FirebaseAuth.instance.signInWithCredential(credential).then((onValue) {
  //       setState(() {
  //         print("working1");
  //         otpVisible = true;
  //         uid = onValue.user!.uid;
  //         autoSignInUser(onValue.user!.uid);
  //       });
  //       print('Verification_com : ' +
  //           uid! +
  //           "\n" +
  //           onValue.user!.uid.toString());
  //     });
  //   }
  //
  //   verificationFailed(Exception authException) {
  //     setState(() {
  //       print('authexp:$authException');
  //       Navigator.pop(context);
  //     });
  //   }
  //
  //   phoneCodeSent(String? verificationId, [int? forceResendingToken]) {
  //     this.verificationId = verificationId!;
  //     print('Phone Code Sent : ${this.verificationId}');
  //     Navigator.pop(context);
  //     otpVisible = true;
  //     setState(() {});
  //   }
  //
  //   phoneCodeAutoRetrievalTimeout(String verificationId) {
  //     this.verificationId = verificationId;
  //     print('CodeAutoRetrieve is : ${this.verificationId}');
  //     timerColorBool = true;
  //     setState(() {
  //
  //     });
  //   }
  //
  //   await FirebaseAuth.instance.verifyPhoneNumber(
  //       phoneNumber: '${widget.availableCountryModel.code!}${phoneNumberController.text}',
  //       timeout: const Duration(seconds: 60),
  //       verificationCompleted: verificationCompleted,
  //       verificationFailed: verificationFailed,
  //       codeSent: phoneCodeSent,
  //       codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout);
  // }

  Future<void> verifyPhoneNo() async {
    print("Requesting OTP");

    String phoneNumber = '${widget.availableCountryModel.code!}${phoneNumberController.text}';
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
      if (response.statusCode == 200 || responseData['success'] == true) {
        // OTP sent successfully
        Navigator.pop(context);
        otpVisible = true;
        setState(() {});
      } else {
        // Failed to send OTP
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "Failed to send OTP. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
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

  void autoSignInUser(String uid) async {
    print('Auto Login with UID: ${uid}'); // Initial UID passed

    // Check if the farmer already exists
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      // If the farmer exists, update their data
      print('Farmer exists with UID: ${uid}');
      farmerModel = FarmerModel.toObject(doc.data());
      farmerModel.uid = doc.id; // Ensure the existing UID is set
      print('FarmerModel UID after fetching existing data: ${farmerModel.uid}');
      farmerModel.farmerName = nameController.text;
      farmerModel.phone = phoneNumberController.text;
      farmerModel.fatherName = fatherNameController.text;
      farmerModel.villageName = villageNameController.text;
      farmerModel.districtName = districtNameController.text;
      updateUser();
    } else {
      // If the farmer does not exist, create a new one
      if (signal == 0) {
        print('No existing farmer found. Creating new farmer.');
        farmerModel.uid = uid; // Use the passed UID
        print('Setting FarmerModel UID: ${farmerModel.uid}');
        farmerModel.farmerName = nameController.text;
        farmerModel.phone = phoneNumberController.text;
        farmerModel.fatherName = fatherNameController.text;
        farmerModel.villageName = villageNameController.text;
        farmerModel.districtName = districtNameController.text;
        farmerModel.date = Timestamp.fromDate(DateTime.now());
        registerUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: colorWhite,
      body: loading
          ? LoadingDialog.showLoadingDialog(context)
          : SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: colorBlack,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${getTranslated(context, 'personalDetails')}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.raleway(
                            color: colorBlack,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${getTranslated(context, 'enterDetailsToSignUp')}",
                          style: GoogleFonts.raleway(
                              color: colorBlack,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    // InkWell(
                    //   onTap: () {
                    //     // getImagefromCamera();
                    //     if(isPhoto){
                    //       showOptions(context, "${getTranslated(context, 'choose')}");
                    //     }else{
                    //       CommonFunctionClass.showToast("${getTranslated(context, 'pleaseAllowGalleryAccessToProceed')}");
                    //       askPermission();
                    //     }
                    //   },
                    //   child: Container(
                    //     height: 60,
                    //     width: 60,
                    //     child: showImage(),
                    //   ),
                    // )
                  ],
                ),
              ),
              Divider(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.all(0),
                      children: <Widget>[
                        TextFormField(
                          autofocus:
                          boolEditProfile == true ? false : true,
                          controller: nameController,
                          decoration: InputDecoration(
                              labelText: "${getTranslated(context, 'name')}",
                              suffixIcon: Icon(Icons.person)),
                          validator: (val) {
                            if (val?.trim().length == 0) {
                              return "${getTranslated(context, 'nameCannotBeEmpty')}";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          enabled: boolEditProfile ? true : false,
                          controller: phoneNumberController,
                          keyboardType: TextInputType.numberWithOptions(signed: true,decimal:true),
                          decoration: new InputDecoration(
                            labelText: "${getTranslated(context, 'contact')}",
                            fillColor: colorWhite,
                            suffixIcon: Icon(Icons.phone),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          autofocus:
                          boolEditProfile == true ? false : true,
                          controller: fatherNameController,
                          decoration: InputDecoration(
                              labelText: "${getTranslated(context, 'fathername')}",
                              suffixIcon: Icon(Icons.person)),
                          validator: (val) {
                            if (val?.trim().length == 0) {
                              return "${getTranslated(context, 'fathernameCannotBeEmpty')}";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          autofocus:
                          boolEditProfile == true ? false : true,
                          controller: districtNameController,
                          decoration: InputDecoration(
                              labelText: "${getTranslated(context, 'districtName')}",
                              suffixIcon: Icon(Icons.location_city)),
                          validator: (val) {
                            if (val?.trim().length == 0) {
                              return "${getTranslated(context, 'districtNameCannotBeEmpty')}";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          autofocus:
                          boolEditProfile == true ? false : true,
                          controller: villageNameController,
                          decoration: InputDecoration(
                              labelText: "${getTranslated(context, 'villageName')}",
                              suffixIcon: Icon(Icons.maps_home_work_outlined)),
                          validator: (val) {
                            if (val?.trim().length == 0) {
                              return "${getTranslated(context, 'villageNameCannotBeEmpty')}";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        otpVisible ? otpFieldWidget() : Container(),
                      ],
                    ),
                  ),
                ),
              ),
              boolEditProfile == false
                 ? Container(
                    height: 50,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(
                    bottom: 10, left: 10, right: 10),
                child: Row(
                  children: <Widget>[
                    !otpVisible
                        ? nextButton()
                        : buttonProceedWidget(context),
                  ],
                ),
                   )
                 : Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(
                    bottom: 10, left: 10, right: 10),
                child: Row(
                  children: <Widget>[saveButton()],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget nextButton() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        width: MediaQuery.of(context).size.width,
        height: 50,
        child: InkWell(
          onTap: (){
            if (_formKey.currentState!.validate()) {
              LoadingDialog.showLoadingDialog(context);
              verifyPhoneNo();
              print('verifyPhoneNo');
            } else {
              Fluttertoast.showToast(
                  msg: "${getTranslated(context, 'checkFields')}",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 2,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          },
          child: Container(
            decoration: const BoxDecoration(
                color: colorPrimary,
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Center(
              child: Text(
                "${getTranslated(context, 'createAccount')}",
                style: TextStyle(fontSize: 18, color: colorWhite),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buttonProceedWidget(context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        width: MediaQuery.of(context).size.width,
        height: 50,
        child: InkWell(
          onTap: (){
            if (_formKey.currentState!.validate()) {
              this.enterOtp = otpController.text;
              if (otpController.text == null || otpController.text.isEmpty) {
                print("SMS Code Null !");
              } else {
                LoadingDialog.showLoadingDialog(context);
                signInWithPhone(context);
              }
            } else {}
          },
          child: Container(
            decoration: BoxDecoration(
                color: colorPrimary,
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Center(
              child: Text(
                "${getTranslated(context, 'register')}",
                style: TextStyle(fontSize: 18, color: colorWhite),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signInWithPhone(BuildContext context) async {
    try {
      // Check if entered OTP matches received OTP
      print(enterOtp);
      print(receivedOtp);
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
        return;
      }

      // Proceed if OTP is valid
      Uri uri = Uri.parse('https://us-central1-digitalfarmerhub.cloudfunctions.net/getAuthCustomToken');
      http.Response httpResponse = await http.post(uri, body: {
        "mobile": '${widget.availableCountryModel.code!}${phoneNumberController.text}'
      });
      Map<String, dynamic> responseJSON = jsonDecode(httpResponse.body);

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCustomToken(responseJSON['firebaseCustomToken']);
      uid = userCredential.user?.uid;

      if (uid != null) {
        String phoneNumber = '${phoneNumberController.text}';
        var query = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: phoneNumber)
            .get();

        if (query.docs.isNotEmpty) {
          var doc = query.docs.first;
          farmerModel = FarmerModel.toObject(doc.data());
          uidP = doc.id;
          isStaffCheck = farmerModel.isStaff;
          await FirebaseFirestore.instance.collection('users').doc(uidP).delete();
          print("Document with id $uidP deleted successfully");
        }

        farmerModel.uid = uid;
        farmerModel.farmerName = nameController.text;
        farmerModel.phone = phoneNumberController.text;
        farmerModel.fatherName = fatherNameController.text;
        farmerModel.villageName = villageNameController.text;
        farmerModel.districtName = districtNameController.text.toUpperCase();
        farmerModel.profileImage = imageUrl.toString();
        farmerModel.date = Timestamp.fromDate(DateTime.now());
        farmerModel.loginDate = Timestamp.fromDate(DateTime.now());
        farmerModel.loginType = 0;
        String districtId = await _setDistrictId(districtNameController.text.toUpperCase());
        farmerModel.districtId = districtId;
        // if (isStaffCheck != null && isStaffCheck!) {
        //   farmerModel.isStaff = true;
        // } else {
        //   farmerModel.isStaff = false;
        // }
        farmerModel.isStaff = (isStaffCheck != null) ? isStaffCheck! : false;

        registerUser();
      }
    } catch (e) {
      print('Error in verify OTP: $e');
    }
  }


  Future<String> getFirebaseToken() async {
    return await firebaseMessaging.getToken().then((value) {
      return value!;
    });
  }

  Future<String> _setDistrictId(String districtName) async {
    final districtsCollection = FirebaseFirestore.instance.collection('districts');

    // Check if the district already exists
    final querySnapshot = await districtsCollection.where('districtName', isEqualTo: districtName).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      // District exists, return the existing document ID
      return querySnapshot.docs.first.id;
    } else {
      // District does not exist, create a new document
      final newDistrictDoc = districtsCollection.doc();
      final newDistrictId = newDistrictDoc.id;
      await newDistrictDoc.set({
        'districtName': districtName.toUpperCase(),
        'districtId': newDistrictId,
        'createdOn': Timestamp.now(),
      });
      return newDistrictId;
    }
  }

  otpFieldWidget() {
    // startTimer();
    return Column(
      children: [
        TextFormField(
          decoration: new InputDecoration(
              labelText: "${getTranslated(context, 'enterOtp')}",
              fillColor: colorWhite,
              suffixIcon: Icon(Icons.phone_android)),
          onChanged: (val) {},
          keyboardType: TextInputType.number,
          maxLines: 1,
          inputFormatters: [LengthLimitingTextInputFormatter(4)],
          controller: otpController,
          validator: (val) {
            if (val!.isEmpty ||
                val.length > 4 ||
                val.length < 4 ||
                val == '' ||
                val == null) {
              return "${getTranslated(context, 'enterValidOtp')}";
            } else {
              return null;
            }
          },
        ),
        SizedBox(height: 16,),
        StatefulBuilder(builder: (BuildContext context,
            void Function(void Function()) setState) {
          resendOtpState = setState;
          return InkWell(
            onTap: (){
              if(timerColorBool){
                timerColorBool = false;
                LoadingDialog.showLoadingDialog(context);
                // startTimer();
                verifyPhoneNo();
                setState((){});
              }
            },
            child: Text(timerColorBool?"${getTranslated(context, 'resendOtp')}":"${getTranslated(context, 'ifNotReceivedThenResendOptionWillComeAfter60Seconds')}",
              style: TextStyle(fontWeight: timerColorBool?FontWeight.bold:FontWeight.normal,
                  fontSize: timerColorBool?16:12,
                  color: timerColorBool?colorPrimary:Colors.grey.shade400),),
          );
        })
      ],
    );
  }

  registerUser() async {
    // if (Platform.isIOS) {
    //   iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
    //     // save the token  OR subscribe to a topic here
    //   });
    //   _fcm.requestNotificationPermissions(IosNotificationSettings());
    // }
    farmerModel.token = await getFirebaseToken();;
    farmerModel.platform = Platform.operatingSystem;
    if (_image != null) {
      await uploadImages(context);
    }
    FirebaseFirestore.instance
        .collection(users)
        .doc(uid)
        .set(farmerModel.getMap())
        .then((value) {
      LoadingDialog.stopLoadingDialog(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){
        return HomePage(this.uid!, widget.extraModel!);
      }));
    });
  }

  updateUser() async {
    String? fcmToken = await _fcm?.getToken();
    farmerModel.token = fcmToken;
    farmerModel.platform = Platform.operatingSystem;
    // if (_image != null) {
    //   await uploadImages(context);
    // }
    FirebaseFirestore.instance
        .collection(users)
        .doc(farmerModel.uid)
        .update(farmerModel.getMap())
        .then((value) {
      LoadingDialog.stopLoadingDialog(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){
        return HomePage(this.farmerModel.uid!, widget.extraModel!);
      }));
    });
  }

  showOptions(BuildContext context, String title) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    getImage();
                  },
                  child: Container(
                      padding: EdgeInsets.all(8), child: Text("${getTranslated(context, 'phoneGallery')}")),
                ),
                SizedBox(
                  height: 8,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    getImagefromCamera();
                  },
                  child: Container(
                      padding: EdgeInsets.all(8), child: Text("${getTranslated(context, 'camera')}")),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("${getTranslated(context, 'cancel')}"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget? showImage() {
    if(signal==0||localImage==true){
      return CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        maxRadius: 30,
        minRadius: 20,
        child: Container(
          padding: EdgeInsets.all(4),
          // child: Image.file(
          //   _image,
          //   width: 300,
          //   height: 300,
          // ),
        ),
      );

    }else{
      if (farmerModel.profileImage == null ||
          farmerModel.profileImage!.isEmpty ||
          farmerModel.profileImage == '') {
        return CircleAvatar(
          maxRadius: 25,
          backgroundColor: colorPrimary,
          backgroundImage: NetworkImage(
              'https://www.freeiconspng.com/uploads/no-image-icon-4.png'),
        );
      }else if(farmerModel.profileImage!=null||farmerModel.profileImage!=''){
        return CircleAvatar(
          maxRadius: 25,
          backgroundColor: colorPrimary,
          backgroundImage: NetworkImage(
              farmerModel.profileImage!),
        );
      }
    }
  }

  Future askPermission() async {
    if(await Permission.photos.request().isGranted){
      isPhoto = true;
    }else{
      isPhoto = false;
    }

    if(await Permission.camera.request().isGranted){
      isCamera = true;
    }else{
      isCamera = false;
    }

    return true;}

  Future getImage() async {
    XFile? f = await ImagePicker().pickImage(source: ImageSource.gallery);
    _image = File(f!.path);
    setState(() {
      localImage = true;
    });
    // uploadImages(context);
  }

  Future getImagefromCamera() async {
    XFile? f = await ImagePicker().pickImage(source: ImageSource.camera);
    _image = File(f!.path);
    setState(() {
      localImage = true;
      // print('Image Path : '+_image.path);
    });
    // uploadImages(context);
  }

  Future<void> uploadImages(context) async {
    LoadingDialog.showLoadingDialog(context);
    // documentReference = Firestore.instance.collection(prod).doc();
    firebase_storage.Reference firebaseStorageRef = await FirebaseStorage.instance
        .ref()
        .child("Farmers/" + farmerModel.uid! + "/Profile/");
    firebase_storage.UploadTask task = firebaseStorageRef.putFile(await _image!);

    // var downUrl = await (await task.onComplete).ref.getDownloadURL();
    String downUrl = '';
    await task.whenComplete(() async {
      downUrl = await firebaseStorageRef.getDownloadURL();
    });
    // var downUrl = await firebaseStorageRef.getDownloadURL();
    imageUrl = downUrl.toString();
    print('url is ${imageUrl.toString()}');
    setState(() {
      farmerModel.profileImage = imageUrl;
      print('testImageState' + farmerModel.profileImage! + '\n' + imageUrl);
      LoadingDialog.stopLoadingDialog(context);
    });
  }

  showProfileImage() {
    if (farmerModel.profileImage == null ||
        farmerModel.profileImage!.isEmpty ||
        farmerModel.profileImage == '') {
      return CircleAvatar(
        maxRadius: 25,
        backgroundColor: colorPrimary,
        backgroundImage: NetworkImage(
            'https://www.freeiconspng.com/uploads/no-image-icon-4.png'),
      );
    } else if (farmerModel.profileImage != null) {
      return CircleAvatar(
          maxRadius: 25,
          backgroundColor: colorPrimary,
          backgroundImage: NetworkImage(farmerModel.profileImage!));
    } else {
      return CircleAvatar(
          maxRadius: 25,
          backgroundColor: colorPrimary,
          backgroundImage: NetworkImage(_image.toString()));
    }
  }

  Widget saveButton() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        width: MediaQuery.of(context).size.width,
        height: 50,
        child: InkWell(
          onTap: (){
            if (_formKey.currentState!.validate()) {
              LoadingDialog.showLoadingDialog(context);
              autoSignInUser(farmerModel.uid!);
            } else {}
          },
          child: Container(
            decoration: const BoxDecoration(
                color: colorPrimary,
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Center(
              child: Text(
                "${getTranslated(context, 'save')}",
                style: TextStyle(fontSize: 18, color: colorWhite),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
