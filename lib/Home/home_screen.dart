// ignore_for_file: deprecated_member_use

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Widgets/shimmer_job_card_h.dart';
import '../Widgets/shimmer_jobcard.dart';
import '../Widgets/snackbar.dart';
import '../job/job_detail_page.dart';
import '../job/new_hiring.dart';
import '../job/recommended_jobs.dart';
import 'notification_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String userImage = '';
  String userName = '';
  initInfo() {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationsSettings =
        InitializationSettings(android: androidInitialize);
    flutterLocalNotificationsPlugin.initialize(
      initializationsSettings,
      onSelectNotification: (String? payload) async {
        try {
          if (payload != null && payload.isNotEmpty) {
          } else {}
        } on FirebaseAuthException catch (e) {
          Snack().errorSnackBar('On Snap!', e.message.toString());
        }
        return;
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        print('*************** onMessage **************');
      }
      if (kDebugMode) {
        print(
            'onMessage: ${message.notification!.title}/${message.notification!.body}');
      }

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          message.notification!.body.toString(),
          htmlFormatBigText: true,
          contentTitle: message.notification!.title.toString(),
          htmlFormatContentTitle: true);
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'fyp', 'fyp', importance: Importance.max,
        styleInformation: bigTextStyleInformation, priority: Priority.max,
        playSound: false,
        // sound: RowResourceAndroidNotificationSound('notification'),
      );
      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
          message.notification!.body, platformChannelSpecifics,
          payload: message.data['title']);
    });
  }

  @override
  initState() {
    super.initState();
    initInfo();
    getUserData();
  }

  getUserData() async {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    setState(() {
      userImage = userDoc.get('User Image');
      userName = userDoc.get('Name');
    });
  }

  Future<void> refreshData() async {
    setState(() {
      getUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Theme.of(context).colorScheme.onSurface,
                  statusBarIconBrightness: Theme.of(context).brightness),
              backgroundColor: Colors.transparent,
              scrolledUnderElevation: 0,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              elevation: 0,
              floating: true,
              toolbarHeight: 50,
              leadingWidth: 80,
              titleSpacing: 0,
              leading: Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: CircleAvatar(
                    radius: 22,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: userImage == ''
                            ? const Icon(
                                Icons.person,
                                size: 25,
                                color: Colors.grey,
                              )
                            : Image.network(userImage)),
                  )),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(userName,
                      style: Theme.of(context).textTheme.headlineLarge),
                  AutoSizeText(
                    'Find your job here',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationListScreen()));
                      },
                      icon: Icon(
                        Icons.notifications_none_sharp,
                        color: Theme.of(context).colorScheme.outline,
                        size: 22,
                      )),
                )
              ],
            ),
          ],
          body: RefreshIndicator(
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            color: Theme.of(context).colorScheme.onSecondary,
            onRefresh: () => refreshData(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //New Hiring Buttons
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AutoSizeText('New Hiring',
                            style: Theme.of(context).textTheme.labelMedium),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const NewHiring()));
                            },
                            child: AutoSizeText('View All',
                                style:
                                    Theme.of(context).textTheme.headlineSmall))
                      ],
                    ),
                  ),
                  // Horizontal jobs section
                  const SizedBox(
                    height: 15,
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Jobs')
                        .orderBy('PostedAt', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 240,
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return const ShimmerJobCardH();
                              },
                              scrollDirection: Axis.horizontal,
                              // itemCount: snapshot.data.docs.length,
                              itemCount: 2),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.active) {
                        if (snapshot.data?.docs.isNotEmpty == true) {
                          return SizedBox(
                            height: 240,
                            child: ListView.builder(
                              itemCount: snapshot.data.docs.length > 5
                                  ? 5
                                  : snapshot.data.docs.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: SizedBox(
                                    width: 202,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        String id =
                                            snapshot.data!.docs[index]['id'];
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    JobDetailScreen(
                                                      id: id,
                                                      uid: snapshot.data
                                                          .docs[index]['uid'],
                                                      ownerEmail: snapshot
                                                              .data.docs[index]
                                                          ['OwnerEmail'],
                                                      jobDescription: snapshot
                                                              .data.docs[index]
                                                          ['JobDescription'],
                                                      jobExperience: snapshot
                                                              .data.docs[index]
                                                          ['JobExperience'],
                                                      jobType: snapshot
                                                              .data.docs[index]
                                                          ['JobType'],
                                                      jobRecruitment: snapshot
                                                              .data.docs[index]
                                                          ['JobRecruitment'],
                                                      jobLocation: snapshot
                                                              .data.docs[index]
                                                          ['JobLocation'],
                                                      userImage: snapshot
                                                              .data.docs[index]
                                                          ['UserImage'],
                                                      userName: snapshot
                                                              .data.docs[index]
                                                          ['UserName'],
                                                      jobTitle: snapshot
                                                              .data.docs[index]
                                                          ['JobTitle'],
                                                      postDate: snapshot
                                                              .data.docs[index]
                                                          ['PostedAt'],
                                                      jobSalary: snapshot
                                                              .data.docs[index]
                                                          ['JobSalary'],
                                                    )));
                                      },
                                      style: ButtonStyle(
                                        overlayColor:
                                            const MaterialStatePropertyAll(
                                                Color(0xff1a288a)),
                                        splashFactory: InkRipple.splashFactory,
                                        elevation:
                                            const MaterialStatePropertyAll(0),
                                        padding: const MaterialStatePropertyAll(
                                            EdgeInsets.zero),
                                        backgroundColor:
                                            const MaterialStatePropertyAll(
                                                Color(0xff5800FF)),
                                        shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                      ),
                                      child: SizedBox(
                                        width: 202,
                                        child: Card(
                                          color: Colors.transparent,
                                          elevation: 0,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, top: 10),
                                                child: CircleAvatar(
                                                    radius: 22,
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(22),
                                                        child: snapshot.data
                                                                            .docs[
                                                                        index][
                                                                    'UserImage'] ==
                                                                ''
                                                            ? const Icon(
                                                                Icons.person,
                                                                size: 25,
                                                                color:
                                                                    Colors.grey,
                                                              )
                                                            : Image.network(snapshot
                                                                    .data
                                                                    .docs[index]
                                                                [
                                                                'UserImage']))),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    AutoSizeText(
                                                      '${snapshot.data.docs[index]['UserName']}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts.dmSans(
                                                          color: const Color(
                                                              0xffF6F8FE),
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(
                                                      '${snapshot.data.docs[index]['JobTitle']}',
                                                      style: GoogleFonts.dmSans(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    Text(
                                                      "\$ ${snapshot.data.docs[index]['JobSalary']}",
                                                      style: GoogleFonts.dmSans(
                                                        color: const Color(
                                                            0xffF6F8FE),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    Container(
                                                      width: 70,
                                                      height: 28,
                                                      decoration: BoxDecoration(
                                                          color: const Color(
                                                              0xff9333FF),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8)),
                                                      child: Center(
                                                        child: Text(
                                                          '${snapshot.data.docs[index]['JobType']}',
                                                          style: GoogleFonts
                                                              .dmSans(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${snapshot.data.docs[index]['PostedAt']}',
                                                      style: GoogleFonts.dmSans(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                    SizedBox(
                                                      width: 80,
                                                      height: 30,
                                                      child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              splashFactory:
                                                                  InkRipple
                                                                      .splashFactory,
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              foregroundColor:
                                                                  const Color(
                                                                      0xff292c47),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12))),
                                                          onPressed: () {
                                                            String id = snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                ['id'];
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            JobDetailScreen(
                                                                              id: id,
                                                                              uid: snapshot.data.docs[index]['uid'],
                                                                              ownerEmail: snapshot.data.docs[index]['OwnerEmail'],
                                                                              jobDescription: snapshot.data.docs[index]['JobDescription'],
                                                                              jobExperience: snapshot.data.docs[index]['JobExperience'],
                                                                              jobType: snapshot.data.docs[index]['JobType'],
                                                                              jobRecruitment: snapshot.data.docs[index]['JobRecruitment'],
                                                                              jobLocation: snapshot.data.docs[index]['JobLocation'],
                                                                              userImage: snapshot.data.docs[index]['UserImage'],
                                                                              userName: snapshot.data.docs[index]['UserName'],
                                                                              jobTitle: snapshot.data.docs[index]['JobTitle'],
                                                                              postDate: snapshot.data.docs[index]['PostedAt'],
                                                                              jobSalary: snapshot.data.docs[index]['JobSalary'],
                                                                            )));
                                                          },
                                                          child: Text(
                                                            'Apply',
                                                            style: GoogleFonts.dmSans(
                                                                color: const Color(
                                                                    0xff5800FF),
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          )),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              scrollDirection: Axis.horizontal,
                              // itemCount: snapshot.data.docs.length,
                            ),
                          );
                        } else {
                          return Center(
                            child: AutoSizeText(
                              'There is no Job!',
                              style: GoogleFonts.dmSans(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 16),
                            ),
                          );
                        }
                      }
                      return Center(
                        child: AutoSizeText(
                          'Something went wrong',
                          style: GoogleFonts.dmSans(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 16),
                        ),
                      );
                    },
                  ),
                  // Recommended section
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AutoSizeText('Featured',
                            style: Theme.of(context).textTheme.labelMedium),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RecommendedJobScreen()));
                            },
                            child: AutoSizeText('View All',
                                style:
                                    Theme.of(context).textTheme.headlineSmall))
                      ],
                    ),
                  ),
                  // Recommended jobs
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Jobs')
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 240,
                          child: ListView.builder(
                            itemCount: 5,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) =>
                                const ShimmerJobCard(),
                          ),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.active) {
                        if (snapshot.data?.docs.isNotEmpty == true) {
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data.docs.length > 5
                                ? 5
                                : snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              return Card(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  splashFactory: InkRipple.splashFactory,
                                  // splashColor: Color(0xff5800FF),
                                  overlayColor: const MaterialStatePropertyAll(
                                      Color(0x4d5800ff)),
                                  onTap: () {
                                    String id =
                                        snapshot.data!.docs[index]['id'];
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                JobDetailScreen(
                                                  id: id,
                                                  uid: snapshot.data.docs[index]
                                                      ['uid'],
                                                  ownerEmail:
                                                      snapshot.data.docs[index]
                                                          ['OwnerEmail'],
                                                  jobDescription:
                                                      snapshot.data.docs[index]
                                                          ['JobDescription'],
                                                  jobExperience:
                                                      snapshot.data.docs[index]
                                                          ['JobExperience'],
                                                  jobType: snapshot.data
                                                      .docs[index]['JobType'],
                                                  jobRecruitment:
                                                      snapshot.data.docs[index]
                                                          ['JobRecruitment'],
                                                  jobLocation:
                                                      snapshot.data.docs[index]
                                                          ['JobLocation'],
                                                  userImage: snapshot.data
                                                      .docs[index]['UserImage'],
                                                  userName: snapshot.data
                                                      .docs[index]['UserName'],
                                                  jobTitle: snapshot.data
                                                      .docs[index]['JobTitle'],
                                                  postDate: snapshot.data
                                                      .docs[index]['PostedAt'],
                                                  jobSalary: snapshot.data
                                                      .docs[index]['JobSalary'],
                                                )));
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        contentPadding:
                                            const EdgeInsets.only(left: 15),
                                        leading: CircleAvatar(
                                            radius: 22,
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(22),
                                                child: snapshot.data.docs[index]
                                                            ['UserImage'] ==
                                                        ""
                                                    ? const Icon(
                                                        Icons.person,
                                                        size: 25,
                                                        color: Colors.grey,
                                                      )
                                                    : Image.network(snapshot
                                                            .data.docs[index]
                                                        ['UserImage']))),
                                        title: AutoSizeText(
                                            '${snapshot.data.docs[index]['JobTitle']}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium),
                                        subtitle: AutoSizeText(
                                          '${snapshot.data.docs[index]['UserName']} - ${snapshot.data.docs[index]['PostedAt']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge,
                                        ),
                                        trailing: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Icon(
                                            Icons.arrow_forward_ios_sharp,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Wrap(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                              size: 18,
                                            ),
                                            AutoSizeText(
                                              '${snapshot.data.docs[index]['JobLocation']}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Icon(
                                              Icons.currency_exchange_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                              size: 15,
                                            ),
                                            AutoSizeText(
                                              ' ${snapshot.data.docs[index]['JobSalary']}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: AutoSizeText(
                              'There is no Job!',
                              style: GoogleFonts.dmSans(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 16),
                            ),
                          );
                        }
                      }
                      return Center(
                        child: AutoSizeText(
                          'Something went wrong',
                          style: GoogleFonts.dmSans(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 16),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
