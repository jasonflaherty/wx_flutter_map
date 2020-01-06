import 'dart:async';
import 'dart:async' show Future;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:weather_graph/SnoTelSite.dart';
import 'package:weather_graph/constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BuildContext context;
  int _currentIndex = 0;
  final List<Widget> _children = [MapView(), SiteData()];

  final Map<String, Marker> _markers = {};
  
  Completer<GoogleMapController> _controller = Completer();

  // void _onMapCreated(GoogleMapController controller) {
  //   _controller.complete(controller);
  // }

// A function that converts a response body into a List<Photo>.
List<SnoTelSite> parseSnoTelSites(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<SnoTelSite>((json) => SnoTelSite.fromJson(json)).toList();
}

Future<List<SnoTelSite>> fetchSnoTelSites(http.Client client) async {
  final response =
      await client.get(snotelsitesjsonUrl);

  return parseSnoTelSites(response.body);
}

// Future<void> _onMapCreated(GoogleMapController controller) async {
//     final sts = await ;
//     setState(() {
//       _markers.clear();
//       for (final site in sts) {
//         final marker = Marker(
//           markerId: MarkerId(site.name),
//           position: LatLng(site.lat, site.lng),
//           infoWindow: InfoWindow(
//             title: site.name,
//             snippet: site.address,
//           ),
//         );
//         _markers[site.name] = marker;
//       }
//     });
//   }

  @override
  void initState() {
    super.initState();
     fetchSnoTelSites(http.Client());
    
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnoTel Data',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          title: Text('SnoTel Map'),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.map),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapView()),
                );
              },
            ),
            // action button
            IconButton(
              icon: Icon(Icons.warning),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WarningsMap()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SiteData()),
                );
              },
            ),
          ],
        ),
        body: MapView(),
        //_children[_currentIndex],
      ),
    );
  }
}

//bottom nav

// bottomNavigationBar: BottomNavigationBar(
//           backgroundColor: Colors.blueGrey,
//           type: BottomNavigationBarType.shifting,
//           onTap: onTabTapped,
//           currentIndex: _currentIndex,
//           items: [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.ac_unit, color: Color.fromARGB(255, 0, 0, 0)),
//               title: new Text(''),
//             ),
//             BottomNavigationBarItem(
//                 icon:
//                     Icon(Icons.ac_unit, color: Color.fromARGB(255, 0, 0, 0)),
//                 title: new Text('')),
//             BottomNavigationBarItem(
//                 icon:
//                     Icon(Icons.ac_unit, color: Color.fromARGB(255, 0, 0, 0)),
//                 title: new Text('')),
//           ],
//         )),

//SHOWS MAP OF ALL SITES
class MapView extends StatelessWidget {
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _locMtBaker = CameraPosition(
    target: LatLng(48.8572916, -121.6666619),
    zoom: 7,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GoogleMap(
        mapType: MapType.terrain,
        initialCameraPosition: _locMtBaker,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationEnabled: true,
      ),
    );
  }
}

class SnotelMap extends StatelessWidget {
  const SnotelMap({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text("NOTHING");
  }
}

class WarningsMap extends StatelessWidget {
  const WarningsMap({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Warning Map'),
    );
  }
}

//SHOWS SITE DATA LAYOUT
class SiteData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Column(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    FadeInImage.assetNetwork(
                      imageSemanticLabel: "Image of the Mountains",
                      image: 'https://source.unsplash.com/weekly?ski',
                      placeholder: 'assets/images/wallows-nate.gif',
                      fit: BoxFit.fitWidth,
                      height: 200,
                    ),
                  ],
                ),
                Container(
                  //NEGATIVE MARGIN!
                  transform: Matrix4.translationValues(0.0, -200.0, 0.0),
                  alignment: Alignment(-1.0, -1.0),
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        // When the user taps the button, show a snackbar.
                        child: Container(
                          color: Colors.red,
                          padding: EdgeInsets.all(3.0),
                          child: IconButton(
                            icon: Icon(Icons.add),
                            color: Colors.white,
                            onPressed: () {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Send Area Report'),
                              ));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black87,
                          offset: Offset(0, 0),
                          blurRadius: 5,
                          spreadRadius: 1)
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  //NEGATIVE MARGIN!
                  transform: Matrix4.translationValues(0.0, -120.0, 0.0),
                  padding:
                      EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15),
                  margin:
                      EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 15),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "8\u00b0",
                                      style: TextStyle(
                                          fontFamily: 'Open Sans',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[Text("TEMP")],
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "6%",
                                      style: TextStyle(
                                          fontFamily: 'Open Sans',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[Text("SNWE")],
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "25\"",
                                      style: TextStyle(
                                          fontFamily: 'Open Sans',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[Text("NEW SNOW")],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "-2\u00b0/15\u00b0",
                                      style: TextStyle(
                                          fontFamily: 'Open Sans',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[Text("LO/HI TEMP")],
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "8MPH",
                                      style: TextStyle(
                                          fontFamily: 'Open Sans',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[Text("WIND")],
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "110\"",
                                      style: TextStyle(
                                          fontFamily: 'Open Sans',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[Text("SNOW DEPTH")],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.all(15),
                          child: FadeInImage.assetNetwork(
                              placeholder:
                                  "assets/images/stacked_area_custom_color_full.png",
                              image:
                                  "assets/images/stacked_area_custom_color_full.png"),
                        ),
                        Container(
                          margin: EdgeInsets.all(15),
                          child: Text(
                              "Mauris a risus sagittis, semper dolor nec, feugiat neque. Suspendisse rhoncus egestas orci ut sollicitudin. Suspendisse consectetur laoreet lectus, quis ullamcorper ex aliquam vitae. Vivamus felis ipsum, convallis at facilisis sed, molestie id ipsum. Etiam et est quam. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.",
                              style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal)),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HeaderWidget extends StatelessWidget {
  final String text;

  HeaderWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text(text),
      color: Colors.grey[200],
    );
  }
}

class BodyWidget extends StatelessWidget {
  final Color color;

  BodyWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      color: color,
      alignment: Alignment.center,
    );
  }
}
