import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';

class InformationDetail extends StatelessWidget {
  final String title;
  final String content;
  final String imageUrl;
  final DateTime createdOn;

  const InformationDetail({
    Key? key,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.createdOn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(10.0)),
                  child: AspectRatio(
                    aspectRatio: 10 / 9, // Adjust this as needed
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.scaleDown, // Ensures the image scales down to fit within the space
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        DateFormat('MMM d, yyyy').format(createdOn),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 20),
                      HtmlWidget(
                        content,
                        textStyle: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 3,
            top: 40, // Adjust as needed for better positioning
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
    );
  }
}
