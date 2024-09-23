import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_farmer_hub/pages/AboutUs_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helper/Constants.dart';
import '../helper/localization/language_constants.dart';
import '../helper/theme_class.dart';
import 'Pdf_viewer.dart';

class ReportPdf extends StatefulWidget {
  const ReportPdf({super.key});

  @override
  State<ReportPdf> createState() => _ReportPdfState();
}

class _ReportPdfState extends State<ReportPdf> {
  final int _initialLimit = 20;
  final int _loadMoreLimit = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isLoading = true;
  List<DocumentSnapshot> _documents = [];
  ScrollController _scrollController = ScrollController();

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
        .where("type", isEqualTo: 1)
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
        .collection(contentCollection)
        .where("type", isEqualTo: 1)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: true,
          title: Text(
            '${getTranslated(context, 'ourReports')}',
            style: TextStyle(
              color: ThemeClass.colorPrimary,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
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

          String pdfUrl = data['pdfUrl'] ?? 'No content available';
          String imageUrl = data['imageUrl'] ?? 'https://via.placeholder.com/150';
          String reportId = data['reportId'] ?? '';
          String title = data['title'] ?? 'Untitled';
          Timestamp timestamp = data['createdOn'] as Timestamp;
          DateTime createdOn = timestamp.toDate();

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewer(
                    title: title,
                    pdfUrl: pdfUrl,
                  ),
                ),
              );
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

// import 'package:flutter/material.dart';
//
// class ReportPdf extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Cake List'),
//         ),
//         body: CakeListPage(),
//     );
//   }
// }
//
// class CakeListPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: cakes.length,
//       itemBuilder: (context, index) {
//         return CakeCard(cake: cakes[index]);
//       },
//     );
//   }
// }
//
// class CakeCard extends StatelessWidget {
//   final Cake cake;
//
//   CakeCard({required this.cake});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.5),
//               spreadRadius: 2,
//               blurRadius: 5,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(16),bottom: Radius.circular(16)),
//               child: Stack(
//                 children: [
//                   Image.network(
//                     cake.imageUrl,
//                     width: double.infinity,
//                     height: 200,
//                     fit: BoxFit.cover,
//                   ),
//                   Container(
//                     width: double.infinity,
//                     height: 200,
//                     color: Colors.black.withOpacity(0.3),
//                   ),
//                   Positioned(
//                     bottom: 10,
//                     left: 10,
//                     child: Container(
//                       // color: Colors.black54,
//                       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       child: Text(
//                         cake.title,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class Cake {
//   final String imageUrl;
//   final String title;
//   final String subtitle;
//
//   Cake({
//     required this.imageUrl,
//     required this.title,
//     required this.subtitle,
//   });
// }
//
// List<Cake> cakes = [
//   Cake(
//     imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRLUa-ZRKO7w4xwD70vbLeBa3S0s39vnhpJWg&s',
//     title: '8 Easy Cakes You Can Bake At Home',
//     subtitle: 'India Today · 1w',
//   ),
//   Cake(
//     imageUrl: 'https://agrierp.com/blog/wp-content/uploads/2022/03/Apps-for-Farmers.jpg',
//     title: '8 Easy Cakes You Can Bake At Home',
//     subtitle: 'India Today · 1w',
//   ),
// ];

