import 'package:digital_farmer_hub/helper/theme_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AppColors.dart';

class LoaderWidget extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        height: 40,
        width: 40,
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(ThemeClass.colorPrimaryLight),
          ),
        ),
      ),
    );
  }
}
