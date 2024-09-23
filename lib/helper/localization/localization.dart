import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../CommonFunctions.dart';

class DemoLocalization {

  Map<dynamic, dynamic> _localizedValues = {};
  final Locale locale;

  DemoLocalization(this.locale);

  static DemoLocalization? of(BuildContext context) {
    return Localizations.of<DemoLocalization>(context, DemoLocalization);
  }


  Future<void> load(languageCode) async {
    // CommonFunctionClass.showPrint('test language----------:'+locale.languageCode);
    String jsonStringValues = await rootBundle
        .loadString('lib/helper/lang/$languageCode.json');
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String? translate(String key) {
    return _localizedValues[key];
  }

  // static member to have simple access to the delegate from Material App
  static const LocalizationsDelegate<DemoLocalization> delegate =
  _DemoLocalizationsDelegate();

  static DemoLocalization? get instance =>
      _DemoLocalizationsDelegate.instance; // add this

}

class _DemoLocalizationsDelegate
    extends LocalizationsDelegate<DemoLocalization> {
  const _DemoLocalizationsDelegate();
  static DemoLocalization? instance;
  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'pa'].contains(locale.languageCode);
  }

  @override
  Future<DemoLocalization> load(Locale locale) async {
    DemoLocalization localization = DemoLocalization(locale);
    await localization.load(locale.languageCode);
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<DemoLocalization> old) => false;
}