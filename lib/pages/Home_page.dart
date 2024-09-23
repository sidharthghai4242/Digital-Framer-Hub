import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:digital_farmer_hub/models/ContentModel.dart';
import 'package:digital_farmer_hub/pages/lecturesPlay.dart';
import 'package:digital_farmer_hub/pages/report_pdf.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'NonIntensiveForm_page.dart';
import 'Search_page.dart';
import 'event_detail.dart';
import 'dart:ui';
import 'gallery_page.dart';
import 'upcoming_events.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_farmer_hub/login_flow/Registration_page.dart';
import 'package:digital_farmer_hub/models/ExtraModel.dart';
import 'package:digital_farmer_hub/models/GalleryModel.dart';
import 'package:digital_farmer_hub/pages/AboutUs_page.dart';
import 'package:digital_farmer_hub/pages/Information_page.dart';
import 'package:digital_farmer_hub/pages/UserProfile.dart';
import 'package:digital_farmer_hub/pages/Videos_page.dart';
import 'package:digital_farmer_hub/pages/news_page.dart';
import 'package:digital_farmer_hub/pages/lectures.dart';
import 'package:digital_farmer_hub/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
// import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:spring/spring.dart';
import 'package:permission_handler/permission_handler.dart';
import '../helper/AppColors.dart';
import '../helper/CommonFunctions.dart';
import '../helper/Constants.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../helper/loaderWidget.dart';
import '../helper/localization/language_constants.dart';
import '../helper/theme_class.dart';
import '../main.dart';
import '../models/FarmerModel.dart';
import '../models/MemberModel.dart';
import '../models/NotificationModel.dart';
import '../models/SliderModel.dart';
import '../provider/client_db_provider.dart';
// import 'GalleryFlow/images_page.dart';
import 'package:badges/badges.dart' as badges;
import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'Notification_page.dart';
import 'feedBack_page.dart';

class HomePage extends StatefulWidget {
  FarmerModel? farmerModel;
  ExtraModel? extraModel = ExtraModel();
  String? uid = '';

  HomePage(this.uid, this.extraModel, {super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  String selectedLanguage = 'English';
  List<Map<String, dynamic>> socialMediaData = [];

  AppLifecycleState? _notification;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  ExtraModel extraModel = ExtraModel();
  FarmerModel? farmerModel;
  List<FarmerModel> farmerList = [];
  int currentSliderIndex = 0;
  List<dynamic> namesList = [],
      categoriesList = [],
      doctorIdList = [],
      uniqueIdList = [];
  StreamSubscription<QuerySnapshot>? appointmentStream;
  bool isInternetConnected = false;
  bool englishSelected = false;
  bool punjabiSelected = false;
  bool hindiSelected = false;
  final List sideMenu = [
    {"0": "aboutUs", "1": "", "2": 8},
    {"0": "videos", "1": "", "2": 1},
    {"0": "feedBack", "1": "", "2": 12},
    {"0": "notifications", "1": "", "2": 0},
    {"0": "Information", "1": "", "2": 23},
    // {"0": "NonIntensiveForm", "1": "", "2": 0},
    {"0": "news", "1": "", "2": 0},
    // {"0": "gallery", "1": "", "2": 0},
    {"0": "reports", "1": "", "2": 0},
    {"0": "logout", "1": "", "2": 0, "3": Icons.exit_to_app},
  ];
  final List sideMenuIcon = [
    Icons.info_outline,
    Icons.video_collection,
    Icons.message,
    Icons.notifications_active,
    Icons.notes,
    // Icons.format_align_center,
    Icons.alarm,
    // Icons.browse_gallery,
    Icons.question_answer,
    Icons.exit_to_app,
  ];
  bool loading = false, isUserLogined = false;
  int selectedIndex = 0;
  String uid = '',
      farmerName = 'Loading...',
      farmerMobile = '',
      farmerImage = 'https://www.freeiconspng.com/uploads/no-image-icon-4.png',
      hintDoctorId = 'Search by Doctor Id';
  //States
  StateSetter? appointmentsState,
      patientDetailCardState,
      prescriptionState,
      emptyHomeState,
      schedulesState,
      sittingsState;
  DateFormat timeFormat = DateFormat("hh:mm a");
  List<String> strAppointmentList = [],
      strSlotIdList = [],
      familyMemberList = [];
  String strDropdownValue = '';
  MemberModel? memberModel;
  List<MemberModel> memberModelList = [];
  bool selectedMember = false;
  List<MemberModel> selectedMemberList = [];

  String? appVersion, buildNumber;
  var batch = FirebaseFirestore.instance.batch();
  StreamSubscription<RemoteMessage>? notificationMsgSub;

  int _logoIndex = 0;
  List<String> _logoImages = [
    'assets/main_logo.jpg',
    'assets/Splash.jpg', // Add more logo images here
  ];
  List<String> _logoText = [
    'Digital Farmer Hub',
    'CIPT', // Add more logo images here
  ];

  String get currentLogo => _logoImages[_logoIndex];
  String get currentLogoText => _logoText[_logoIndex];
  bool logoloading = true;
  late Timer _timer;

  ContentModel jsonToContentModel(Map<String, dynamic> json) {
    ContentModel model = ContentModel();
    model.title = json['title'] ?? '';
    model.content = json['content'] ?? '';
    model.imageUrl = json['imageUrl'] ?? '';
    model.author = json['author'] ?? '';
    model.youtubeLink = json['youtubeLink'] ?? '';
    model.pdfUrl = json['pdfUrl'] ?? '';
    model.status = json['status'] ?? true;
    model.impStatus = json['impStatus'] ?? false;
    model.sequence = json['sequence'] ?? 0;
    model.type = json['type'] ?? 0;
    model.imageList = json['imageList']?.cast<String>() ?? [];
    return model;
  }

  // final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = widget.uid!;
    extraModel = widget.extraModel!;
    farmerModel = widget.farmerModel;
    loading = true;
    initConnectyCube();
    setUpNotification();
    checkPermission();
    getUser(uid);
    _fetchSocialMediaData();
    // subscribeToTopicsContentDistrict(widget.farmerModel!.districtId!);
    getPackageInfo();
    // init();

    // Initialize timer to change logo and text every 3 seconds
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        // Toggle between logo images
        _logoIndex = (_logoIndex + 1) % _logoImages.length;
        // _logoIndex = (_logoIndex + 1) % _logoText.length;
      });
    });

  }

  @override
  void dispose() {
    notificationMsgSub?.cancel();
    _timer.cancel();
    super.dispose();
  }

  void init() async {
    context.read<ClientDBProvider>().getSliderData();
    context.read<ClientDBProvider>().getGalleryData();
    context.read<ClientDBProvider>().getNotificationData();
    context.read<ClientDBProvider>().getContentData();
    if (farmerModel != null && farmerModel!.districtId != null) {
      print('widget.farmerModel!.districtId is : ${farmerModel!.districtId!}');
      context.read<ClientDBProvider>().subscribeToTopicsContentDistrict(farmerModel!.districtId!);
    } else {
      print('Error: farmerModel or districtId is null');
    }
  }

  Future checkPermission() async {
    if (!await Permission.camera.isGranted) {
      await Permission.camera.request();
    }
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
    if (!await Permission.microphone.isGranted) {
      await Permission.storage.request();
    }
  }

  void getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  initConnectyCube() {
    String? APP_ID = extraModel.connectyCubeAPP_ID;
    String? AUTH_KEY = extraModel.connectyCubeAUTH_KEY;
    String? AUTH_SECRET = extraModel.connectyCubeAUTH_SECRET;
    String? ACCOUNT_ID = extraModel.connectyCubeACCOUNT_ID;
    String? DEFAULT_PASS = extraModel.connectyCubeDEFAULT_PASS;
  }

  void setUpNotification() async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: false,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      CommonFunctionClass.showPrint('data ${message.data}');
      CommonFunctionClass.showPrint('notification ${message.notification}');

      String body = "";
      if (message.data['body'] != null) {
        if (message.data['body'].toString().isNotEmpty) {
          body = message.data['body'];
        }
      }
      if (message.notification != null) {
        if (message.notification!.body!.isNotEmpty) {
          body = message.notification!.body!;
        }
      }

      if (body.isNotEmpty) {
        String title = message.notification?.title ?? "";
        String body = message.notification?.body ?? "";

        // Check if the message contains the required data for ContentModel
        if (message.data.containsKey('title') || message.data.containsKey('content')) {
        // if (message.data.containsKey('title') && message.data.containsKey('content')) {
          // Create ContentModel from message.data
          ContentModel contentModel = ContentModel();
          contentModel.title = message.data['title'];
          contentModel.content = message.data['content'];
          contentModel.imageUrl = message.data['imageUrl'];
          contentModel.status = message.data['status'] == 'true';  // Convert string to boolean
          contentModel.impStatus = message.data['impStatus'] == 'true';  // Convert string to boolean
          contentModel.sequence = int.tryParse(message.data['sequence'] ?? '0');
          contentModel.type = int.tryParse(message.data['type'] ?? '0');
          contentModel.author = message.data['author'];
          contentModel.youtubeLink = message.data['youtubeLink'];
          contentModel.youtubeLink = message.data['youtubeVideoId'];
          contentModel.pdfUrl = message.data['pdfUrl'];

          print('contentModel $contentModel');

          // Show the notification with the content model
          CommonFunctionClass.showTopModelNotification(title, body, context, contentModel);
        } else {
          // Show the notification without the content model
          CommonFunctionClass.showTopModelNotification2(title, body, context);
          print('contentModel notificationreport');
        }
      }
    });
  }

  getUser(uid) async {
    print('test: same Id user: ' + uid);
    FirebaseFirestore.instance
        .collection(users)
        .doc(uid)
        .snapshots()
        .listen((event) {
      setState(() {
        if (event.exists && event.data() != null) {
          farmerModel = FarmerModel.toObject(event.data()!);
          strDropdownValue = farmerModel!.farmerName!;
          farmerName = farmerModel!.farmerName!;
          farmerMobile = farmerModel!.phone!;
          loading = false;
          init();
        } else {
          // Handle the case where the document doesn't exist or has no data
          print("Document does not exist or has no data");
          loading = false;
        }
      });
    });
  }

  void updateFarmers() async {
    farmerModel?.farmerName = farmerModel?.farmerName.toString().toUpperCase();
    await FirebaseFirestore.instance
        .collection(prod)
        .doc(prod)
        .collection(users)
        .doc(farmerModel?.uid)
        .update(farmerModel!.getMap())
        .then((value) {
      // print('testVideoCall is : Document Updated');
    }).catchError((onError) {
      print('testVideoCall is :' +
          ' Document Update error : ' +
          onError.toString());
    });
  }

  Future<void> _fetchSocialMediaData() async {
    FirebaseFirestore.instance
        .collection('social-media')
        .orderBy("sequence", descending: true)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        socialMediaData = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
      // print("Social Media Data: $socialMediaData");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: setDrawer(context),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        leading: IconButton.filledTonal(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // CircleAvatar(
            //   backgroundImage: AssetImage('assets/main_logo.jpg'),
            //   radius: 25,
            // ),
            Image.asset(
              currentLogo,
              width: 70,
              height: 70,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${getTranslated(context, 'DigitalFarmerHub')}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  "${farmerModel?.farmerName ?? 'Unknown'}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton.filledTonal(
              onPressed: () async {
                // Call showModalBottomMenu and wait for the result
                final selected = await CommonFunctionClass.showModalBottomMenu(context, selectedLanguage);
                if (selected != null) {
                  setState(() {
                    selectedLanguage = selected; // Update the selected language
                  });
                }
              },
              icon: Icon(
                Icons.language_sharp,
                color: ThemeClass.colorPrimary,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[200],
        elevation: 12,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            getNavWidget(0, CupertinoIcons.home, "${getTranslated(context, 'Home')}", false),
            getNavWidget(1, CupertinoIcons.collections, "${getTranslated(context, 'videos')}", false),
            getNavWidget(2, CupertinoIcons.app_badge, "${getTranslated(context, 'Gallery')}", false),
            getNavWidget(3, CupertinoIcons.person_alt_circle, "${getTranslated(context, 'Profile')}", false),
            // getNavWidget(4, CupertinoIcons.cube_box, "Form", false),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 16.0,
                bottom: 5.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => SearchPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              var begin = Offset(1.0, 0.0);
                              var end = Offset.zero;
                              var curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(17.0),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 12.0),
                            Text(
                              "${getTranslated(context, 'Searchhere')}",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(17.0),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => SearchPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                var begin = Offset(1.0, 0.0);
                                var end = Offset.zero;
                                var curve = Curves.ease;

                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        icon: Icon(Icons.manage_search),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(0), // Ensuring no padding
              child: Column(
                children: [
                  StatefulBuilder(
                    builder: (BuildContext context,
                        void Function(void Function()) setState) {
                      List<SliderModel>? sliderModelList =
                          context.watch<ClientDBProvider>().sliderModelList;
                      if (sliderModelList!.isEmpty) {
                        return getImageSlide(-1, null);
                      }
                      return Container(
                          width: double.infinity, // Ensuring full width
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: CarouselSlider.builder(
                            options: CarouselOptions(
                              autoPlay: true,
                              onPageChanged: (index, _) {
                                currentSliderIndex = index;
                              },
                              viewportFraction: 1, // Full width for each item
                              enlargeCenterPage: false,
                              autoPlayInterval: const Duration(seconds: 4),
                            ),
                            itemCount: sliderModelList.length,
                            itemBuilder: (_, index, realIndex) {
                              return Container(
                                width: double.infinity, // Ensuring full width for the item
                                child: getImageSlide(index, sliderModelList[index]),
                              );
                            },
                          )
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 10.0,
                bottom: 0.0,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: SizedBox(
                      height: 160,
                      child: Card(
                        color: Colors.green.shade50,
                        elevation: 0.1,
                        shadowColor: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12), // Padding for the card content
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space between text and image
                            children: [
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${getTranslated(context, 'Freeconsultation')}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    Text(
                                        "${getTranslated(context, 'AssistanceforfarmersOurteamisheretohelp')}"),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return FeedBackPage(this.uid!, widget.extraModel!);
                                            },
                                          ),
                                        );
                                      },
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(11.0), // Adjust the value to reduce the border radius
                                          ),
                                        ),
                                      ),
                                      child: Text("${getTranslated(context, 'SendFeedback')}"),
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                'assets/ConsultLogo6.png',
                                width: 135,
                                height: 135,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              // padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 70.0),
              child: Column(
                children: [
                  SizedBox(height: 10), // Add some space between the text and the tabs
                  GridView.count(
                    crossAxisCount: 2, // Two items per row
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(), // Prevent the grid from scrolling
                    children: [
                      _buildTab(context, "${getTranslated(context, 'aboutUs')}", "assets/AboutUs2.jpg", AboutUsPage()),
                      _buildTab(context, "${getTranslated(context, 'UpcomingEvents')}", "assets/gallery.jpg", UpcomingEventsPage()),
                      _buildTab(context, " ${getTranslated(context, 'Information/Jankari')}", "assets/jankari.jpg", InformationPage()),
                      _buildTab(context, "${getTranslated(context, 'news')}", "assets/AboutDFH.jpg", NewsPage()),
                      // _buildTab(context, "Videos", "assets/news.jpg", Lectures()),
                      // _buildTab(context, "Gallery", "assets/AboutUs.jpeg", GalleryPage()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: socialMediaData.map((socialMedia) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: FloatingActionButton(
              onPressed: () {
                launch(socialMedia['link']);
              },
              backgroundColor: Colors.white, // Adjust color if needed
              mini: true,
              child: Image.network(
                socialMedia['imageUrl'],
                fit: BoxFit.cover,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget setDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(0),
        child: Stack(
          children: <Widget>[
            StatefulBuilder(
              builder: (BuildContext context, void Function(void Function()) setState) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(top: 26, bottom: 4),
                      margin: const EdgeInsets.only(top: 0, bottom: 0),
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return UserProfile(extraModel, farmerModel!, 1);
                              }));
                        },
                        child: Row(
                          children: [
                            Container(
                              child: getImageWidget(),
                              margin: const EdgeInsets.fromLTRB(16, 34, 16, 6),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(height: 30),
                                Text(
                                  farmerModel!.farmerName!,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  farmerModel!.phone!,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "${getTranslated(context, 'menu')}",
                        style: GoogleFonts.openSans(
                            fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ),
                    MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView.builder(
                        itemCount: sideMenu.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              if (index == 0) {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return AboutUsPage();
                                    }));
                              } else if (index == 1) {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return Lectures();
                                    }));
                              } else if (index == 2) {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return FeedBackPage(
                                          this.uid!, widget.extraModel!);
                                    }));
                              } else if (index == 3) {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return NotificationPage();
                                    }));
                              } else if (index == 4) {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return InformationPage();
                                    }));
                              } else if (index == 5) {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return NewsPage();
                                    }));
                              } else if (index == 6) {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return ReportPdf();
                                    }));
                              } else if (index == 7) {
                                logoutDialog();
                              }
                            },
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(0, 0, 16, 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25.0),
                                      color: Colors.white,
                                      border: Border.all(
                                        width: 1.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: Icon(
                                      sideMenuIcon[index],
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.only(left: 5.0)),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '${getTranslated(context, sideMenu[index]["0"])}',
                                        style: GoogleFonts.openSans(
                                            fontSize: 15, color: Colors.black),
                                      ),
                                      Text(
                                        sideMenu[index]["1"],
                                        style: GoogleFonts.openSans(
                                            fontSize: 11,
                                            color: Colors.grey.shade500),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (farmerModel!.isStaff!) // Your condition here
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                                return MyForm(farmerModel!);
                              }));
                        },
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0),
                                  color: Colors.white,
                                  border: Border.all(
                                    width: 1.5,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Icon(
                                  Icons.new_releases,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(left: 5.0)),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Non Intensive Form',
                                    style: GoogleFonts.openSans(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                  Text(
                                    'Add new Non Intensive Form',
                                    style: GoogleFonts.openSans(
                                        fontSize: 11, color: Colors.grey.shade500),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: StatefulBuilder(
                builder: (BuildContext context, void Function(void Function()) setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        alignment: Alignment.center,
                        child: Text(
                          appName,
                          style: GoogleFonts.openSans(
                              color: ThemeClass.colorPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 0, bottom: 10),
                        alignment: Alignment.center,
                        child: Text(
                          '"${getTranslated(context, 'version')}" $appVersion ($buildNumber)',
                          style: GoogleFonts.openSans(
                              color: Colors.black.withOpacity(0.2),
                              fontWeight: FontWeight.w600,
                              fontSize: 11),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  getNavWidget(
      int index,
      IconData iconData,
      String name,
      bool hideFlag,
      ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 4,
      child: InkWell(
        onTap: () {
          if (index == 0) {
            Navigator.push(
                context,
                CommonFunctionClass.pageRouteBuilder(
                    HomePage(farmerModel?.uid, extraModel)));
          } else if (index == 1) {
            Navigator.push(
                context,
                CommonFunctionClass.pageRouteBuilder(
                    Lectures()));
          } else if (index == 2) {
            Navigator.push(
                context,
                CommonFunctionClass.pageRouteBuilder(
                    GalleryPage()));
          } else if (index == 3) {
            Navigator.push(
                context,
                CommonFunctionClass.pageRouteBuilder(
                    UserProfile(extraModel, farmerModel!, 1)));
          } else if (index == 4) {
            Navigator.push(
                context,
                CommonFunctionClass.pageRouteBuilder(
                    MyForm(farmerModel!)));
          }
        },
        child: Container(
          height: 40,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      size: 22,
                      color: hideFlag ? Colors.transparent : Colors.green,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      name.toUpperCase(),
                      style: const TextStyle(color: Colors.black, fontSize: 10),
                    )
                  ],
                ),
              ),
              // if (index == 0) ...[
              //   StatefulBuilder(
              //     builder: (BuildContext context,
              //         void Function(void Function()) setState) {
              //       return const SizedBox(
              //         height: 40,
              //         width: 40,
              //         child: Align(
              //           alignment: Alignment.topRight,
              //           child: SizedBox(
              //             height: 10,
              //             width: 10,
              //             child: CircleAvatar(
              //               maxRadius: 10,
              //               backgroundColor: Colors.red,
              //             ),
              //           ),
              //         ),
              //       );
              //     },
              //   )
              // ]
            ],
          ),
        ),
      ),
    );
  }

  getImageSlide(int index, SliderModel? sliderModel) {
    if (index == -1) {
      return Container();
    } else {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      sliderModel!.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      filterQuality: FilterQuality.low,
                      // loadingBuilder: (context, child, loadingProgress) {
                      //   if (loadingProgress == null) {
                      //     return child;
                      //   } else {
                      //     return LoaderWidget();
                      //   }
                      // },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/ContactUs.png",
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(200, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  getImageWidget() {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(
          width: 1.5,
          color: Colors.black,
        ),
      ),
      child: const Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(0, 0),
            child: Icon(
              Icons.person,
              color: Colors.black,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.transparent,
              // backgroundImage: NetworkImage(patientImage),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("${getTranslated(context, 'areYouSureToLogout')}",
              style: TextStyle(color: Colors.black)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "${getTranslated(context, 'youWillGetSignOutOfTheAppAfterYouLogout')}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  "${getTranslated(context, 'wouldYouLikeToApproveThisMessage')}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("${getTranslated(context, 'notNow')}",
                  style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("${getTranslated(context, 'logout')}",
                  style: TextStyle(color: Colors.black)),
              onPressed: () {
                if (farmerModel != null && farmerModel!.districtId != null) {
                  print('unsubscribeToTopic Successfull : ${farmerModel!.districtId!}');
                  ClientDBProvider().unsubscribeToTopic(farmerModel!.districtId!);
                } else {
                  print('Error: unsubscribeToTopic districtId is null');
                }
                // ClientDBProvider().unsubscribeToTopic();
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return const MyHomePage(
                    title: '',
                  );
                }));
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTab(BuildContext context, String title, String imagePath, Widget destinationPage) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // Background Image
              Image.asset(
                imagePath, // Replace with your image path
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              // Opacity Layer
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
              // Text at Bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

}


