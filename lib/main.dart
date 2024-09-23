import 'dart:io';
import 'package:digital_farmer_hub/firebase_options.dart';
import 'package:digital_farmer_hub/helper/theme_class.dart';
import 'package:digital_farmer_hub/models/FarmerModel.dart';
import 'package:digital_farmer_hub/pages/Home_page.dart';
import 'package:digital_farmer_hub/provider/client_db_provider.dart';
import 'package:digital_farmer_hub/helper/Constants.dart';
import 'package:digital_farmer_hub/helper/localization/language_constants.dart';
import 'package:digital_farmer_hub/helper/CommonFunctions.dart';
import 'package:digital_farmer_hub/models/ExtraModel.dart';
import 'package:digital_farmer_hub/login_flow/login_page.dart';
import 'package:digital_farmer_hub/login_flow/landing_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:digital_farmer_hub/firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'helper/AppColors.dart';
import 'helper/localization/languageDropDown.dart';
import 'helper/localization/language_constants.dart';
import 'helper/localization/localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ClientDBProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale){
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale){
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark));
    return MaterialApp(
      title: appName,
      color: colorPrimary,
      debugShowCheckedModeBanner: false,
      theme: ThemeClass.darktheme,
      locale: _locale,
      supportedLocales: const [
        Locale("en", "US"),
        Locale("hi", "IN"),
        Locale("pa", "IN"),
      ],
      localizationsDelegates: const [
        DemoLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale!.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      home: const MyHomePage(title: appName),
    );
  }
}

Widget loadingWidget() {
  return Align(
    alignment: Alignment.topCenter,
    child: Container(
      margin: const EdgeInsets.only(top: 20),
      height: 40,
      width: 40,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colorPrimary),
          ),
        ),
      ),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title, uid = "";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FarmerModel farmerModel = FarmerModel();
  bool checkIfUserLogin = false;
  ExtraModel extraModel = ExtraModel();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ExtraModel? extraa;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () async {
      checkAppUpdate();
    });
  }

  Widget splashUi() {
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: [
          const Image(
            image: AssetImage('assets/Splash2.jpg'),
            fit: BoxFit.fitHeight,
            width: double.infinity,  // To ensure the image covers the entire width
            height: double.infinity,  // To ensure the image covers the entire height
          ),
          Container(
            color: Colors.white.withOpacity(0.2),
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            top: 70,  // Adjust the position as needed
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image(
                  image: AssetImage('assets/main_logo.jpg'),
                  width: 170,
                  height: 170,
                  fit: BoxFit.cover,
                ),
              ),

            ),
          ),
          Positioned(
            bottom: 30,  // Adjust the position as needed
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Harvest the Power of Digital Farming',
                style: TextStyle(
                  color: Colors.white,  // Adjust color as needed
                  fontSize: 17,  // Adjust font size as needed
                  fontWeight: FontWeight.w600,  // Adjust font weight as needed
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  checkAppUpdate() async {
    print('check for update');
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    extraa = await context.read<ClientDBProvider>().fetchUpdate();

    FirebaseFirestore.instance
        .collection(extra)
        .doc(extra)
        .get()
        .then((value) {
      print('value is :${value.data()}');
      if (!value.exists) {
        CommonFunctionClass.showToast(
            "Something went wrong. Please try again later.");
        print('value - :');
        return;
      }
      extraModel = ExtraModel.toObject(value.data());
      int? versionConst;
      if (Platform.isAndroid) {
        versionConst = extraModel.userAppAndroidVersion;
      } else if (Platform.isIOS) {
        versionConst = extraModel.userAppIosVersion;
      }
      print("App Latest Version ${versionConst.toString()}");
      if (versionConst! > int.parse(buildNumber)) {
        // Navigator.pushReplacement(context,
        //     new CupertinoPageRoute(builder: (context) => UpdateAppActivity()));
      } else {
        checkIfUserLoggedIn();
      }
    });
  }

  Future<void> checkIfUserLoggedIn() async {
    final User? user = await _auth.currentUser;
    if (user != null) {
      getUser(user.uid);
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) {
            return LandingPage(extraModel);
          }));
    }
  }

  getUser(String uid) {
    FirebaseFirestore.instance
        .collection(users)
        .where('uid', isEqualTo: uid)
        .get()
        .then((snapshot) {

      if (snapshot.docs.isEmpty) {
        print('uid isEmpty');
        FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
              return LandingPage(extraModel);
            }));
      } else {
        farmerModel = FarmerModel.toObject(snapshot.docs[0].data());
        loginedFarmer = FarmerModel.toObject(snapshot.docs[0].data());
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
              return HomePage(farmerModel.uid, extraModel);
            }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: splashUi(),
    );
  }
}