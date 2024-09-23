import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'ExtraModel.dart';

class FarmerModel {
  String? uid,
      blockId,
      regionId,
      tehsilId,
      farmerName,
      fatherName,
      phone,
      districtName,
      villageName,
      token,
      platform,
      connectyLogin,
      districtId,
      connectyPassword,
      profileImage;
    // int? connectyId;
  Timestamp? date, loginDate;
  // List<dynamic> subscriptionArray = [];
  int? feedbackCount, loginType;
  bool? isStaff;
  AvailableCountryModel? countryModel;

  static FarmerModel toObject(doc) {
    FarmerModel farmerModel = FarmerModel();

    farmerModel.profileImage = doc['profileImage'];
    farmerModel.token = doc['token'];
    farmerModel.platform = doc['platform'];
    farmerModel.uid = doc['uid'];
    farmerModel.blockId = doc['blockId'];
    farmerModel.regionId = doc['blockId'];
    farmerModel.tehsilId = doc['blockId'];
    farmerModel.farmerName = doc['farmerName'];
    farmerModel.fatherName = doc['fatherName'];
    farmerModel.districtName = doc['districtName'];
    farmerModel.villageName = doc['villageName'];
    farmerModel.phone = doc['phone'];
    farmerModel.date = doc['date'];
    farmerModel.loginDate = doc['loginDate'];
    farmerModel.districtId = doc['districtId'];
    farmerModel.connectyLogin = doc['connectyLogin'];
    farmerModel.connectyPassword = doc['connectyPassword'];
    farmerModel.isStaff = doc['isStaff'];
    farmerModel.loginType = doc['loginType'] ?? 0;
    farmerModel.feedbackCount = doc['feedbackCount'] ?? 0;
    farmerModel.countryModel = doc['countryModel'] == null
        ? null
        : AvailableCountryModel.toObject(doc['countryModel']);

    return farmerModel;
  }

  Map<String, Object?> getMap() {
    Map<String, Object?> map = {};
    map['profileImage'] = profileImage ?? "";
    map['token'] = token ?? "";
    map['platform'] = platform ?? "";
    map['uid'] = uid ?? "";
    map['blockId'] = blockId ?? "";
    map['tehsilId'] = blockId ?? "";
    map['regionId'] = blockId ?? "";
    map['farmerName'] = farmerName ?? "";
    map['phone'] = phone ?? "";
    map['date'] = date ?? "";
    map['loginDate'] = loginDate ?? "";
    map['fatherName'] = fatherName ?? "";
    map['districtName'] = districtName ?? "";
    map['villageName'] = villageName ?? "";
    map['districtId']= districtId ?? "";
    map['connectyLogin'] = connectyLogin ?? "";
    map['connectyPassword'] = connectyPassword ?? "";
    map['isStaff'] = isStaff;
    map['loginType'] = loginType ?? 0;
    map['feedbackCount'] = feedbackCount ?? 0;
    map['countryModel'] = countryModel?.getMap();

    return map;
  }

  @override
  String toString() {
    return 'FarmerModel{uid: $uid, farmerName: $farmerName, phone: $phone, fatherName: $fatherName, districtName: $districtName, villageName: $villageName, token: $token, platform: $platform, connectyLogin: $connectyLogin, connectyPassword: $connectyPassword, profileImage: $profileImage, date: $date, districtId: $districtId, loginType: $loginType}';
  }
}