import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryModel {
  String galleryId = "", imageUrl = "", title = "";
  // bool galleryStatus = false;
  Timestamp createdOn = Timestamp.now();
  int? sequence;

  GalleryModel();

  static GalleryModel toObject(doc) {
    GalleryModel model = GalleryModel();
    model.galleryId = doc['galleryId'];
    model.imageUrl = doc['imageUrl'];
    model.createdOn = doc['createdOn'];
    model.title = doc['title'];
    // model.galleryStatus = doc['galleryStatus'];
    model.sequence = doc['sequence'] ?? 0;

    return model;
  }

  Map<String, Object> getMap() {
    Map<String, Object> map = {};
    map['galleryId'] = galleryId;
    map['imageUrl'] = imageUrl;
    map['createdOn'] = createdOn;
    map['title'] = title;
    // map['galleryStatus'] = galleryStatus;
    map['sequence'] = sequence ??0;
    return map;
  }

  @override
  String toString() {
    return 'GalleryModel{galleryId: $galleryId, imageUrl: $imageUrl, title: $title, addedOn: $createdOn}';
  }
}
