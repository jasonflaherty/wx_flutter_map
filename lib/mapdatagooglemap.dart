import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'SnoTelSite.dart';
import 'constants.dart';

void main() => runApp(MapDataGM());

class MapDataGM extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 6,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 6);
  final Set<Marker> _markers = Set();
  var marker = <Marker>[];
  List<SitesList> sl = [];
  List<SnoTelSite> sts = [];

  void _initMarkers() async {
    loadSites().then((sitesdata) {
      print('CM Sites Asset JSON');
      //clone sitesdata into sts array
      sts..addAll(sitesdata);
      print(sts.length);
      sts.forEach((s) {
        marker.add(Marker(
          markerId: MarkerId(s.siteID),
          position: new LatLng(double.parse(s.lat), double.parse(s.lng)),
          infoWindow: InfoWindow(title: s.name,snippet: s.siteID),
          onTap: (){
            
          }
        ));
      });
      _markers..clear()..addAll(marker);
    });
  }

  @override
  initState() {
    
    super.initState();
  }

  MapSampleState() {
_initMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: _markers),
    );
  }

  //local load assets ... constants hold path snotelsitesjson
  Future<String> _loadSiteAssets() async {
    return await rootBundle.loadString(snotelsitesjson);
  }

  Future loadSites() async {
    String jsonString = await _loadSiteAssets();
    final jsonResponse = json.decode(jsonString);
    SitesList sitesList = new SitesList.fromJson(jsonResponse);
    // for(final i in sitesList.sites){
    //   print(i.name);
    // }
    return sitesList.sites;
  }
}

//marker bottomsheet
class _MarkerPopUp extends StatelessWidget {
  //getting sid data from marker into this bottomsheet
  _MarkerPopUp({Key key, this.sitename, this.siteelevation, this.siteid}) : super(key: key);
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
