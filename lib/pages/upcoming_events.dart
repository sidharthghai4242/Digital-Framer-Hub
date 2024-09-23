import 'dart:async';

import 'package:digital_farmer_hub/pages/event_detailMain.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../helper/Constants.dart';
import '../helper/localization/language_constants.dart';
import 'AboutUs_page.dart';
import 'event_detail.dart';

class UpcomingEventsPage extends StatefulWidget {
  @override
  _UpcomingEventsPageState createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  final int _initialLimit = 20;
  final int _loadMoreLimit = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isLoading = true;
  List<DocumentSnapshot> _documents = [];
  ScrollController _scrollController = ScrollController();
  String _filter = 'all'; // 'all', 'past', 'future'
  StreamSubscription<QuerySnapshot>? _subscription;
  String selectedFilter = 'all'; // Track selected filter
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMoreData();
      }
    });
  }

  void _fetchInitialData() {
    setState(() {
      _isLoading = true;
    });

    Query query = FirebaseFirestore.instance.collection(contentCollection).where("type", isEqualTo: 4).where("status", isEqualTo: true);
    // Query query = FirebaseFirestore.instance.collection("publish-events");
    if (_filter == 'past') {
      query = query.where('date', isLessThan: DateTime.now().toIso8601String());
    } else if (_filter == 'future') {
      query = query.where('date', isGreaterThan: DateTime.now().toIso8601String());
    }

    _subscription?.cancel();
    _subscription = query.limit(_initialLimit).snapshots().listen((querySnapshot) {
      setState(() {
        _documents = querySnapshot.docs;
        _hasMore = querySnapshot.docs.length == _initialLimit;
        _isLoading = false;
      });
    }, onError: (e) {
      print('Error fetching initial data: $e');
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMore || _documents.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    Query query = FirebaseFirestore.instance.collection('publish-events');
    if (_filter == 'past') {
      query = query.where('date', isLessThan: DateTime.now().toIso8601String());
    } else if (_filter == 'future') {
      query = query.where('date', isGreaterThan: DateTime.now().toIso8601String());
    }

    try {
      QuerySnapshot querySnapshot = await query
          .startAfterDocument(_documents.last)
          .limit(_loadMoreLimit)
          .get();

      setState(() {
        _documents.addAll(querySnapshot.docs);
        _isLoadingMore = false;
        _hasMore = querySnapshot.docs.length == _loadMoreLimit;
      });
    } catch (e) {
      print('Error loading more data: $e');
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _filter = filter;
      selectedFilter = filter; // Update selected filter
      _documents = [];
      _hasMore = true;
      _isLoading = true;
    });
    _fetchInitialData();
  }

  Future<String> getFeedbackQuestion() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('feedBackQuestion')
          .doc('feedBackQuestion')
          .get();
      if (snapshot.exists) {
        var feedbackData = snapshot.data();
        if (feedbackData != null && feedbackData.containsKey('eventfeedback')) {
          List<dynamic> infoFeedbackList = feedbackData['eventfeedback'];
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

  Future<void> incrementFeedbackCount(String uid, BuildContext context, String title, String content, DateTime date, List<String> imageList) async {
    final userDocRef = FirebaseFirestore.instance.collection(users).doc(uid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userDoc = await transaction.get(userDocRef);
      if (userDoc.exists) {
        final currentCount = userDoc.data()?['eventfeedback'] ?? 0;
        final newCount = currentCount + 1;
        transaction.update(userDocRef, {'eventfeedback': newCount});

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
                          builder: (context) => EventPage(
                            title: title,
                            content: content,
                            date: date,
                            imageList: imageList,
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
                          builder: (context) => EventPage(
                            title: title,
                            content: content,
                            date: date,
                            imageList: imageList,
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
              builder: (context) => EventPage(
                title: title,
                content: content,
                date: date,
                imageList: imageList,
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
          if (feedbackData != null && feedbackData.containsKey('eventfeedback')) {
            List<dynamic> infoFeedbackList = feedbackData['eventfeedback'];
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
            transaction.update(docRef, {'eventfeedback': infoFeedbackList});
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
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          '${getTranslated(context, 'UpcomingEvents')}',
          style: TextStyle(color: Colors.green),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0, // Remove the shadow
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: selectedFilter == 'all' ? Colors.green : Colors.white, // Background color
                  borderRadius: BorderRadius.circular(8.0), // Border radius
                ),
                child: TextButton(
                  onPressed: () => _applyFilter('all'),
                  child: Text(
                    '${getTranslated(context, 'AllEvents')}',
                    style: TextStyle(color: selectedFilter == 'all' ? Colors.white : Colors.black), // Text color
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: selectedFilter == 'past' ? Colors.green : Colors.white, // Background color
                  borderRadius: BorderRadius.circular(15.0), // Border radius
                ),
                child: TextButton(
                  onPressed: () => _applyFilter('past'),
                  child: Text(
                    '${getTranslated(context, 'PastEvents')}',
                    style: TextStyle(color: selectedFilter == 'past' ? Colors.white : Colors.black), // Text color
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric( vertical: 8.0),
                decoration: BoxDecoration(
                  color: selectedFilter == 'future' ? Colors.green : Colors.white, // Background color
                  borderRadius: BorderRadius.circular(15.0), // Border radius
                ),
                child: TextButton(
                  onPressed: () => _applyFilter('future'),
                  child: Text(
                    '${getTranslated(context, 'FutureEvents')}',
                    style: TextStyle(color: selectedFilter == 'future' ? Colors.white : Colors.black), // Text color
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : (_documents.isEmpty && !_isLoading)
                ? Center(child: Text('No events found.'))
                : GridView.builder(
              controller: _scrollController,
              itemCount: _documents.length + (_isLoadingMore ? 1 : 0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 5.0,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                if (index == _documents.length) {
                  return Center(child: CircularProgressIndicator());
                }

                DocumentSnapshot doc = _documents[index];
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                String imageUrl = data['imageUrl'] != null
                    ? data['imageUrl'] as String
                    : 'https://via.placeholder.com/150'; // Placeholder URL if url is null
                List<String> imageList = (data['imageList'] != null)
                    ? List<String>.from(data['imageList'])
                    : ['https://via.placeholder.com/150']; // Placeholder URL if imageList is null
                String title = data['title'] ?? 'Untitled Event';
                String content =
                    data['content'] ?? 'No description available';
                DateTime date = (data['date'] != null)
                    ? DateTime.tryParse(data['date'] as String) ?? DateTime.now()
                    : DateTime.now();
                bool isImportant = data['impStatus'] == true;

                return GestureDetector(
                  // onTap: () {
                  //   showDialog(
                  //     context: context,
                  //     builder: (BuildContext context) {
                  //       return EventDetail(
                  //         title: title,
                  //         content: content,
                  //         date: date,
                  //         imageList: imageList,
                  //       );
                  //     },
                  //   );
                  // },
                  onTap: () async {
                    if (_auth.currentUser != null) {
                      await incrementFeedbackCount(_auth.currentUser!.uid, context, title, content, date, imageList);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventPage(
                            title: title,
                            content: content,
                            date: date,
                            imageList: imageList,
                          ),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: (isImportant && date.isAfter(DateTime.now())) ? Border.all(color: Colors.red, width: 2.0) : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.0)),
                            child: Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 16.0,
                              bottom: 10.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  DateFormat('MMM d, yyyy').format(date),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (isImportant && date.isAfter(DateTime.now()))
                                  Text(
                                    '${getTranslated(context, 'Importantevent')}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }
}
