import 'package:bill_tracker/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/Bill.dart';

class BillList extends StatefulWidget {
  BillList({required this.auth, required this.futureBills});
  final AuthBase auth;
  late Future<List<Bill>> futureBills;

  @override
  _BillListState createState() => _BillListState();
}

class _BillListState extends State<BillList> {
  late Future<List<String>> likedBillsFuture;
  List<String> likedBills = List<String>.empty();
  late Future<List<String>> dislikedBillsFuture;
  List<String> dislikedBills = List<String>.empty();

  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    likedBillsFuture = _getLikedBills();
    likedBillsFuture.then((value) => likedBills = value);
    dislikedBillsFuture = _getDislikedBills();
    dislikedBillsFuture.then((value) => dislikedBills = value);
  }

  Future<List<String>> _getDislikedBills() async {
    DocumentSnapshot documentSnapshot =
        await _users.doc(widget.auth.currentUser?.uid).get();

    Map<String, dynamic>? data = documentSnapshot.data();
    String prevDisikedBills = data!['dislikedBills'] ?? '';
    return prevDisikedBills.split(',');
  }

  Future<List<String>> _getLikedBills() async {
    DocumentSnapshot documentSnapshot =
        await _users.doc(widget.auth.currentUser?.uid).get();

    Map<String, dynamic>? data = documentSnapshot.data();
    String prevLikedBills = data!['likedBills'] ?? '';
    return prevLikedBills.split(',');
  }

  void likeABill(String bill_id) async {
    if (!likedBills.contains(bill_id)) {
      String prevLikedBills = likedBills.join(',');
      prevLikedBills = prevLikedBills + ',' + bill_id;

      _users
          .doc(widget.auth.currentUser?.uid)
          .update({'likedBills': prevLikedBills});
      likedBills.add(bill_id);
      setState(() {
        likedBills;
      });
    } else {
      likedBills.remove(bill_id);
      String newLikedBills = likedBills.join(",");
      _users
          .doc(widget.auth.currentUser?.uid)
          .update({'likedBills': newLikedBills});

      setState(() {
        likedBills;
      });
    }
  }

  void dislikeABill(String bill_id) async {
    if (!dislikedBills.contains(bill_id)) {
      String prevDisikedBills = dislikedBills.join(',');
      prevDisikedBills = prevDisikedBills + ',' + bill_id;

      _users
          .doc(widget.auth.currentUser?.uid)
          .update({'dislikedBills': prevDisikedBills});
      dislikedBills.add(bill_id);
      setState(() {
        dislikedBills;
      });
    } else {
      dislikedBills.remove(bill_id);
      String newDislikedBills = dislikedBills.join(",");
      _users
          .doc(widget.auth.currentUser?.uid)
          .update({'dislikedBills': newDislikedBills});

      setState(() {
        dislikedBills;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills'),
        elevation: 2.0,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Bill>>(
              future: widget.futureBills,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Bill>> snapshot) {
                if (snapshot.hasData) {
                  List<Bill>? bills = snapshot.data;

                  return SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: bills!
                            .map((Bill bill) => Card(
                                color: Colors.white,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        const Icon(Icons.calendar_today,
                                            size: 20),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(bill.introduced_date ?? '')
                                      ]),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        bill.short_title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(bill.title),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text("Sponsored By :",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50.0),
                                            child: Image.network(
                                              "https://theunitedstates.io/images/congress/original/" +
                                                  bill.sponsor_id! +
                                                  ".jpg",
                                              height: 70.0,
                                              width: 70.0,
                                            ),
                                          ),
                                          Text(bill.sponsor_name!)
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          FutureBuilder<List<String>>(
                                              future: likedBillsFuture,
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<List<String>>
                                                      snapshot) {
                                                if (snapshot.hasData) {
                                                  return IconButton(
                                                      onPressed: () =>
                                                          likeABill(
                                                              bill.bill_id),
                                                      icon: likedBills.contains(
                                                              bill.bill_id)
                                                          ? const Icon(
                                                              Icons.thumb_up,
                                                              size: 15)
                                                          : const Icon(
                                                              Icons
                                                                  .thumb_up_outlined,
                                                              size: 15));
                                                } else {
                                                  return IconButton(
                                                      onPressed: () =>
                                                          likeABill(
                                                              bill.bill_id),
                                                      icon: const Icon(
                                                          Icons
                                                              .thumb_up_outlined,
                                                          size: 15));
                                                }
                                              }),
                                          FutureBuilder<List<String>>(
                                              future: dislikedBillsFuture,
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<List<String>>
                                                      snapshot) {
                                                if (snapshot.hasData) {
                                                  return IconButton(
                                                      onPressed: () =>
                                                          dislikeABill(
                                                              bill.bill_id),
                                                      icon: dislikedBills
                                                              .contains(
                                                                  bill.bill_id)
                                                          ? const Icon(
                                                              Icons.thumb_down,
                                                              size: 15)
                                                          : const Icon(
                                                              Icons
                                                                  .thumb_down_outlined,
                                                              size: 15));
                                                } else {
                                                  return IconButton(
                                                      onPressed: () =>
                                                          dislikeABill(
                                                              bill.bill_id),
                                                      icon: const Icon(
                                                          Icons
                                                              .thumb_down_outlined,
                                                          size: 15));
                                                }
                                              }),
                                          IconButton(
                                              onPressed: () =>
                                              {},
                                              icon: const Icon(Icons.comment,
                                                      size: 15)
                                          )

                                        ],
                                      )
                                    ])))
                            .toList()),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              })),
      backgroundColor: Colors.grey[200],
    );
  }
}
