import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<T?> showTopModalSheet<T>(BuildContext context, Widget child, {bool barrierDismissible = true}) {
  return showGeneralDialog<T?>(
    context: context,
    barrierDismissible: barrierDismissible,
    transitionDuration: const Duration(milliseconds: 250),
    barrierLabel: MaterialLocalizations.of(context).dialogLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    pageBuilder: (context, _, __) => SafeArea(
      child: child,
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)
            .drive(Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [child],
              ),
            ),
          ],
        ),
      );
    },
  );
}

bool isWeb() {
  // Implement this function to check if the app is running on the web.
  // Return true if running on the web, otherwise false.
  return false;
}