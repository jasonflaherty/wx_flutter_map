import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';

class MapSites extends StatelessWidget {
  const MapSites({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            //setting the icon for the AppBar
            leading: Icon(Icons.ac_unit),
            //setting title for the AppBar
            title: Text("SnoTel Map"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  //Handling click on the action items
                  debugPrint("Favorites");
                },
              ),
              //Setting IconButton action item to send message
              IconButton(
                icon: Icon(Icons.feedback),
                onPressed: () {
                  //Handling click on the action items
                  debugPrint("Message sent");
                },
              ),
              //Setting Overflow action items using PopupMenuButton
            ],
          ),
          body: _MapWidget()),
    );
  }
}

class SiteID {
  final String sid;
  SiteID(this.sid);
}

//const so flutter doesn't rebuild it each time...
class _MapWidget extends StatelessWidget {
  const _MapWidget();
  final SiteID sid = null;
  final Sites s = null;
  @override
  Widget build(BuildContext context) {
    var parsedMarkers = <Marker>[
      new Marker(
        point: new LatLng(40.1, -120),
        builder: (ctx) => _MarkerPopUp(sid: "999"),
      ),
      new Marker(
        point: new LatLng(40.5, -120),
        builder: (ctx) => _MarkerPopUp(sid: "888"),
      ),
    ];

    return new FlutterMap(
      options: new MapOptions(
        center: new LatLng(40.0, -120.0),
        zoom: 8.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
          subdomains: ['a', 'b', 'c'],
          tileProvider: CachedNetworkTileProvider(),
        ),
        new MarkerLayerOptions(markers: parsedMarkers),
      ],
    );
  }
}

class _MarkerPopUp extends StatelessWidget {
  //getting sid data from marker into this bottomsheet
  _MarkerPopUp({Key key, this.sid}) : super(key: key);
  final String sid;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
            child: Container(
          child: FloatingActionButton(
            onPressed: () {
              showBottomSheet(
                context: context,
                builder: (context) => Container(
                    height: 500,
                    color: Colors.blueGrey,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            "ID: $sid",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                        ),
                      ],
                    )),
              );
            },
            child: Icon(
              Icons.ac_unit,
              color: Colors.white,
            ),
            backgroundColor: Colors.cyan,
          ),
        )),
      ),
    ]);
  }
}

Future<List<Sites>> fetchSites(http.Client client) async {
  final response =
      await client.get('http://jasonflaherty.com/snoteldata/snotelsites.json');
  // Use the compute function to run parseSites in a separate isolate.
  return compute(parseSites, response.body);
}

List<Sites> parseSites(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<Sites> parsedsiteslist =
      parsed.map<Sites>((json) => Sites.fromJson(json)).toList();

  parsedsiteslist.sort((a, b) {
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  debugPrint("PSITES " + parsedsiteslist.length.toString());
  return parsedsiteslist;
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
