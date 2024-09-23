import 'package:cloud_firestore/cloud_firestore.dart';

class MediaModel {
  String mediaId = "", imageUrl = "", videoUrl = "", externalvideoUrl = "", uploadType = "", fileUrl = "";
  bool status = false;
  Timestamp createdOn = Timestamp.now();
  int? sequence;

  MediaModel();

  static MediaModel toObject(doc) {
    MediaModel model = MediaModel();
    model.mediaId = doc['mediaId'];
    model.imageUrl = doc['imageUrl'];
    model.videoUrl = doc['videoUrl'];
    model.externalvideoUrl = doc['externalvideoUrl'];
    model.uploadType = doc['uploadType'];
    model.fileUrl = doc['fileUrl'];
    model.createdOn = doc['createdOn'];
    model.status = doc['status'];
    model.sequence = doc['sequence'] ?? 0;

    return model;
  }

  Map<String, Object> getMap() {
    Map<String, Object> map = {};
    map['mediaId'] = mediaId;
    map['imageUrl'] = imageUrl;
    map['createdOn'] = createdOn;
    map['videoUrl'] = videoUrl;
    map['externalvideoUrl'] = externalvideoUrl;
    map['uploadType'] = uploadType;
    map['fileUrl'] = fileUrl;
    map['status'] = status;
    map['sequence'] = sequence ??0;
    return map;
  }

  @override
  String toString() {
    return 'MediaModel{mediaId: $mediaId, imageUrl: $imageUrl, videoUrl: $videoUrl, externalvideoUrl: $externalvideoUrl, uploadType: $uploadType, fileUrl: $fileUrl, addedOn: $createdOn}';
  }
}