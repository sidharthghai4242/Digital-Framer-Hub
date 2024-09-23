import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:digital_farmer_hub/models/ExtraModel.dart';

import '../helper/AppColors.dart';
import '../helper/CommonFunctions.dart';
import '../helper/localization/language_constants.dart';
import '../helper/theme_class.dart';
import 'package:digital_farmer_hub/login_flow/login_page.dart';

import 'login_otp.dart';

class LandingPage extends StatefulWidget {
  ExtraModel extraModel = new ExtraModel();
  List<String> selectedLanguages = [];

  LandingPage(ExtraModel extraModel) {
    this.extraModel = extraModel;
  }

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  PageController? _controller;
  double currentPage = 0;
  bool isPhoto = false, isCamera = false;
  bool englishSelected = false;
  bool punjabiSelected = false;
  bool hindiSelected = false;
  String selectedLanguage = 'English';

  @override
  void initState() {
    // TODO: implement initState
    _controller = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   List<Widget> items = [
     loginUi(context)
   ];

   return Scaffold(
     backgroundColor: Colors.white,
     body: Column(
       children: <Widget>[
         Expanded(
           child: PageView(
             children: items,
             controller: _controller,
           ),
         ),
       ],
     ),
   );
  }

  Widget loginUi(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0, right: 16.0 ),
                      child: SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Call showModalBottomMenu and wait for the result
                            final selected = await CommonFunctionClass.showModalBottomMenu(context, selectedLanguage);
                            if (selected != null) {
                              setState(() {
                                selectedLanguage = selected; // Update the selected language
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                            backgroundColor: ThemeClass.colorPrimary,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.language,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Language',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  flex: 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image(
                        image: AssetImage('assets/main_logo.jpg'),
                        height: 340,
                        width: 340,
                      ),
                      // Image(
                      //   image: AssetImage('assets/Splash.jpg'),
                      //   height: 100,
                      //   width: 150,
                      // ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 60,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                            return LoginOtpActivity(widget.extraModel);
                          }));
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: ThemeClass.colorGreenDark,
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Center(
                        child: Text(
                          "${getTranslated(context, 'login')}",
                          // 'Login',
                          style: GoogleFonts.openSans(
                              fontSize: 18, color: colorWhite),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "${getTranslated(context, 'jointhecommunityLogintoconnectwithfellowfarmers')}",
                        style: GoogleFonts.openSans(
                            fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
