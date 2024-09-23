import '../helper/CommonFunctions.dart';

class ExtraModel {
  int? userAppAndroidVersion, userAppIosVersion;
  String? termsAndConditionsUrl;
  String? connectyCubeAPP_ID,
      connectyCubeAUTH_KEY,
      connectyCubeAUTH_SECRET,
      connectyCubeACCOUNT_ID,
      connectyCubeDEFAULT_PASS;
  List<AvailableCountryModel>? availableCountryList;

  static ExtraModel toObject(doc) {
    ExtraModel model = ExtraModel();

    model.userAppAndroidVersion = doc['userAppAndroidVersion'];
    model.userAppIosVersion = doc['userAppIosVersion'];
    model.termsAndConditionsUrl = doc['termsAndConditionsUrl'];
    model.connectyCubeAPP_ID = doc['connectyCubeAPP_ID'];
    model.connectyCubeAUTH_KEY = doc['connectyCubeAUTH_KEY'];
    model.connectyCubeAUTH_SECRET = doc['connectyCubeAUTH_SECRET'];
    model.connectyCubeACCOUNT_ID = doc['connectyCubeACCOUNT_ID'];
    model.connectyCubeDEFAULT_PASS = doc['connectyCubeDEFAULT_PASS'];
    model.availableCountryList = [];
    for (var element in doc['availableCountryList']) {
      CommonFunctionClass.showPrint('$element');
      model.availableCountryList!.add(AvailableCountryModel.toObject(element));
    }
    CommonFunctionClass.showPrint('${model.availableCountryList}');
    return model;
  }

  // Map<String, Object> getMap() {
  //   Map<String, Object> map = Map();
  //
  //   map['userAppAndroidVersion'] = userAppAndroidVersion ?? "";
  //   map['userAppIosVersion'] = userAppIosVersion ?? "";
  //   return map;
  // }

  @override
  String toString() {
    return 'Extra{userAppAndroidVersion: $userAppAndroidVersion, userAppIosVersion: $userAppIosVersion}';
  }
}

class AvailableCountryModel {
  String? code, name;

  static AvailableCountryModel toObject(doc) {
    AvailableCountryModel model = AvailableCountryModel();

    model.code = doc['code'];
    model.name = doc['name'];

    return model;
  }

  Map<String, Object?> getMap() {
    Map<String, Object?> map = Map();

    map['code'] = code;
    map['name'] = name;
    return map;
  }

  @override
  String toString() {
    return 'AvailableCountryModel{code: $code, name: $name}';
  }
}