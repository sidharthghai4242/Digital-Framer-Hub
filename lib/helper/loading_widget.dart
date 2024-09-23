import 'package:digital_farmer_hub/helper/theme_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.only(top: 20),
        height: 40,
        width: 40,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
              strokeWidth: 2,
              valueColor: new AlwaysStoppedAnimation<Color>(ThemeClass.colorPrimary),
            ),
          ),
        ),
      ),
    );
  }
}