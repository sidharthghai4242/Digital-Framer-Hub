import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'localization.dart';

const String LAGUAGE_CODE = 'languageCode';

//languages code
const String ENGLISH = 'en';
const String HINDI = 'hi';
const String PUNJABI = 'pa';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "en";
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  // print('test lang 6:'+languageCode.toString());
  switch (languageCode) {
    case ENGLISH:
      return const Locale(ENGLISH, 'US');
    case HINDI:
      return const Locale(HINDI, "IN");
    case PUNJABI:
      return const Locale(PUNJABI, "IN");

    default:
      return const Locale(ENGLISH, 'US');
  }
}

String? getTranslated(BuildContext context, String key) {
  return DemoLocalization.of(context)?.translate(key);
}

String? translateWithoutContext(String key) {
  return DemoLocalization.instance?.translate(key);
}