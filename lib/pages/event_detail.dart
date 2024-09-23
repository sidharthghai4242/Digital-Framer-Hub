import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EventDetail extends StatelessWidget {
  final String title;
  final String content;
  final DateTime date;
  final List<String> imageList;

  EventDetail({
    required this.title,
    required this.content,
    required this.date,
    required this.imageList,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: EdgeInsets.all(20.0),
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 200,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 1.0,
                          aspectRatio: 2.0,
                        ),
                        items: imageList.map((imageUrl) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    Positioned(
                      right: 3,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5), // Opaque background color
                        ),
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.white), // White icon for better visibility
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  DateFormat('MMM d, yyyy').format(date),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 10),
                HtmlWidget(
                  content,
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
