import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_farmer_hub/pages/Information_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helper/Constants.dart';
import '../helper/localization/language_constants.dart';
import '../helper/theme_class.dart';

  class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final int _initialLimit = 20;
  final int _loadMoreLimit = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isLoading = true;
  List<DocumentSnapshot> _documents = [];
  ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          _hasMore &&
          !_isLoadingMore) {
        _loadMoreData();
      }
    });
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
    });

    FirebaseFirestore.instance
        .collection(contentCollection)
        .where("type", isEqualTo: 2)
        .where("status", isEqualTo: true)
        .orderBy('createdOn', descending: true)
        .limit(_initialLimit)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        _documents = querySnapshot.docs;
        _hasMore = querySnapshot.docs.length == _initialLimit;
        _isLoading = false;
      });
    });
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('information')
        .where("type", isEqualTo: 2)
        .where("status", isEqualTo: true)
        .orderBy('createdOn', descending: true)
        .startAfterDocument(_documents.last)
        .limit(_loadMoreLimit)
        .get();

    setState(() {
      _documents.addAll(querySnapshot.docs);
      _isLoadingMore = false;
      _hasMore = querySnapshot.docs.length == _loadMoreLimit;
    });
  }

  Future<String> getFeedbackQuestion() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('feedBackQuestion')
          .doc('feedBackQuestion')
          .get();
      if (snapshot.exists) {
        var feedbackData = snapshot.data();
        if (feedbackData != null && feedbackData.containsKey('informationfeedback')) {
          List<dynamic> infoFeedbackList = feedbackData['informationfeedback'];
          if (infoFeedbackList.isNotEmpty && infoFeedbackList[0].containsKey('question')) {
            return infoFeedbackList[0]['question'];
          }
        }
      }
    } catch (e, stacktrace) {
      print('Error: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }
    return 'Have you ever used a mobile app for farming activities?'; // Default question
  }

  Future<void> incrementFeedbackCount(String uid, BuildContext context, String title, String content, String imageUrl, DateTime createdOn) async {
    final userDocRef = FirebaseFirestore.instance.collection(users).doc(uid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userDoc = await transaction.get(userDocRef);
      if (userDoc.exists) {
        final currentCount = userDoc.data()?['informationfeedback'] ?? 0;
        final newCount = currentCount + 1;
        transaction.update(userDocRef, {'informationfeedback': newCount});

        if (newCount == 4) {
          // Fetch the feedback question from Firestore
          String feedbackQuestion = await getFeedbackQuestion();

          // Show the modal popup with the fetched question
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Feedback"),
                content: Text(feedbackQuestion),
                actions: <Widget>[
                  TextButton(
                    child: Text("Yes"),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Thank you for your response. Please continue Reading."),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      // Update 'yes' count in Firestore
                      await updateFeedbackCount(feedbackQuestion, true);
                      Navigator.push(
                        context,
                          MaterialPageRoute(
                            builder: (context) => InformationDetail(
                              title: title,
                              content: content,
                              imageUrl: imageUrl,
                              createdOn: createdOn,
                            ),
                          ),
                      );
                    },
                  ),
                  TextButton(
                    child: Text("No"),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Thank you for your response. Please continue Reading."),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      // Update 'no' count in Firestore
                      await updateFeedbackCount(feedbackQuestion, false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InformationDetail(
                            title: title,
                            content: content,
                            imageUrl: imageUrl,
                            createdOn: createdOn,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // Navigate to LecturePlay if feedbackCount is not 4
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InformationDetail(
                title: title,
                content: content,
                imageUrl: imageUrl,
                createdOn: createdOn,
              ),
            ),
          );
        }
      }
    });
  }

  Future<void> updateFeedbackCount(String question, bool isYes) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('feedBackQuestion')
          .doc('feedBackQuestion');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          var feedbackData = snapshot.data();
          if (feedbackData != null && feedbackData.containsKey('informationfeedback')) {
            List<dynamic> infoFeedbackList = feedbackData['informationfeedback'];
            for (var feedback in infoFeedbackList) {
              if (feedback['question'] == question) {
                if (isYes) {
                  feedback['yes'] = (feedback['yes'] ?? 0) + 1;
                } else {
                  feedback['no'] = (feedback['no'] ?? 0) + 1;
                }
                break;
              }
            }
            transaction.update(docRef, {'informationfeedback': infoFeedbackList});
          }
        }
      });
    } catch (e, stacktrace) {
      print('Error: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '${getTranslated(context, 'Information')}',
          style: TextStyle(
            color: ThemeClass.colorPrimary, // Set the color of the AppBar title
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Set the AppBar background color
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _scrollController,
        itemCount: _documents.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _documents.length) {
            return Center(child: CircularProgressIndicator());
          }

          DocumentSnapshot doc = _documents[index];
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          String content = data['content'] ?? 'No content available';
          String imageUrl = data['imageUrl'] ?? 'https://via.placeholder.com/150';
          String informationId = data['informationId'] ?? '';
          String title = data['title'] ?? 'Untitled';
          Timestamp timestamp = data['createdOn'] as Timestamp;
          DateTime createdOn = timestamp.toDate();

          return GestureDetector(
            onTap: () async {
              if (_auth.currentUser != null) {
                await incrementFeedbackCount(_auth.currentUser!.uid, context, title, content, imageUrl, createdOn);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InformationDetail(
                      title: title,
                      content: content,
                      imageUrl: imageUrl,
                      createdOn: createdOn,
                    ),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(
                left: 18.0,
                right: 18.0,
                top: 20.0,
                bottom: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  // border: Border(
                  //   bottom: BorderSide(color: Colors.grey.shade300),
                  // ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16),bottom: Radius.circular(16)),
                      child: Stack(
                        children: [
                          Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.black.withOpacity(0.3),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: null,  // No limit on lines
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
