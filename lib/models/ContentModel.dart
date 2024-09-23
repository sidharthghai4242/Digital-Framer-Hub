import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  String? title = "", content = "",imageUrl = "", author = "", youtubeLink = "", pdfUrl= "", youtubeVideoId="";
  bool? impStatus = false;
  bool? status = false;
  // Timestamp createdOn = Timestamp.now();
  // Timestamp date = Timestamp.now();
  int? sequence, type;
  List<dynamic>? imageList = [];
  // List<dynamic>? uids = [];

  ContentModel();

  static ContentModel toObject(doc) {
    ContentModel model = ContentModel();
    // model.contentId = doc['contentId'];
    model.title = doc['title'];
    model.content = doc['content'];
    model.imageUrl = doc['imageUrl'];
    model.author = doc['author'];
    model.youtubeLink = doc['youtubeLink'];
    model.youtubeVideoId = doc['youtubeVideoId'];
    model.pdfUrl = doc['pdfUrl'];
    // model.createdOn = doc['createdOn'];
    // model.date = doc['date'];
    model.status = doc['status'];
    model.impStatus = doc['impStatus'];
    model.sequence = doc['sequence'] ?? 0;
    model.type = doc['type'] ?? 0;
    // model.imageList = doc['imageList'];
    // model.uids = doc['uids'];

    return model;
  }

  Map<String, Object> getMap() {
    Map<String, Object> map = {};
    // map['contentId'] = contentId!;
    map['title'] = title!;
    map['content'] = content!;
    map['imageUrl'] = imageUrl!;
    map['author'] = author!;
    map['youtubeLink'] = youtubeLink!;
    map['youtubeVideoId'] = youtubeVideoId!;
    map['pdfUrl'] = pdfUrl!;
    // map['createdOn'] = createdOn!;
    // map['date'] = date!;
    map['status'] = status!;
    map['impStatus'] = impStatus!;
    map['sequence'] = sequence! ??0;
    map['type'] = type! ??0;
    map['imageList'] = imageList!;
    // map['uids'] = uids!;
    return map;
  }

  @override
  String toString() {
    return 'ContentModel{title: $title, content: $content, imageUrl: $imageUrl, status: $status, impStatus: $impStatus, sequence: $sequence, author: $author, youtubeVideoId: $youtubeVideoId,, youtubeLink: $youtubeLink, pdfUrl: $pdfUrl, type: $type, imageList: $imageList}';
  }

  // @override
  // String toString() {
  //   return 'ContentModel{contentId: $contentId, title: $title, content: $content, imageUrl: $imageUrl, author: $author, youtubeLink: $youtubeLink, pdfUrl: $pdfUrl, createdOn: $createdOn, date: $date, status: $status, impStatus: $impStatus, sequence: $sequence, type: $type}';
  // }
}
