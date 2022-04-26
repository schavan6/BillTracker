
import 'dart:convert';

import 'package:bill_tracker/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../models/Representative.dart';
class UserProfile extends StatefulWidget {
  UserProfile({required this.auth});

  AuthBase auth;

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  String name = "test";
  int likedRepsNumber =0;
  int likedBillsNumber =0;
  int dislikedRepsNumber = 0;
  int dislikedBillsNumber =0;

  late Future<DocumentSnapshot> documentFuture;

  @override
  void initState() {
    super.initState();
    documentFuture = _getInfo();
  }
  Future<DocumentSnapshot> _getInfo() async{
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.auth.currentUser?.uid)
        .get();
    return document;
/*
    name = await document.data()!['name'];
    likedRepsNumber = await document.data()!['likedRepsNumber'] as int;
    likedBillsNumber = await document.data()!['likedBillsNumber'] as int;
    dislikedRepsNumber = await document.data()!['dislikedRepsNumber'] as int;
    dislikedBillsNumber = await document.data()!['dislikedBillsNumber'] as int;*/
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 2.0,
      ),
      body: FutureBuilder(
    future: documentFuture,
    builder:
    (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if(snapshot.hasData){
        DocumentSnapshot? document = snapshot.data;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () =>{},
                  icon: const Icon(
                      Icons.person_outline_rounded,
                      size: 65)
                      ),
              SizedBox(height: 50,),
              Text(document?.data()!['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:25)),
              SizedBox(height: 10,),
              Text(document?.data()!['desc'],
                  style: const TextStyle(
                      fontSize:15)),
              SizedBox(height: 20,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Liked Bills :',
                      style: const TextStyle(
                          fontSize:15)),
                  SizedBox(width: 10,),
                  Text((document?.data()!['likedBillsNumber'] ?? 1 - 1).toString() ?? '',
                      style: const TextStyle(
                          fontSize:15))
                ],
              ),
              SizedBox(height: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Disliked Bills :',
                      style: const TextStyle(
                          fontSize:15)),
                  SizedBox(width: 10,),
                  Text((document?.data()!['dislikedBillsNumber'] ?? 1 -1).toString() ?? '',
                      style: const TextStyle(
                          fontSize:15))
                ],
              ),
              SizedBox(height: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Liked Reps :',
                      style: const TextStyle(
                          fontSize:15)),
                  SizedBox(width: 10,),
                  Text((document?.data()!['likedRepsNumber'] ?? 1 - 1).toString() ?? '',
                      style: const TextStyle(
                          fontSize:15))
                ],
              ),
              SizedBox(height: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Disiked Reps :',
                      style: const TextStyle(
                          fontSize:15)),
                  SizedBox(width: 10,),
                  Text((document?.data()!['dislikedRepsNumber'] ?? 1- 1).toString() ?? '',
                      style: const TextStyle(
                          fontSize:15))
                ],
              )

            ],
          ),
        );
      }
      else{
        return const Center(child: CircularProgressIndicator());
      }

    }


      )

    );
  }
}
