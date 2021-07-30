import 'package:feed_me_flutter_inclass/services/business.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:feed_me_flutter_inclass/services/location.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Future<List<Business>> _futureData;

// returns a Future asynchronously
  Future<List<Business>> _fetchBusinessList() async {
    await DotEnv.load(fileName: ".env");
    Location location = Location();
    await location.getLocation();
    print("Location: ${location.latitude} :  ${location.longitude}");
    var response = await http.get(
      'https://api.yelp.com/v3/businesses/search' +
          "?&latitude=${location.latitude}&longitude=${location.longitude}",
      headers: {
        HttpHeaders.authorizationHeader: "Bearer ${DotEnv.env['API_KEY']}"
      },
    );

    // get the businesses from the response
    Iterable decodedData = jsonDecode(response.body)['businesses'];

// extract the names to a list
    List<Business> businesses = decodedData
        .map((businessJson) => Business.fromJson(businessJson))
        .toList();

    return businesses;
  }

  @override
  void initState() {
    super.initState();
    // hit API and assign value ONCE when widget is added to the tree
    _futureData = _fetchBusinessList();
  }

// render the future to the screen via FutureBuilder
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Business>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Column(children: <Widget>[
                    Container(
                      height: 120.0,
                      width: 120.0,
                      decoration: new BoxDecoration(
                        image: DecorationImage(
                          image: new NetworkImage(
                              '${snapshot.data[index].image_url}'),
                          fit: BoxFit.fill,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Card(
                      child: Text('${snapshot.data[index].name}'),
                    )
                  ]);
                });
          } else if (snapshot.hasError) {
            return Text(snapshot.error);
          }
          // default show a loading spinner
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
