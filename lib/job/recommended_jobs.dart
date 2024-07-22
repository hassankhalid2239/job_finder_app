import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Widgets/shimmer_jobcard.dart';
import 'job_detail_page.dart';

class RecommendedJobScreen extends StatefulWidget {
  const RecommendedJobScreen({super.key});

  @override
  State<RecommendedJobScreen> createState() => _RecommendedJobScreenState();
}

class _RecommendedJobScreenState extends State<RecommendedJobScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).colorScheme.onSurface,
            statusBarIconBrightness: Theme.of(context).brightness),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        elevation: 0,
        centerTitle: true,
        title: Text('Recommended jobs',
            style: Theme.of(context).textTheme.displayMedium),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Jobs').snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.separated(
              itemCount: 7,
              itemBuilder: (context, index) => const ShimmerJobCard(),
              separatorBuilder: (context, index) => const SizedBox(
                height: 10,
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data?.docs.isNotEmpty == true) {
              return RefreshIndicator(
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                color: Theme.of(context).colorScheme.onSecondary,
                onRefresh: () => refreshData(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: double.infinity,
                      height: 107,
                      child: Card(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        child: InkWell(
                          splashFactory: InkRipple.splashFactory,
                          // splashColor: Color(0xff5800FF),
                          overlayColor:
                              const WidgetStatePropertyAll(Color(0x4d5800ff)),
                          onTap: () {
                            String id = snapshot.data!.docs[index]['id'];
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => JobDetailScreen(
                                          jobRecruitment: snapshot.data
                                              .docs[index]['JobRecruitment'],
                                          id: id,
                                          uid: snapshot.data.docs[index]['uid'],
                                          ownerEmail: snapshot.data.docs[index]
                                              ['OwnerEmail'],
                                          jobDescription: snapshot.data
                                              .docs[index]['JobDescription'],
                                          jobExperience: snapshot.data
                                              .docs[index]['JobExperience'],
                                          jobType: snapshot.data.docs[index]
                                              ['JobType'],
                                          jobLocation: snapshot.data.docs[index]
                                              ['JobLocation'],
                                          userImage: snapshot.data.docs[index]
                                              ['UserImage'],
                                          userName: snapshot.data.docs[index]
                                              ['UserName'],
                                          jobTitle: snapshot.data.docs[index]
                                              ['JobTitle'],
                                          postDate: snapshot.data.docs[index]
                                              ['PostedAt'],
                                          jobSalary: snapshot.data.docs[index]
                                              ['JobSalary'],
                                        )));
                          },
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.only(left: 15),
                                leading: CircleAvatar(
                                    radius: 22,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(22),
                                        child: snapshot.data.docs[index]
                                                    ['UserImage'] ==
                                                ""
                                            ? const Icon(
                                                Icons.person,
                                                size: 25,
                                                color: Colors.grey,
                                              )
                                            : Image.network(snapshot.data
                                                .docs[index]['UserImage']))),
                                title: Text(
                                    '${snapshot.data.docs[index]['JobTitle']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium),
                                subtitle: Text(
                                  '${snapshot.data.docs[index]['UserName']} - ${snapshot.data.docs[index]['PostedAt']}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                trailing: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      size: 18,
                                    ),
                                    Text(
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
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      size: 15,
                                    ),
                                    Text(
                                      ' ${snapshot.data.docs[index]['JobSalary']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Center(
                child: Text('There is no Job!',
                    style: Theme.of(context).textTheme.labelMedium),
              );
            }
          }
          return Center(
            child: Text('Something went wrong',
                style: Theme.of(context).textTheme.labelMedium),
          );
        },
      ),
    );
  }
}
