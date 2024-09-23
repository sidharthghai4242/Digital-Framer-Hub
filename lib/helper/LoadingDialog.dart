import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'AppColors.dart';
import 'package:digital_farmer_hub/helper/theme_class.dart';

class LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.white,
        valueColor: new AlwaysStoppedAnimation<Color>(ThemeClass.colorPrimaryLight),
      ),
    );
  }

  static showLoadingDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: LoadingDialog(),
          );
        });
  }

  static stopLoadingDialog(BuildContext context){
    Navigator.pop(context);
  }

}