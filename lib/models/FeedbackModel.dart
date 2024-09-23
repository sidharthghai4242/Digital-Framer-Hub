class FeedbackModel {
  List<Map<String, dynamic>>? feedback;
  String farmerUid;
  DateTime timestamp;
  List<Map<String, dynamic>>? audioFeedback;

  FeedbackModel({
    required this.farmerUid,
    required this.timestamp,
    this.feedback,
    this.audioFeedback,
  });

  Map<String, dynamic> toJson() {
    return {
      'feedback': feedback,
      'farmerUid': farmerUid,
      'timestamp': timestamp,
      'audioFeedback': audioFeedback,
    };
  }
}
