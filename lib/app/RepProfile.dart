import 'dart:convert';

import 'package:bill_tracker/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../models/Representative.dart';

class RepProfile extends StatefulWidget {

  RepProfile({required this.auth, required this.repId});
  final AuthBase auth;
  String repId;

  @override
  _RepProfileState createState() => _RepProfileState();
}

class _RepProfileState extends State<RepProfile> {

  late Future<Representative> repFuture;
  bool repLiked = false;
  bool repDisliked = false;

  late Future<List<String>> likedRepsFuture;
  List<String> likedReps= List<String>.empty();
  late Future<List<String>> dislikedRepsFuture;
  List<String> dislikedReps= List<String>.empty();

  final CollectionReference _users =
  FirebaseFirestore.instance.collection('users');



  @override
  void initState() {
    super.initState();
    repFuture = _getRepInfo();

    //likedBillsFuture = _getLikedBills();
    //likedBillsFuture.then((value) => likedBills = value);

    likedRepsFuture = _getLikedReps();
    likedRepsFuture.then((value)  {
      likedReps = value;
      print(likedReps);
      if(likedReps.contains(widget.repId)){
        repLiked = true;
        setState(() {
          repLiked;
        });
      }

    });

    dislikedRepsFuture = _getDislikedReps();
    dislikedRepsFuture.then((value)  {
      dislikedReps = value;
      print(dislikedReps);
      if(dislikedReps.contains(widget.repId)){
        repDisliked = true;
        setState(() {
          repDisliked;
        });
      }

    });

  }
  Future<List<String>> _getDislikedReps() async {
    DocumentSnapshot documentSnapshot =
    await _users.doc(widget.auth.currentUser?.uid).get();

    Map<String, dynamic>? data = documentSnapshot.data();
    String prevLikedReps = data!['dislikedReps'] ?? '';
    return prevLikedReps.split(',');
  }
  Future<List<String>> _getLikedReps() async {
    DocumentSnapshot documentSnapshot =
    await _users.doc(widget.auth.currentUser?.uid).get();

    Map<String, dynamic>? data = documentSnapshot.data();
    String prevLikedReps = data!['likedReps'] ?? '';
    return prevLikedReps.split(',');
  }

  Future<Representative> _getRepInfo() async{
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'X-API-Key' : 'V2q4gUN0KXw5Ew1Wl29Z2Av5Y39EjME7VFXj2d2c'
    };
    try{
      final response = await http.get(
        Uri.parse('https://api.propublica.org/congress/v1/members/'+widget.repId+'.json'),
        // Send authorization headers to the backend.
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {

        final body = jsonDecode(response.body);


        Map<String, dynamic> repInfoMap = body['results'][0];

        Representative rep  =Representative.fromJson(repInfoMap);
        //print(rep);

        return rep;

      }else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load rep');
      }
    }
    catch(e){
      print("exception:");
      print(e);
    }


    return Representative("test id", "test name");



  }
  void dislikeARep(String rep_id) async {

    if (!dislikedReps.contains(rep_id)) {
      String prevDislikedReps = dislikedReps.join(',');
      prevDislikedReps = prevDislikedReps + ',' + rep_id;

      dislikedReps.add(rep_id);
      repDisliked = true;
      setState(() {
        dislikedReps;
        repDisliked;
      });
      _users
          .doc(widget.auth.currentUser?.uid)
          .update({'dislikedReps': prevDislikedReps, 'dislikedRepsNumber' : dislikedReps.length});
    }
    else{
      dislikedReps.remove(rep_id);
      repDisliked = false;

      setState(() {
        dislikedReps;
        repDisliked;
      });

      String newLikedBills = dislikedReps.join(",");
      _users
          .doc(widget.auth.currentUser?.uid)
          .update({'dislikedReps': newLikedBills,'dislikedRepsNumber' : dislikedReps.length });

    }

  }
  void likeARep(String rep_id) async {
    if (!likedReps.contains(rep_id)) {
      String prevLikedReps = likedReps.join(',');
      prevLikedReps = prevLikedReps + ',' + rep_id;

      likedReps.add(rep_id);
      repLiked = true;
      setState(() {
        likedReps;
        repLiked;
      });
      _users
          .doc(widget.auth.currentUser?.uid)
          .update({'likedReps': prevLikedReps, 'likedRepsNumber' : likedReps.length});

    } else {
      likedReps.remove(rep_id);
      repLiked = false;
      setState(() {
        likedReps;
        repLiked;
      });
      String newLikedBills = likedReps.join(",");
      _users
          .doc(widget.auth.currentUser?.uid)
          .update({'likedReps': newLikedBills,'likedRepsNumber' : likedReps.length });


    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Representative'),
        elevation: 2.0,
      ),
        body: FutureBuilder<Representative>(
          future: repFuture,
          builder:
          (BuildContext context, AsyncSnapshot<Representative> snapshot) {
            if (snapshot.hasData) {
              Representative? rep = snapshot.data;
              return SingleChildScrollView(
                child:Column(
                  children: [
                    Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Text(
                              rep?.name ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:25),

                            ),

                            IconButton(
                                onPressed: () =>likeARep(rep?.id ?? ''),
                                icon: repLiked
                                    ? const Icon(
                                    Icons.thumb_up,
                                    size: 15)
                                    : const Icon(
                                    Icons
                                        .thumb_up_outlined,
                                    size: 15)),
                            IconButton(
                                onPressed: () =>dislikeARep(rep?.id ?? ''),
                                icon: repDisliked
                                    ? const Icon(
                                    Icons.thumb_down,
                                    size: 15)
                                    : const Icon(
                                    Icons
                                        .thumb_down_outlined,
                                    size: 15)),

                          ],
                        ),
                        Image.network("https://theunitedstates.io/images/congress/original/"+widget.repId+".jpg",
                          height: 200.0, width: 200.0,),

                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:   [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Basic Details :",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:20),

                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "Date of Birth : ",
                              style: TextStyle(
                                  fontSize:15),

                            ),
                            Text(
                              rep?.date_of_birth ?? " ",
                              style: TextStyle(
                                  fontSize:15),

                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "Website : ",
                              style: TextStyle(
                                  fontSize:15),

                            ),
                            Text(
                              rep?.website ?? " ",
                              style: TextStyle(
                                  fontSize:15),

                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "Party : ",
                              style: TextStyle(
                                  fontSize:15),

                            ),
                            Text(
                              rep?.current_party ?? " ",
                              style: TextStyle(
                                  fontSize:15),

                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "Most Recent Vote : ",
                              style: TextStyle(
                                  fontSize:15),

                            ),
                            Text(
                              rep?.most_recent_vote ?? " ",
                              style: TextStyle(
                                  fontSize:15),

                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "Twitter Id : ",
                              style: TextStyle(
                                  fontSize:15),

                            ),
                            Text(
                              rep?.twitter_account ?? " ",
                              style: TextStyle(
                                  fontSize:15),

                            ),

                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "Facebook Account : ",
                              style: TextStyle(
                                  fontSize:15),

                            ),
                            Text(
                              rep?.facebook_account ?? " ",
                              style: TextStyle(
                                  fontSize:15),

                            ),

                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "YouTube Account : ",
                              style: TextStyle(
                                  fontSize:15),

                            ),
                            Text(
                              rep?.youtube_account ?? " ",
                              style: TextStyle(
                                  fontSize:15),

                            ),

                          ],
                        )


                      ],
                    )

                  ],
                )

              );
            }
            else {
              return const Center(child: CircularProgressIndicator());
            }

          }
        ));
  }
}
