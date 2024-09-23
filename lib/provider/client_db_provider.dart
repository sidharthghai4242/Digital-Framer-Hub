import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_farmer_hub/models/ContentModel.dart';
import 'package:digital_farmer_hub/models/GalleryModel.dart';
import 'package:digital_farmer_hub/models/MediaModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

import '../helper/Constants.dart';
import '../models/ExtraModel.dart';
import '../models/NotificationModel.dart';
import '../models/SliderModel.dart';

class ClientDBProvider extends ChangeNotifier {
  FirebaseFirestore? firestore;
  NotificationModel? notificationModel;
  ContentModel? contentModel;
  List<SliderModel>? sliderModelList = [];
  List<GalleryModel>? galleryList = [];
  List<MediaModel>? videomediaList = [];
  List<ContentModel>? newsList = [];
  List<ContentModel>? contentList = [];
  List<NotificationModel>? notificationList = [];
  ExtraModel? extraModel;
  StreamSubscription<QuerySnapshot>? sliderSub, gallerySub, videomediaSub,newsSub, allUserNotificationSub, singleUserNotificationSub;
  StreamSubscription<QuerySnapshot>? notificationSub;
  dynamic states;

  @override
  void dispose() {
    if (allUserNotificationSub != null) {
      allUserNotificationSub!.cancel();
    }
    if (singleUserNotificationSub != null) {
      singleUserNotificationSub!.cancel();
    }
    if (sliderSub != null) {
      sliderSub!.cancel();
    }
    if (gallerySub != null) {
      gallerySub!.cancel();
    }
    if (videomediaSub != null) {
      videomediaSub!.cancel();
    }
    if (newsSub != null) {
      newsSub!.cancel();
    }
    if (notificationSub != null) {
      notificationSub!.cancel();
    }
    super.dispose();
  }

  ClientDBProvider() {
    firestore = FirebaseFirestore.instance;
  }

  getSliderData() {
    sliderSub = firestore!
        .collection(sliderCollection)
        .where("sliderStatus", isEqualTo: true)
        .orderBy("sequence", descending: true)
        .snapshots()
        .listen((event) {
      sliderModelList!.clear();
      for (var element in event.docs) {
        SliderModel content = SliderModel.toObject(element.data());
        sliderModelList!.add(content);
        // print('SliderContentModel title: ${content.title}');
        // sliderModelList!.add(SliderModel.toObject(element.data()));
      }
      notifyListeners();
    });
  }

  getGalleryData() {
    gallerySub = firestore!
        .collection(galleryCollection)
        .where("status", isEqualTo: true)
        .orderBy("sequence", descending: true)
        .snapshots()
        .listen((event) {
      galleryList!.clear();
      for (var element in event.docs) {
        galleryList!.add(GalleryModel.toObject(element.data()));
      }
      notifyListeners();
    });
  }

  Future<void> getContentData() async {
    await FirebaseFirestore.instance
        .collection(contentCollection)
        .orderBy("createdOn", descending: true)
        .get()
        .then((value) {
      contentList = [];
      for (var element in value.docs) {
        ContentModel content = ContentModel.toObject(element.data());
        contentList!.add(content);
        // print('ContentModel title: ${content.title}');
      }
    });
    // print('ContentModel List: ${contentList}');
    return;
  }

  Future<void> getNotificationData() async {
    await FirebaseFirestore.instance
        .collection(notificationCollection)
        .orderBy("date", descending: true)
        .get()
        .then((value) {
      notificationList = [];
      for (var element in value.docs) {
        NotificationModel notification = NotificationModel.toObject(element.data());
        notificationList!.add(notification);
        // print('NotificationModel title: ${notification.title}');
      }
    });
    // print('NotificationModel List: ${notificationList}');
    subscribeToTopicsContent();
    subscribeToTopicsNotification();
    subscribeToTopicsGallery();
    subscribeToTopicsContentevent();
    return;
  }

  subscribeToTopicsNotification() async {
    await FirebaseMessaging.instance.subscribeToTopic("allUserNotificationTopic").then((_) {
      print('Subscribed to allUserNotificationTopic');
    }).catchError((error) {
      print('Failed to subscribe to allUserNotificationTopic: $error');
    });
  }

  subscribeToTopicsContent() async {
    await FirebaseMessaging.instance.subscribeToTopic("allContent").then((_) {
      print('Subscribed to allContent');
    }).catchError((error) {
      print('Failed to subscribe to allContent: $error');
    });
  }

  subscribeToTopicsContentevent() async {
    await FirebaseMessaging.instance.subscribeToTopic("allEventContent").then((_) {
      print('Subscribed to allEventContent');
    }).catchError((error) {
      print('Failed to subscribe to allEventContent: $error');
    });
  }

  subscribeToTopicsContentDistrict(String districtId) async {
    await FirebaseMessaging.instance.subscribeToTopic(districtId).then((_) {
      print('Subscribed to district $districtId');
    }).catchError((error) {
      print('Failed to subscribe to district $districtId: $error');
    });
  }

  subscribeToTopicsGallery() async {
    await FirebaseMessaging.instance.subscribeToTopic("galleryTopic").then((_) {
      print('Subscribed to Gallery');
    }).catchError((error) {
      print('Failed to subscribe to Gallery: $error');
    });
  }

  fetchUpdate() {
    return FirebaseFirestore.instance
        .collection(extra)
        .doc(extra)
        .get()
        .then((value) {
      extraModel = ExtraModel.toObject(value.data());
      return extraModel;
    });
  }

  unsubscribeToTopic(String districtId) async {
      await FirebaseMessaging.instance.unsubscribeFromTopic("allUserNotificationTopic");
      await FirebaseMessaging.instance.unsubscribeFromTopic("allContent");
      await FirebaseMessaging.instance.unsubscribeFromTopic("allEventContent");
      await FirebaseMessaging.instance.unsubscribeFromTopic("Gallery");
      await FirebaseMessaging.instance.unsubscribeFromTopic(districtId);
  }

}