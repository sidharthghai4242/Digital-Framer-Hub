import 'package:flutter/material.dart';

class EventSkeletonLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 0.0,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40, // Adjust the height based on your design
                          decoration: BoxDecoration(
                            color: Colors.grey[300], // Adjust color as needed
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Container(
                          height: 40, // Adjust the height based on your design
                          width: 40, // Adjust the width based on your design
                          decoration: BoxDecoration(
                            color: Colors.grey[300], // Adjust color as needed
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 160,
                  child: Card(
                    color: Colors.grey[200], // Adjust color as needed
                    elevation: 0.1,
                    shadowColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 24, // Adjust height based on your design
                                  width: double.infinity, // Adjust width based on your design
                                  color: Colors.grey[300], // Adjust color as needed
                                ),
                                SizedBox(height: 8), // Adjust spacing based on your design
                                Container(
                                  height: 40, // Adjust height based on your design
                                  width: double.infinity, // Adjust width based on your design
                                  color: Colors.grey[300], // Adjust color as needed
                                ),
                                SizedBox(height: 12), // Adjust spacing based on your design
                                Container(
                                  height: 36, // Adjust height based on your design
                                  width: 120, // Adjust width based on your design
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300], // Adjust color as needed
                                    borderRadius: BorderRadius.circular(11.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12), // Adjust spacing based on your design
                          Container(
                            width: 150, // Adjust width based on your design
                            color: Colors.grey[300], // Adjust color as needed
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverGrid(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Adjust color as needed
                  borderRadius: BorderRadius.circular(10.0),
                ),
              );
            },
            childCount: 6, // Adjust based on your design
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 5.0,
            childAspectRatio: 0.75,
          ),
        ),
      ],
    );
  }
}
