import 'package:digital_farmer_hub/models/FarmerModel.dart';

const appName = 'DIGITAL FARMER HUB';
const String prod = "prod";
const bool isProd = true;
const String hyphen = "-";

const String extra = "extra";
const String users = "users";
const String sliderCollection = 'slider';
const String galleryCollection = 'gallery';
const String mediaCollection = 'media';
const String feedBackCollection = 'feedback';
const String notificationCollection = "notifications";
const String reportCollection = "reports";
const String videoQuestionsCollection = "videoQuestions";
const String contentCollection = 'content';
const String aboutUSCollection = 'aboutUs';
const String districtCollection = 'districts';
const String regionsCollection = 'regions';

FarmerModel loginedFarmer = FarmerModel();

class Algolia {
  // Algolia CONSTANTS
  static const String applicationId = "3CV0BSLAB3";
  static const String apiKey = "12ca004169b9ae3a96170c15798b394b";
  static const String indexName = "content";
}