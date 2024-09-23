import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helper/theme_class.dart';
import '../provider/client_db_provider.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // init();
  }

  void init() async {
    // context.read<ClientDBProvider>().getSliderData();
    // context.read<ClientDBProvider>().getGalleryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Our Videos',
          style: TextStyle(
            color: ThemeClass.colorPrimary, // Set the color of the AppBar title
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Set the AppBar background color
      ),
    );
  }
}
