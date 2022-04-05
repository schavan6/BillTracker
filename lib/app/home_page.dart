import 'dart:convert';

import 'package:bill_tracker/models/Representative.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../common_widgets/custom_raised_button.dart';
import '../models/Bill.dart';
import '../services/auth.dart';
import 'package:flutter/foundation.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.auth}) : super(key: key);
  final AuthBase auth;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Representative>> futureReps;
  late Future<List<Bill>> futureBills;

  void fetchRepProfile(){

  }
  @override
  void initState() {

    super.initState();
    futureReps = fetchYourReps();
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
          debugPrint(response.body.toString());

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

              ],
            )),
        body:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Representative>>(
                future: futureReps,
                builder: (BuildContext context, AsyncSnapshot<List<Representative>> snapshot) {
                  if (snapshot.hasData) {
                    List<Representative>? reps = snapshot.data;
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[

                          const Text("Your Reps",style: TextStyle(fontSize: 20),),
                          const SizedBox(height: 10),
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
                                      CustomRaisedButton(child:Text(rep.name),color: Colors.blue,onPressed: fetchRepProfile,)
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
                    print(bills![0].bill_id);
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          const Text("Bills",style: TextStyle(fontSize: 20),),
                          const SizedBox(height: 10),
                          Card(
                            color: Colors.white70,
                            child: Text(bills![0].title)
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
