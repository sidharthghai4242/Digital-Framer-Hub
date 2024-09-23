import 'package:cloud_firestore/cloud_firestore.dart';

class SliderModel {
  String  imageUrl = "", title = "";
  bool sliderStatus = false;
  Timestamp createdOn = Timestamp.now();
  int? sequence;

  SliderModel();

  static SliderModel toObject(doc) {
    SliderModel model = SliderModel();
    // model.imageId = doc['imageId'];
    model.imageUrl = doc['imageUrl'];
    model.createdOn = doc['createdOn'];
    model.title = doc['title'];
    model.sliderStatus = doc['sliderStatus'];
    model.sequence = doc['sequence'] ?? 0;

    return model;
  }

  Map<String, Object> getMap() {
    Map<String, Object> map = {};
    // map['imageId'] = imageId;
    map['imageUrl'] = imageUrl;
    map['createdOn'] = createdOn;
    map['title'] = title;
    map['sliderStatus'] = sliderStatus;
    map['sequence'] = sequence ??0;
    return map;
  }

  @override
  String toString() {
    return 'SliderModel{ imageUrl: $imageUrl, title: $title, addedOn: $createdOn}';
  }
}
