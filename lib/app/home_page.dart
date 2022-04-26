import 'dart:convert';

import 'package:bill_tracker/app/UserProfile.dart';
import 'package:bill_tracker/models/Representative.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../common_widgets/custom_raised_button.dart';
import '../models/Bill.dart';
import '../services/auth.dart';
import 'dart:math';

import 'BillList.dart';
import 'RepsList.dart';
import 'RepProfile.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.auth}) : super(key: key);
  final AuthBase auth;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Representative>> futureReps;
  late Future<List<Representative>> futureYourReps;
  late Future<List<Bill>> futureBills;

  void fetchRepProfile(String id){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => RepProfile(auth: widget.auth, repId: id,),
      ),
    );
  }
  @override
  void initState() {

    super.initState();
    futureReps = fetchReps(); // set futureReps to the function that returns a list of reps
    futureYourReps = fetchYourReps();
    futureBills = fetchLatestBills();
  }
  Future<List<Bill>> fetchLatestBills() async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'X-API-Key' : 'V2q4gUN0KXw5Ew1Wl29Z2Av5Y39EjME7VFXj2d2c'
    };
    final response = await http.get(
      Uri.parse('https://api.propublica.org/congress/v1/117/senate/bills/passed.json'),
      // Send authorization headers to the backend.
      headers: requestHeaders,
    );
    if (response.statusCode == 200) {
      List<dynamic> billList = new List.filled(1, 0);
      try{
          final body = jsonDecode(response.body);
          billList  = body['results'][0]['bills'];
          //debugPrint(response.body.toString());

        }catch(e){
          print(e);
        }



      List<Bill> bills = billList
          .map(
            (dynamic item) => Bill.fromJson(item),
      )
          .toList();

      return bills;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load bills');
    }
  }
  Future<List<Representative>> fetchReps() async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'X-API-Key' : 'V2q4gUN0KXw5Ew1Wl29Z2Av5Y39EjME7VFXj2d2c'
    };
    final response = await http.get(
      Uri.parse('https://api.propublica.org/congress/v1/116/senate/members.json'),
      // Send authorization headers to the backend.
      headers: requestHeaders,
    );
    if (response.statusCode == 200) {

      final body = jsonDecode(response.body);
      List<dynamic> repList  = body['results'][0]['members'];
      List<Representative> reps = repList
          .map(
            (dynamic item) => Representative.fromJson(item),
      ).toList();

      return reps;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load reps');
    }
  }
  void _showBillList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => BillList(auth: widget.auth, futureBills: futureBills,),
      ),
    );
  }
  void _showRepsList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => RepsList(auth: widget.auth, futureReps: futureReps,),
      ),
    );
  }


  Future<List<Representative>> fetchYourReps() async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'X-API-Key' : 'V2q4gUN0KXw5Ew1Wl29Z2Av5Y39EjME7VFXj2d2c'
    };
    final response = await http.get(
      Uri.parse('https://api.propublica.org/congress/v1/members/senate/GA/current.json'),
      // Send authorization headers to the backend.
      headers: requestHeaders,
    );
    if (response.statusCode == 200) {

      final body = jsonDecode(response.body);
      //print(response.body);
     List<dynamic> repList  = body['results'];

      List<Representative> reps = repList
          .map(
            (dynamic item) => Representative.fromJson(item),
      )
          .toList();

      return reps;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load reps');
    }
  }
  void _showUserProfile(){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => UserProfile(auth: widget.auth),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                IconButton(
                    onPressed: () => widget.auth.signOut(),
                    icon: const Icon(Icons.first_page, size: 30)),
                Text("BillTracker"),
                IconButton(
                    onPressed: () => {_showUserProfile()},
                    icon: const Icon(Icons.person_outline_rounded, size: 30)),

              ],
            )
        ),
        body:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            FutureBuilder<List<Representative>>(
                future: futureYourReps,
                builder: (BuildContext context, AsyncSnapshot<List<Representative>> snapshot) {
                  if (snapshot.hasData) {
                    List<Representative>? reps = snapshot.data;
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          Row(
                            children: [
                              const Text("Your Reps",style: TextStyle(fontSize: 20),),
                              const SizedBox(width: 10),
                              RichText(
                                  text: TextSpan(text:"See All",
                                    style: TextStyle(fontSize: 10, color: Colors.blue),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () {
                                        _showRepsList(context);
                                      },

                                  )
                              ),

                            ],
                          ),


                          Row(
                            children: reps!
                                .map(
                                  (Representative rep) => Card(
                                  color: Colors.white70,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.network("https://theunitedstates.io/images/congress/original/"+rep.id+".jpg",
                                        height: 100.0, width: 100.0,),
                                      const SizedBox(height: 5),
                                      CustomRaisedButton(child:Text(rep.name),color: Colors.blue,onPressed:()=>{ fetchRepProfile(rep.id)},)
                                    ],
                                  )
                              ),
                            )
                                .toList(),
                          )
                        ]);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }
            ),
            FutureBuilder<List<Bill>>(
                future: futureBills,
                builder: (BuildContext context, AsyncSnapshot<List<Bill>> snapshot) {
                  if (snapshot.hasData) {
                    List<Bill>? bills = snapshot.data;
                    Random random = Random();
                    int randomNumber = random.nextInt(20);
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          Row(
                            children: [
                              const Text("Bills",style: TextStyle(fontSize: 20),),
                              const SizedBox(width: 10),
                              RichText(
                                text: TextSpan(text:"See All",
                                  style: TextStyle(fontSize: 10, color: Colors.blue),
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () {
                                      _showBillList(context);
                                    },

                                )
                              ),

                            ],
                          ),

                          const SizedBox(height: 10),
                          Card(
                            color: Colors.white,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:[
                                  Row(
                                    children: [
                                    const Icon(Icons.calendar_today, size: 20),
                                      SizedBox(width: 10,),
                                      Text(bills![randomNumber].introduced_date ?? '')
                                    ]
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(bills![randomNumber].short_title,style: TextStyle(fontWeight: FontWeight.bold),),
                                  const SizedBox(height: 10,),
                                  Text(bills![randomNumber].title),
                                  const SizedBox(height: 10,),
                                  Text("Sponsored By :",style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10,),
                                  Row(
                                    children: [
                                      ClipRRect(
                                      borderRadius: BorderRadius.circular(50.0),
                                        child: Image.network("https://theunitedstates.io/images/congress/original/"+bills![randomNumber].sponsor_id!+".jpg",
                                          height: 70.0, width: 70.0,),
                                      ),

                                      Text(bills![randomNumber].sponsor_name!)

                                    ],
                                  )


                                ]


                             )
                          )
                        ]);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }
            )

          ],
        )

    );
  }
}
