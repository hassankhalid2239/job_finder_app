// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder_app/profile/pdf_viewer_screen.dart';
import 'package:job_finder_app/profile/setting_page.dart';
import 'package:job_finder_app/profile/upload_resume_page.dart';
import 'package:page_transition/page_transition.dart';
import '../Widgets/snackbar.dart';
import 'aboutme_screen.dart';
import 'edit_profile.dart';
import 'my_education_screen.dart';
import 'my_experience_screen.dart';
import 'my_skills_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController scController = ScrollController();
  final user = FirebaseAuth.instance.currentUser;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String resumeUrl = '';
  String resumeName = '';
  final Snack snack = Snack();
  bool avail = true;
  @override
  void initState() {
    super.initState();
    _getResumeData();
    availability();
  }

  Future _getResumeData() async {
    DocumentSnapshot ref =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    setState(() {
      resumeUrl = ref.get('Resume Url');
      resumeName = ref.get('ResumeName');
      avail = ref.get('Availability');
    });
  }

  Future<void> refreshData() async {
    setState(() {
      _getResumeData();
    });
  }

  void availability() async {
    if (avail == true) {
      setState(() {
        avail = false;
      });
      FirebaseFirestore.instance.collection('Users').doc(uid).update({
        'Availability': avail,
      });
    } else if (avail == false) {
      setState(() {
        avail = true;
      });
      FirebaseFirestore.instance.collection('Users').doc(uid).update({
        'Availability': avail,
      });
    }
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
            automaticallyImplyLeading: false,
            toolbarHeight: 50,
            centerTitle: true,
            title: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text('Profile',
                  style: Theme.of(context).textTheme.displayMedium),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              child: const SettingPage(),
                              type: PageTransitionType.rightToLeft,
                              duration: const Duration(milliseconds: 300)));
                    },
                    icon: Icon(
                      Icons.settings_outlined,
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
          child: ListView(
            children: [
              Container(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text(snapshot.hasError.toString()));
                            }
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                  radius: 30,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: snapshot.data!.get('User Image') ==
                                              ""
                                          ? const Icon(
                                              Icons.camera_alt_outlined,
                                              size: 25,
                                              color: Colors.white,
                                            )
                                          : Image.network(
                                              '${snapshot.data!.get('User Image')}'))),
                              title: Text('${snapshot.data!.get('Name')}',
                                  style:
                                      Theme.of(context).textTheme.labelMedium),
                              subtitle: Text(
                                '${snapshot.data!.get('Email')}',
                                style: GoogleFonts.dmSans(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            );
                          }),
                      const SizedBox(
                        height: 15,
                      ),
                      Wrap(
                        spacing: 30,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            // width: w*0.391,
                            width: 150,
                            height: 45,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    splashFactory: InkRipple.splashFactory,
                                    backgroundColor: const Color(0xff5800FF),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          child: const EditProfilePage(),
                                          type: PageTransitionType.rightToLeft,
                                          duration: const Duration(
                                              milliseconds: 300)));
                                },
                                child: Text('Edit Profile',
                                    style: GoogleFonts.dmSans(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ))),
                          ),
                          SizedBox(
                            // width: w*0.417,
                            width: 150,
                            height: 45,
                            child: OutlinedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    splashFactory: InkRipple.splashFactory,
                                    backgroundColor: avail == true
                                        ? const Color(0xff25D366)
                                        :
                                        // Color(0xff5800FF) :
                                        Colors.transparent,
                                    foregroundColor: const Color(0xff5800FF),
                                    side: const BorderSide(
                                        color: Color(0xff5800FF), width: 1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                onPressed: () {
                                  availability();
                                },
                                child: Text(
                                    avail == true
                                        ? 'Available'
                                        : 'Not Available',
                                    style: avail == true?
                                        GoogleFonts.dmSans(
                                          color: Colors.white,
                                          fontSize: 14
                                        ):
                                    Theme.of(context).textTheme.headlineSmall)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              //Resume section
              Container(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Text('Resume',
                            style: Theme.of(context).textTheme.labelMedium),
                        trailing: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: const UploadResumePage(),
                                    type: PageTransitionType.rightToLeft,
                                    duration:
                                        const Duration(milliseconds: 300)));
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 22,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      resumeUrl == ''
                          ? const SizedBox()
                          : ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PdfViewerScreen(
                                              pdfUrl: resumeUrl.toString(),
                                              resumeName: resumeName.toString(),
                                            )));
                              },
                              horizontalTitleGap: 10,
                              contentPadding: EdgeInsets.zero,
                              leading: SvgPicture.asset(
                                'assets/svg/img_frame_primary.svg',
                                theme: const SvgTheme(
                                    currentColor: Color(0xff8F00FF)),
                                width: 24,
                                height: 24,
                              ),
                              title: Text(resumeName,
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              //Aboutmesection
              Container(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Text('About Me',
                            style: Theme.of(context).textTheme.labelMedium),
                        trailing: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: const AboutMeScreen(),
                                    type: PageTransitionType.rightToLeft));
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 22,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text(snapshot.hasError.toString()));
                            }
                            return Text(
                              '${snapshot.data!.get('About Me')}',
                              style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.outline),
                            );
                          })
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              //Expriencesection
              Container(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Text('Experience',
                            style: Theme.of(context).textTheme.labelMedium),
                        trailing: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: const MyExperienceScreen(),
                                    type: PageTransitionType.rightToLeft));
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 22,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Users")
                              .doc(uid)
                              .collection("Experience")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text(snapshot.hasError.toString()));
                            }
                            return ListView.separated(
                              controller: scController,
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length > 2
                                  ? 2
                                  : snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${snapshot.data!.docs[index]['Start Date']}-${snapshot.data!.docs[index]['End Date']}",
                                      style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff5800FF)),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                        '${snapshot.data!.docs[index]['Title']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium),
                                    Text(
                                      'At ${snapshot.data!.docs[index]['Company Name']}',
                                      style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      '${snapshot.data!.docs[index]['Job Description']}',
                                      style: GoogleFonts.dmSans(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 15,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 16,
                              ),
                            );
                          }),
                      const Divider(
                        thickness: 0.2,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: ButtonStyle(
                              splashFactory: InkRipple.splashFactory,
                              overlayColor: const MaterialStatePropertyAll(
                                  Color(0x4d5800ff)),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)))),
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: const MyExperienceScreen(),
                                    type: PageTransitionType.rightToLeft));
                          },
                          child: Wrap(
                            children: [
                              Text('Show all experience  ',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.black,
                                size: 18,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              //Education-section
              Container(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Text('Education',
                            style: Theme.of(context).textTheme.labelMedium),
                        trailing: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: const MyEducationScreen(),
                                    type: PageTransitionType.rightToLeft));
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 22,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Users")
                              .doc(uid)
                              .collection("Education")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text(snapshot.hasError.toString()));
                            }
                            return ListView.separated(
                              controller: scController,
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length > 2
                                  ? 2
                                  : snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${snapshot.data!.docs[index]['Start Date']}-${snapshot.data!.docs[index]['End Date']}',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff5800FF)),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                        '${snapshot.data!.docs[index]['School']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium),
                                    Text(
                                      '${snapshot.data!.docs[index]['Degree']}',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 16,
                              ),
                            );
                          }),
                      const Divider(
                        thickness: 0.2,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: ButtonStyle(
                              splashFactory: InkRipple.splashFactory,
                              overlayColor: const MaterialStatePropertyAll(
                                  Color(0x4d5800ff)),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)))),
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: const MyEducationScreen(),
                                    type: PageTransitionType.rightToLeft));
                          },
                          child: Wrap(
                            children: [
                              Text('Show all education  ',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.black,
                                size: 18,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              //Skill section
              Container(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Text('Skills',
                            style: Theme.of(context).textTheme.labelMedium),
                        trailing: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: const MySkillsScreen(),
                                    type: PageTransitionType.rightToLeft));
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 22,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Users")
                              .doc(uid)
                              .collection("Skills")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text(snapshot.hasError.toString()));
                            }
                            return Wrap(
                              spacing: 16,
                              runSpacing: 10,
                              children: List.generate(
                                  snapshot.data!.docs.length > 3
                                      ? 3
                                      : snapshot.data!.docs.length, (index) {
                                return Chip(
                                  color: MaterialStatePropertyAll(
                                    Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                                  ),
                                  elevation: 0,
                                  label: Text(
                                      '${snapshot.data!.docs[index]['Title']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall),
                                  backgroundColor: const Color(0xff282837),
                                );
                              }),
                            );
                          }),
                      const Divider(
                        thickness: 0.2,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: ButtonStyle(
                              splashFactory: InkRipple.splashFactory,
                              overlayColor: const MaterialStatePropertyAll(
                                  Color(0x4d5800ff)),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)))),
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: const MySkillsScreen(),
                                    type: PageTransitionType.rightToLeft));
                          },
                          child: Wrap(
                            children: [
                              Text('Show all skills  ',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.black,
                                size: 18,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

