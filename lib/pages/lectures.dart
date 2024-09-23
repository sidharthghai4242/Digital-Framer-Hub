import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_farmer_hub/helper/theme_class.dart';
import 'package:digital_farmer_hub/pages/lecturesPlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helper/Constants.dart';
import '../helper/localization/language_constants.dart';
import '../models/FarmerModel.dart';

class Lectures extends StatefulWidget {
  const Lectures({super.key});

  @override
  State<Lectures> createState() => _LecturesState();
}

class _LecturesState extends State<Lectures> {
  bool loading = true;
  List<dynamic>? classLectureModelList;
  FarmerModel farmerModel = FarmerModel();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    getLectureVideos();
    checkUser();
    super.initState();
  }

  Future<void> checkUser() async {
    final User? user = await _auth.currentUser;
    if (user != null) {
      await getUser(user.uid);
    }
  }

  Future<void> getUser(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(users)
          .where('uid', isEqualTo: uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        print(snapshot.docs[0].data());
        farmerModel = FarmerModel.toObject(snapshot.docs[0].data())!;
      }
    } catch (e, stacktrace) {
      print('Error: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }
  }

  void getLectureVideos() async {
    var docRef = await FirebaseFirestore.instance
        .collection(contentCollection)
        .where("type", isEqualTo: 0)
        .orderBy('createdOn', descending: true)
        .get();
    setState(() {
      classLectureModelList = docRef.docs.map((doc) => doc.data()).toList();
      loading = false;
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
        if (feedbackData != null && feedbackData.containsKey('videofeedback')) {
          List<dynamic> videoFeedbackList = feedbackData['videofeedback'];
          if (videoFeedbackList.isNotEmpty && videoFeedbackList[0].containsKey('question')) {
            return videoFeedbackList[0]['question'];
          }
        }
      }
    } catch (e, stacktrace) {
      print('Error: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }
    return 'Have you ever used a mobile app for farming activities?'; // Default question
  }

  Future<void> incrementFeedbackCount(String uid, BuildContext context, String videoId) async {
    final userDocRef = FirebaseFirestore.instance.collection(users).doc(uid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userDoc = await transaction.get(userDocRef);
      if (userDoc.exists) {
        final currentCount = userDoc.data()?['feedbackCount'] ?? 0;
        final newCount = currentCount + 1;
        transaction.update(userDocRef, {'feedbackCount': newCount});

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
                          content: Text("Thank you for your response. Please continue watching the video."),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      // Update 'yes' count in Firestore
                      await updateFeedbackCount(feedbackQuestion, true);
                      // Navigate to LecturePlay after closing the modal
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LecturePlay(videoId: videoId)),
                      );
                    },
                  ),
                  TextButton(
                    child: Text("No"),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Thank you for your response. Please continue watching the video."),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      // Update 'no' count in Firestore
                      await updateFeedbackCount(feedbackQuestion, false);
                      // Navigate to LecturePlay after closing the modal
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LecturePlay(videoId: videoId)),
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
            MaterialPageRoute(builder: (context) => LecturePlay(videoId: videoId)),
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
          if (feedbackData != null && feedbackData.containsKey('videofeedback')) {
            List<dynamic> videoFeedbackList = feedbackData['videofeedback'];
            for (var feedback in videoFeedbackList) {
              if (feedback['question'] == question) {
                if (isYes) {
                  feedback['yes'] = (feedback['yes'] ?? 0) + 1;
                } else {
                  feedback['no'] = (feedback['no'] ?? 0) + 1;
                }
                break;
              }
            }
            transaction.update(docRef, {'videofeedback': videoFeedbackList});
          }
        }
      });
    } catch (e, stacktrace) {
      print('Error: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }
  }

  String formatDate(Timestamp timestamp) {
    return DateFormat('yMMMd').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Text(
          "${getTranslated(context, 'OurVideos')}",
          style: TextStyle(
            color: ThemeClass.colorPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(10),
        children: List.generate(
          classLectureModelList!.length,
              (index) {
            String videoId = classLectureModelList![index]['youtubeVideoId'];
            String thumbnailUrl = "https://img.youtube.com/vi/$videoId/0.jpg";
            Timestamp uploadTimestamp = classLectureModelList![index]['createdOn'];
            String uploadDate = formatDate(uploadTimestamp);

            return Container(
              width: 250,
              margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
              child: InkWell(
                onTap: () async {
                  if (_auth.currentUser != null) {
                    await incrementFeedbackCount(_auth.currentUser!.uid, context, videoId);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LecturePlay(videoId: videoId)),
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        thumbnailUrl,
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        classLectureModelList![index]['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0.0),
                      child: Row(
                        children: [
                          Icon(Icons.date_range, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            'Uploaded on $uploadDate',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
