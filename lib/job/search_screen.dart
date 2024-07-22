import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Widgets/shimmer_jobcard.dart';
import 'job_detail_page.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = 'Search query';
  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      _updateSearchQuery('');
    });
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  Widget _buildSearchField() {
    return TextFormField(
      autocorrect: true,
      controller: _searchQueryController,
      decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              _clearSearchQuery();
            },
            icon: const Icon(
              Icons.close,
              color: Colors.grey,
            ),
          ),
          hintText: 'Search for jobs',
          border: InputBorder.none,
          hintStyle: GoogleFonts.dmSans(color: Colors.grey)),
      style: Theme.of(context).textTheme.titleSmall,
      onChanged: (query) => _updateSearchQuery(query),
    );
  }

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
        title: _buildSearchField(),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Jobs')
            .where('JobTitle',
                isGreaterThanOrEqualTo: searchQuery.toLowerCase().toUpperCase())
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerJobCard();
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data.docs.isNotEmpty == true) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                                        id: id,
                                        jobRecruitment: snapshot
                                            .data.docs[index]['JobRecruitment'],
                                        uid: snapshot.data.docs[index]['uid'],
                                        ownerEmail: snapshot.data.docs[index]
                                            ['OwnerEmail'],
                                        jobDescription: snapshot
                                            .data.docs[index]['JobDescription'],
                                        jobExperience: snapshot.data.docs[index]
                                            ['JobExperience'],
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
                                          : Image.network(snapshot
                                              .data.docs[index]['UserImage']))),
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
                                  color: Theme.of(context).colorScheme.outline,
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
              );
            } else {
              return Center(
                child: Text(
                  'There is no jobs',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              );
            }
          }
          return Center(
            child: Text('Something went wrong!',
                style: Theme.of(context).textTheme.labelMedium),
          );
        },
      ),
    );
  }
}
