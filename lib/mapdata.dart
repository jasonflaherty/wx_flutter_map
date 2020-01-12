import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
import 'package:weather_graph/SnoTelSite.dart';
import 'package:weather_graph/constants.dart';

class MapData extends StatefulWidget {
  MapData({Key key}) : super(key: key);

  @override
  _MapDataState createState() => _MapDataState();
}

class _MapDataState extends State<MapData> {
  List<SitesList> sl = [];
  List<SnoTelSite> sts = [];
  var marker = <Marker>[];

  @override
  initState() {
    print("INIT STATE");
    super.initState();
    loadSites().then((sitesdata) {
      print('Loaded Sites Asset JSON');
      //clone sitesdata into sts array
      sts..addAll(sitesdata);
      sts.forEach((s) {
        marker.add(
          Marker(
            point: new LatLng(double.parse(s.lat), double.parse(s.lng)),
            builder: (ctx) => _MarkerPopUp(
              sitename: s.name,
              siteelevation: s.elevation,
              siteid: s.siteID,
            ),
          ),
        );
      });
      setState(() {
        print("adding markers ... setstate");
        marker = marker;
      });
    });
  }

  //local load assets ... constants hold path snotelsitesjson
  Future<String> _loadSiteAssets() async {
    return await rootBundle.loadString(snotelsitesjson);
  }

  Future loadSites() async {
    String jsonString = await _loadSiteAssets();
    final jsonResponse = json.decode(jsonString);
    SitesList sitesList = new SitesList.fromJson(jsonResponse);
    return sitesList.sites;
  }

//main build and screen layout
  @override
  Widget build(BuildContext context) {
    print("BUILD LAYOUT");
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: Icon(Icons.ac_unit),
            title: Text("SnoTel Map"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  debugPrint("Favorites");
                },
              ),
              IconButton(
                icon: Icon(Icons.feedback),
                onPressed: () {
                  debugPrint("Message sent");
                },
              ),
            ],
          ),
          body: _MapWidget(marker: marker)),
    );
  }
}

//map widget
class _MapWidget extends StatelessWidget {
//const so flutter doesn't rebuild it each time...
  const _MapWidget({this.marker});

  final List<Marker> marker;
  final SiteID sid = null;
  final Sites site = null;

  @override
  Widget build(BuildContext context) {
    print("add map");
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
        new MarkerLayerOptions(markers: marker),
      ],
    );
  }
}

//marker bottomsheet
class _MarkerPopUp extends StatelessWidget {
  //getting sid data from marker into this bottomsheet
  _MarkerPopUp({Key key, this.sitename, this.siteelevation, this.siteid})
      : super(key: key);
  final String sitename, siteelevation, siteid;

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
                            "ID: $siteid : $siteelevation : $sitename",
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

class SiteID {
  final String sid;
  SiteID(this.sid);
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
