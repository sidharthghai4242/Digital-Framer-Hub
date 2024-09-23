import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  String reportId = "", pdfUrl = "", title = "";
  bool status = false;
  Timestamp createdOn = Timestamp.now();
  int? sequence;

  ReportModel();

  static ReportModel toObject(doc) {
    ReportModel model = ReportModel();
    model.reportId = doc['reportId'];
    model.pdfUrl = doc['pdfUrl'];
    model.createdOn = doc['createdOn'];
    model.title = doc['title'];
    model.status = doc['status'];
    model.sequence = doc['sequence'] ?? 0;

    return model;
  }

  Map<String, Object> getMap() {
    Map<String, Object> map = {};
    map['reportId'] = reportId;
    map['pdfUrl'] = pdfUrl;
    map['createdOn'] = createdOn;
    map['title'] = title;
    map['status'] = status;
    map['sequence'] = sequence ??0;
    return map;
  }

  @override
  String toString() {
    return 'ReportModel{reportId: $reportId, pdfUrl: $pdfUrl, title: $title, createdOn: $createdOn}';
  }
}
