import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';
import '../helper/Constants.dart';
import '../helper/localization/language_constants.dart';
import '../helper/theme_class.dart';
import '../models/GalleryModel.dart';
import '../models/SliderModel.dart';// Replace with correct path to your model

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
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
        .collection(galleryCollection)
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
        .collection(galleryCollection)
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

  void _openImageViewer(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewer(
          images: _documents.map((doc) {
            GalleryModel galleryItem = GalleryModel.toObject(doc);
            return galleryItem.imageUrl;
          }).toList(),
          initialIndex: initialIndex,
        ),
      ),
    );
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
        automaticallyImplyLeading: true,
        title: Text(
          '${getTranslated(context, 'Gallery')}',
          style: TextStyle(
            color: ThemeClass.colorPrimary, // Example: Set the color of the AppBar title
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Example: Set the AppBar background color
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!_isLoadingMore &&
              scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
            _loadMoreData();
            return true;
          }
          return false;
        },
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.75,
          ),
          itemCount: _documents.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (index == _documents.length) {
              return Center(child: CircularProgressIndicator());
            }

            DocumentSnapshot doc = _documents[index];
            GalleryModel galleryItem = GalleryModel.toObject(doc);

            return GestureDetector(
              onTap: () => _openImageViewer(context, index),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          galleryItem.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          // loadingBuilder: (context, child, progress) {
                          //   return progress == null
                          //       ? child
                          //       : Center(
                          //     child: CircularProgressIndicator(
                          //       value: progress.expectedTotalBytes != null
                          //           ? progress.cumulativeBytesLoaded /
                          //           progress.expectedTotalBytes!
                          //           : null,
                          //     ),
                          //   );
                          // },
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              return child;
                            } else {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  color: Colors.white,
                                ),
                              );
                            }
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Center(child: Icon(Icons.error)),
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
    );
  }

}

class ImageViewer extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  ImageViewer({required this.images, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: images.length,
            pageController: PageController(initialPage: initialIndex),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(images[index]),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: images[index]),
              );
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),  // Light black with 70% opacity
            ),
            loadingBuilder: (context, progress) {
              return Center(
                child: CircularProgressIndicator(
                  value: progress == null
                      ? null
                      : progress.cumulativeBytesLoaded /
                      (progress.expectedTotalBytes ?? 1),
                ),
              );
            },
          ),
          Positioned(
            top: 50,
            left: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

