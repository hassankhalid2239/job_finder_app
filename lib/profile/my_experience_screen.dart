import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder_app/profile/update_experience_screen.dart';
import 'package:page_transition/page_transition.dart';

import 'add_experience_screen.dart';

class MyExperienceScreen extends StatefulWidget {
  const MyExperienceScreen({super.key});
  @override
  State<MyExperienceScreen> createState() => _MyExperienceScreenState();
}

class _MyExperienceScreenState extends State<MyExperienceScreen> {
  final ScrollController scController = ScrollController();
  String? gender;

  final user = FirebaseAuth.instance.currentUser;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Theme.of(context).colorScheme.onSurface,
              statusBarIconBrightness: Theme.of(context).brightness),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          elevation: 0,
          centerTitle: true,
          title: Text('Experience',
              style: Theme.of(context).textTheme.displayMedium),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      PageTransition(
                        child: const AddExperienceScreen(),
                        type: PageTransitionType.bottomToTop,
                      ));
                },
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.outline,
                ),
                iconSize: 28,
              ),
            )
          ],
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(uid)
                .collection('Experience')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.hasError.toString()));
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        splashFactory: InkRipple.splashFactory,
                        // splashColor: Color(0xff5800FF),
                        overlayColor:
                            const WidgetStatePropertyAll(Color(0x4d5800ff)),
                        onTap: () {
                          String id = snapshot.data!.docs[index]['id'];
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: UpdateExperienceScreen(id = id),
                                  type: PageTransitionType.rightToLeft));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
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
                              Text('${snapshot.data!.docs[index]['Title']}',
                                  style:
                                      Theme.of(context).textTheme.labelMedium),
                              Text(
                                  'At ${snapshot.data!.docs[index]['Company Name']}',
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                  '${snapshot.data!.docs[index]['Job Description']}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }));
  }
}
