import 'package:bill_tracker/models/Representative.dart';
import 'package:bill_tracker/services/auth.dart';
import 'package:flutter/material.dart';

import '../common_widgets/custom_raised_button.dart';
import '../models/Representative.dart';
import 'RepProfile.dart';

class RepsList extends StatefulWidget {
  RepsList({required this.auth, required this.futureReps});
  final AuthBase auth;
  late Future<List<Representative>> futureReps;

  @override
  _RepsListState createState() => _RepsListState();
}

class _RepsListState extends State<RepsList> {
  // late Future<List<String>> futureReps;

  @override
  void initState() {
    super.initState();
    // likedBillsFuture = _getLikedBills();
  }

  void fetchRepProfile(String id) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => RepProfile(auth: widget.auth, repId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Representatives'),
        elevation: 2.0,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Representative>>(
              future: widget.futureReps,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Representative>> snapshot) {
                if (snapshot.hasData) {
                  List<Representative>? reps = snapshot.data;

                  return SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: reps!
                              .map((Representative rep) => Card(
                                  color: Colors.white,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const SizedBox(width: 15),
                                            ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(50.0),
                                              child: Image.network(
                                                "https://theunitedstates.io/images/congress/original/" +
                                                    rep.id +
                                                    ".jpg",
                                                height: 70.0,
                                                width: 70.0,
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            CustomRaisedButton(
                                              child: Text(rep.name),
                                              color: Colors.blue,
                                              onPressed: ()=>{fetchRepProfile(rep.id)},
                                            )
                                          ],
                                        )
                                      ])))
                              .toList()));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              })),
      backgroundColor: Colors.grey[200],
    );
  }
}
