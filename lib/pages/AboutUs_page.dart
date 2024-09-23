import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper/Constants.dart';
import '../helper/localization/language_constants.dart';
import '../helper/theme_class.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  DocumentSnapshot? _document;
  List<Map<String, dynamic>> socialMediaData = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _fetchSocialMediaData();
  }

  Future<void> _fetchInitialData() async {
    FirebaseFirestore.instance
        .collection(aboutUSCollection)
        .doc('aboutUs')
        .snapshots()
        .listen((documentSnapshot) {
      setState(() {
        _document = documentSnapshot;
      });
      if (documentSnapshot.exists) {
        Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
        // print("Document data: $data");
      } else {
        print("No document found with ID 'aboutUs'");
      }
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
    String content = 'Loading...';
    String imageUrl = 'https://via.placeholder.com/150';

    if (_document != null && _document!.exists) {
      Map<String, dynamic> data = _document!.data() as Map<String, dynamic>;
      content = data['content'] ?? 'No content available';
      imageUrl = data['imageUrl'] ?? 'https://via.placeholder.com/150';
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "${getTranslated(context, 'aboutUs')}",
          style: TextStyle(
            color: ThemeClass.colorPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0), // Set the border radius
                child: Image.network(
                  imageUrl,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover, // Ensure the image covers the entire area
                ),
              ),
            ),
            const SizedBox(height: 20),
            HtmlWidget(
              content,
              textStyle: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: socialMediaData.map((socialMedia) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
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
}
