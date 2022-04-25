import 'package:bill_tracker/models/Representative.dart';
import 'package:bill_tracker/services/auth.dart';
import 'package:flutter/material.dart';

import '../common_widgets/custom_raised_button.dart';
import '../models/Representative.dart';

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

  void fetchRepProfile(){

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
              builder:
                  (BuildContext context, AsyncSnapshot<List<Representative>> snapshot) {
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
                                  Row(children: [
                                    Expanded(child: Image.network("https://theunitedstates.io/images/congress/original/" +rep.id+ ".jpg",
                                      height: 100.0, width: 100.0,)),
                                    const SizedBox(height: 5),
                                    CustomRaisedButton(child:Text(rep.name),color: Colors.blue,onPressed: fetchRepProfile,)

                                  ],)
                                ]
                            )
                        )).toList())
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }))
      ,
      backgroundColor: Colors.grey[200],
    );
  }
}
