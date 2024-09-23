import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_farmer_hub/models/FarmerModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../helper/AppColors.dart';
import '../helper/Constants.dart';
import '../helper/loading_widget.dart';
import '../helper/localization/language_constants.dart';
import '../helper/theme_class.dart';
import '../models/NotificationModel.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> notificationList = [];
  DateTime currentDate = DateTime.now();
  bool isSwitched = true,loading = true;
  FirebaseMessaging _fcm = FirebaseMessaging.instance;
  StateSetter? notificationState;
  int documentLimit = 15;
  bool canRetrieveMore = true;
  DocumentSnapshot? lastDocument;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotifications();
  }

  getNotifications(){
    FirebaseFirestore.instance.collection(notificationCollection)
        .orderBy('date',descending: true)
        .limit(documentLimit)
        .get()
        .then((value){
      if(value!=null){
        notificationList.clear();
        for (var i in value.docs) {
          notificationList.add(NotificationModel.toObject(i.data()));
          lastDocument = i;
        }
      }
      if (notificationList.length < documentLimit) {
        canRetrieveMore = false;
      }
      notificationState!((){
        loading = false;
      });
    }).catchError((onError){
      notificationState!((){loading = false;});
    });
  }

  getMoreNotifications(){
    FirebaseFirestore.instance.collection(notificationCollection)
        .orderBy('date',descending: true)
        .startAfterDocument(lastDocument!)
        .limit(documentLimit)
        .get()
        .then((value){
      if(value!=null){
        if (value.docs.length < documentLimit) {
          canRetrieveMore = false;
        }
        for (var i in value.docs) {
          notificationList.add(NotificationModel.toObject(i.data()));
          lastDocument = i;
        }
      }
      if (notificationList.length < documentLimit) {
        canRetrieveMore = false;
      }
      notificationState!((){
        loading = false;
      });
    }).catchError((onError){
      notificationState!((){loading = false;});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${getTranslated(context, 'notifications')}",
                  style: TextStyle(
                    color: ThemeClass.colorPrimary, // Example: Set the color of the AppBar title
                  ),
                ),
                // Text(
                //   farmerModel!.farmerName!,
                //   style: GoogleFonts.openSans(
                //     color: Colors.grey,
                //     fontSize: 10,
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
              ],
            ),
            // actions: [
            //   Switch(
            //     value: isSwitched,
            //     onChanged: (value) {
            //       isSwitched = value;
            //       updateNotifications(isSwitched);
            //       setState(() {});
            //     },
            //     activeTrackColor: Colors.black12,
            //     activeColor: ThemeClass.colorPrimary,
            //   ),
            // ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (BuildContext context, void Function(void Function()) setState) {
                  notificationState = setState;
                  if (loading) {
                    return LoadingWidget();
                  } else {
                    return notificationList.isNotEmpty
                        ? Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, right: 8),
                        color: colorWhite,
                        child: ListView.separated(
                          itemCount: notificationList.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == notificationList.length - 1 && canRetrieveMore) {
                              getMoreNotifications();
                              Future.delayed(Duration(milliseconds: 400)).then((onValue) {
                                notificationState!(() {});
                              });
                            }
                            return Container(
                              margin: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
                              child: Container(
                                padding: const EdgeInsets.only(top: 8, bottom: 8),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 12),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            notificationList[index].title == null
                                                ? Container()
                                                : Text(
                                              notificationList[index].title.toString(),
                                              style: GoogleFonts.openSans(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.left,
                                              softWrap: true,
                                            ),
                                            Text(
                                              notificationList[index].message.toString(),
                                              style: GoogleFonts.openSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.left,
                                              softWrap: true,
                                            ),
                                            Text(
                                              // "${getTranslated(context, 'time:')}" +
                                                  DateFormat('MMM d, yyyy hh:mm aa')
                                                      .format(notificationList[index].date!.toDate())
                                                      .toString(),
                                              style: GoogleFonts.openSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: ThemeClass.colorPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider(
                              height: 1,
                            );
                          },
                        ),
                      ),
                    )
                        : widgetNoData();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget widgetNoData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
              height: 170, width: 170, child: Image.asset('assets/search.jpg')),
          Column(
            children: [
              Text(
                "${getTranslated(context, 'noNotifications')}",
                style: GoogleFonts.openSans(fontSize: 20, color: Colors.black),
              ),
              // Container(
              //   margin: const EdgeInsets.only(top: 30),
              //   width: 300,
              //   child: Text(
              //     "${getTranslated(context, 'ifDoctorStartedSessionDefferTheSessionOrDefferTheAppointmentThenYouWillBeNotifiedInThisSection')}",
              //     style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey),
              //     textAlign: TextAlign.center,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
