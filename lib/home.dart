import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void initState() {
  super.initState();    
    fetchSites(http.Client());
    fetchMarkers(http.Client());
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Sites>>(
        future: fetchSites(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? SitesList(sites: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class SitesList extends StatelessWidget {
  final List<Sites> sites;
 
  SitesList({Key key, this.sites}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sites.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.ac_unit),
          title: Text('${sites[index].name}'),
          subtitle: Text('${sites[index].uSState}' + " " + '${sites[index].siteID}' + " " + '${sites[index].stationType}' + " Elevation (ft): " + '${sites[index].elevation}'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            debugPrint("PASS SOME DATA: " + '${sites[index].name}' + " " + '${sites[index].siteID}');
            showBottomSheet(
                    context: context,
                    builder: (context) => Container(
                          
                          color: Colors.red,
                          child: Text('${sites[index].name}' + " " + '${sites[index].siteID}'),
                        ));
          },
        );
      },
    );
  }
}
Future<Map<String,Marker>> fetchMarkers(http.Client client) async {
  final response =
      await client.get('http://jasonflaherty.com/snoteldata/snotelsites.json');
  // Use the compute function to run parseSites in a separate isolate.
  return compute(parseMarkers, response.body);
}

Future<List<Sites>> fetchSites(http.Client client) async {
  final response =
      await client.get('http://jasonflaherty.com/snoteldata/snotelsites.json');
  // Use the compute function to run parseSites in a separate isolate.
  return compute(parseSites, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Sites> parseSites(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<Sites> parsedsiteslist = parsed.map<Sites>((json) => Sites.fromJson(json)).toList();
  
  parsedsiteslist.sort((a, b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  debugPrint("SITES " + parsedsiteslist.length.toString());
    return parsedsiteslist;

}
Map<String, Marker> parseMarkers(String responseBody) {
  final Map<String, Marker> _markers = {};
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<Sites> parsedsiteslist = parsed.map<Sites>((json) => Sites.fromJson(json)).toList();
       _markers.clear();
      for (final site in parsedsiteslist) {
        final marker = Marker(
          markerId: MarkerId(site.name),
          position: LatLng(double.parse(site.lat), double.parse(site.lng)),
          infoWindow: InfoWindow(
            title: site.name,
            snippet: site.siteID,
          ),
        );
        _markers[site.name] = marker;
      }
  debugPrint("markers " + _markers.length.toString());
  return _markers;
}


class Sites {
  String name;
  String lat;
  String lng;
  String siteID;
  String uSState;
  String stationType;
  String elevation;

  Sites(
      {this.name,
      this.lat,
      this.lng,
      this.siteID,
      this.uSState,
      this.stationType,
      this.elevation});

  factory Sites.fromJson(Map<String, dynamic> json) {
    return Sites(
      name: json['Name'],
      lat: json['Lat'],
      lng: json['Lng'],
      siteID: json['SiteID'],
      uSState: json['USState'],
      stationType: json['StationType'],
      elevation: json['Elevation'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Name'] = this.name;
    data['Lat'] = this.lat;
    data['Lng'] = this.lng;
    data['SiteID'] = this.siteID;
    data['USState'] = this.uSState;
    data['StationType'] = this.stationType;
    data['Elevation'] = this.elevation;
    return data;
  }
}