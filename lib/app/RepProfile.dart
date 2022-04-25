import 'package:bill_tracker/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  //Representative rep = Representative();

  void initState() {
    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
