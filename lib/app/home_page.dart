import 'dart:convert';

import 'package:bill_tracker/models/Representative.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.auth}) : super(key: key);
  final AuthBase auth;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Representative>> futureReps;
  @override
  void initState() {

    super.initState();
    futureReps = fetchYourReps();
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
     List<dynamic> repList  = body['results'];

      List<Representative> reps = repList
          .map(
            (dynamic item) => Representative.fromJson(item),
      )
          .toList();
      print(reps);
      return reps;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
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
        body: Container(
          child: FutureBuilder<List<Representative>>(
            future: futureReps,
              builder: (BuildContext context, AsyncSnapshot<List<Representative>> snapshot) {
                if (snapshot.hasData) {
                  List<Representative>? reps = snapshot.data;
                  return ListView(
                    children: reps!
                        .map(
                          (Representative rep) => ListTile(
                        title: Text(rep.name),
                        subtitle: Text("${rep.id}"),
                      ),
                    )
                        .toList(),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }
          )

        )
    );
  }
}
