import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../job/job_detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  List<String> favJobsList = [];
  List favItemList = [];
  getFavJobsKeys() async {
    var favoriteJobDocument = await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .collection("FavoriteJobs")
        .get();
    for (int i = 0; i < favoriteJobDocument.docs.length; i++) {
      favJobsList.add(favoriteJobDocument.docs[i].id);
    }
    getFavKeysData(favJobsList);
  }

  getFavKeysData(List<String> keysList) async {
    var allJobs = await FirebaseFirestore.instance.collection("Jobs").get();
    for (int i = 0; i < allJobs.docs.length; i++) {
      for (int k = 0; k < keysList.length; k++) {
        if (((allJobs.docs[i].data() as dynamic)['id']) == keysList[k]) {
          favItemList.add(allJobs.docs[i].data());
        }
      }
    }
    setState(() {
      favItemList;
    });
  }

  favJobs(String jobid) async {
    var document = await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .collection("FavoriteJobs")
        .doc(jobid)
        .get();
    if (document.exists) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .collection("FavoriteJobs")
          .doc(jobid)
          .delete();
    } else {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .collection("FavoriteJobs")
          .doc(jobid)
          .set({});
    }
  }

  Future<void> refreshData() async {
    setState(() {
      favItemList.clear();
      favJobsList.clear();
    });
    getFavJobsKeys();
  }

  @override
  void initState() {
    super.initState();
    getFavJobsKeys();
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
              centerTitle: true,
              title: Text('Favorite Jobs',
                  style: Theme.of(context).textTheme.displayMedium),
            ),
          ],
          body: favItemList.isEmpty
              ? RefreshIndicator(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  color: Theme.of(context).colorScheme.onSecondary,
                  onRefresh: () => refreshData(),
                  child: SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 350, horizontal: 50),
                        child: Text('There is no Favorite job',
                            style: Theme.of(context).textTheme.labelMedium),
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                  color: Theme.of(context).colorScheme.onSecondary,
                  onRefresh: () => refreshData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favItemList.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: double.infinity,
                        height: 107,
                        child: Card(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          child: InkWell(
                            splashFactory: InkRipple.splashFactory,
                            // splashColor: Color(0xff5800FF),
                            overlayColor:
                                const WidgetStatePropertyAll(Color(0x4d5800ff)),
                            onTap: () {
                              String id = favItemList[index]['id'];
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => JobDetailScreen(
                                            id: id,
                                            uid: favItemList[index]['uid'],
                                            jobRecruitment: favItemList[index]
                                                ['JobRecruitment'],
                                            ownerEmail: favItemList[index]
                                                ['OwnerEmail'],
                                            jobDescription: favItemList[index]
                                                ['JobDescription'],
                                            jobExperience: favItemList[index]
                                                ['JobExperience'],
                                            jobType: favItemList[index]
                                                ['JobType'],
                                            jobLocation: favItemList[index]
                                                ['JobLocation'],
                                            userImage: favItemList[index]
                                                ['UserImage'],
                                            userName: favItemList[index]
                                                ['UserName'],
                                            jobTitle: favItemList[index]
                                                ['JobTitle'],
                                            postDate: favItemList[index]
                                                ['PostedAt'],
                                            jobSalary: favItemList[index]
                                                ['JobSalary'],
                                          )));
                            },
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding:
                                      const EdgeInsets.only(left: 15),
                                  leading: CircleAvatar(
                                      radius: 22,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(22),
                                          child: favItemList[index]
                                                      ['UserImage'] ==
                                                  ""
                                              ? const Icon(
                                                  Icons.error,
                                                  size: 25,
                                                  color: Colors.red,
                                                )
                                              : Image.network(favItemList[index]
                                                  ['UserImage']))),
                                  title: Text(
                                      '${favItemList[index]['JobTitle']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium),
                                  subtitle: Text(
                                    '${favItemList[index]['UserName']} - ${favItemList[index]['PostedAt']}',
                                    style:
                                        Theme.of(context).textTheme.labelLarge,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        size: 18,
                                      ),
                                      Text(
                                        '${favItemList[index]['JobLocation']}',
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
                                      Text(
                                        ' ${favItemList[index]['JobSalary']}',
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
                ),
        ),
      ),
    );
  }
}
