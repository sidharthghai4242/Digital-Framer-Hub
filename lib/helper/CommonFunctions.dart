import 'dart:async';
import 'dart:ui';
import 'package:digital_farmer_hub/helper/theme_class.dart';
import 'package:digital_farmer_hub/helper/theme_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';

import '../main.dart';
import '../models/ContentModel.dart';
import '../models/top_model_sheet.dart';
import '../pages/Notification_page.dart';
import '../pages/Pdf_viewer.dart';
import '../pages/lecturesPlay.dart';
import '../pages/news_detail.dart';
import '../pages/lectures.dart';
import 'localization/languageDropDown.dart';
import 'localization/language_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonFunctionClass extends StatelessWidget {

  static getLanguageCode(String code, context) {
    List<String> languageCode = ['en', 'hi', 'pa'];
    return languageCode.indexOf(code);
  }

  static Future<int> getLocalLanguage(context) async {
    Locale _locale = await getLocale();
    String code = _locale.toString().split('_')[0].toString();
    return CommonFunctionClass.getLanguageCode(code, context);
  }

  static Future<String> getLocalLanguageCode(context) async {
    Locale _locale = await getLocale();
    return _locale.toString().split('_')[0].toString();
  }

  static void changeLanguage(Language language, context) async {
    Locale _locale = await setLocale(language.languageCode);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("languageCode", language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  static void showPrint(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 14,
        backgroundColor: Colors.grey.shade800,
        textColor: Colors.white);
  }

  static showModalBottom(
      Widget widget, BuildContext context, bool paddingFlag) async {
    Widget data = paddingFlag
        ? Container(
      color: Colors.white,
      padding:
      const EdgeInsets.only(top: 36, left: 16, right: 16, bottom: 16),
      child: widget,
    )
        : widget;
    return showModalBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: false,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (BuildContext context) {
          return data;
        }).then((value) {
      return value;
    });
  }

  static Future<String?> showModalBottomMenu(BuildContext context, String initialSelectedLanguage) async {
    return await showModalBottomSheet<String>(
      context: context,
      isDismissible: true, // Allows closing the modal by tapping outside
      enableDrag: true, // Allows dragging to close
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Initial selected language state
            String selectedLanguage = initialSelectedLanguage;

            return FractionallySizedBox(
              heightFactor: 0.4, // Adjust this factor according to your needs
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Languages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(), // Prevent scrolling
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text('English'),
                              trailing: selectedLanguage == 'English'
                                  ? Icon(Icons.check_circle, color: Colors.green)
                                  : Icon(Icons.circle_outlined, color: Colors.grey),
                              onTap: () {
                                setState(() {
                                  selectedLanguage = 'English'; // Update selected language
                                });
                                CommonFunctionClass.changeLanguage(
                                    Language.languageList()[0],
                                    context);
                                Navigator.pop(context, 'English');
                              },
                            ),
                            ListTile(
                              title: Text('हिंदी'),
                              trailing: selectedLanguage == 'Hindi'
                                  ? Icon(Icons.check_circle, color: Colors.green)
                                  : Icon(Icons.circle_outlined, color: Colors.grey),
                              onTap: () {
                                setState(() {
                                  selectedLanguage = 'Hindi'; // Update selected language
                                });
                                CommonFunctionClass.changeLanguage(
                                    Language.languageList()[1],
                                    context);
                                Navigator.pop(context, 'Hindi');
                              },
                            ),
                            ListTile(
                              title: Text('ਪੰਜਾਬੀ'),
                              trailing: selectedLanguage == 'Punjabi'
                                  ? Icon(Icons.check_circle, color: Colors.green)
                                  : Icon(Icons.circle_outlined, color: Colors.grey),
                              onTap: () {
                                setState(() {
                                  selectedLanguage = 'Punjabi'; // Update selected language
                                });
                                CommonFunctionClass.changeLanguage(
                                    Language.languageList()[2],
                                    context);
                                Navigator.pop(context, 'Punjabi');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Route<Object?> pageRouteBuilder(dynamic routeChild) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation, // Use the animation directly for opacity
          child: routeChild,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return CommonFunctionClass.pageRouteBuilderFadeAnimation(
            context, animation, secondaryAnimation, child);
      },
    );
  }

  static bool isWeb() {
    return kIsWeb;
  }

  static void showTopModelNotification(String title, String body, BuildContext context, ContentModel contentModel) async {
    if (!isWeb()) {
      bool? flag = await Vibration.hasVibrator();
      if (flag!) {
        Vibration.vibrate();
      }
    }

    Widget data = GestureDetector(
      onTap: () {
        // Check the contentModel.type and navigate accordingly
        if (contentModel.type == 0) {
          Navigator.push(
            context,
            CommonFunctionClass.pageRouteBuilder(Lectures()),
            // CommonFunctionClass.pageRouteBuilder(LecturePlay(videoId: contentModel.youtubeVideoId ?? '')),
          );
        } else if (contentModel.type == 4 || contentModel.type == 2 || contentModel.type == 3) {
          Navigator.push(
            context,
            CommonFunctionClass.pageRouteBuilder(NewsDetailPage(contentModel: contentModel)),
          );
        } else if (contentModel.type == 1) {
          print("Unsupported content type");
          Navigator.push(
            context,
            CommonFunctionClass.pageRouteBuilder(PDFViewer(
                title: contentModel.title ?? '',
                pdfUrl: contentModel.pdfUrl ?? '',
              ),
            ),
          );
        } else {
          // Handle other types if needed
          print("Unsupported content type");
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.only(top: 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: ThemeClass.colorGreenLight,
                child: ClipOval(
                  child: Image.asset(
                    'assets/main_logo.jpg',
                    fit: BoxFit.cover,
                    width: 36,
                    height: 36,
                  ),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      body,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );

    // Future.delayed(Duration(seconds: 5), () {
    //   Navigator.of(context, rootNavigator: true).pop();
    // });
    showTopModalSheet(context, data);
  }

  static void showTopModelNotification2(String title, String body, BuildContext context) async {
    if (!isWeb()) {
      bool? flag = await Vibration.hasVibrator();
      if (flag!) {
        Vibration.vibrate();
      }
    }

    Widget data = GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CommonFunctionClass.pageRouteBuilder(NotificationPage()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.only(top: 0.0), // Add padding at the top
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: ThemeClass.colorGreenLight,
                child: ClipOval(
                  child: Image.asset(
                    'assets/main_logo.jpg',
                    fit: BoxFit.cover,
                    width: 36,
                    height: 36,
                  ),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      body,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );

    showTopModalSheet(context, data);
  }

  static pageRouteBuilderFadeAnimation(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);
    return FadeTransition(
      opacity: fadeAnimation,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}




