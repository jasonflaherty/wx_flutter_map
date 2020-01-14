import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:weather_graph/constants.dart';
import 'package:weather_graph/mainog.dart';
import 'package:weather_graph/map.dart';

Future<String> noaaData() async {
  var headers = {
    'token': noaacdcToken,
  };

//example:
//data?datasetid=PRECIP_15&stationid=COOP:010008&units=metric&startdate=2010-05-01&enddate=2010-05-31
  String datastring =
      "data?datasetid=GHCND&locationid=ZIP:28801&startdate=2010-05-01&enddate=2010-05-01";
  var res = await http.get(
      noaacdc + "stations?datatypeid=EMNT&datatypeid=EMXT&datatypeid=HTMN",
      headers: headers);
  if (res.statusCode != 200)
    throw Exception('get error: statusCode= ${res.statusCode}');
  //print(res.body);
  return res.body;
}

class NrcsData extends StatelessWidget {
  const NrcsData(
      {Key key, this.sitestate, this.sitename, this.siteelevation, this.siteid})
      : super(key: key);

  final String sitename, siteelevation, siteid, sitestate;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: sitename,
      theme: new ThemeData(
        primarySwatch: Colors.cyan,
        textTheme: GoogleFonts.muliTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: new NoaaApiData(
          siteid: siteid,
          sitestate: sitestate,
          siteelevation: siteelevation,
          sitename: sitename),
    );
  }
}

class NoaaApiData extends StatefulWidget {
  NoaaApiData(
      {Key key, this.siteid, this.sitestate, this.siteelevation, this.sitename})
      : super(key: key);
  final siteid, siteelevation, sitestate, sitename;
  @override
  _NoaaApiDataState createState() => _NoaaApiDataState();
}

class _NoaaApiDataState extends State<NoaaApiData> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder(
      future: nrcsCSVData(widget.siteid, widget.sitestate),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new Text('loading data...');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return createLayout(context, snapshot);
        }
      },
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Icon(Icons.ac_unit),
        title: Text(widget.sitename),
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
      body: SingleChildScrollView(child: futureBuilder),
    );
  }

//get the csv data into a list
  Future<List<String>> nrcsCSVData(String sid, String sstate) async {
    String url1 =
        "http://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customSingleStationReport/hourly/";
    String url2 =
        ":SNTL%7Cid=%22%22%7Cname/-6,0/TOBS::value,TMAX::value,TMIN::value,SNWD::value,SNWD::prevValue,WTEQ::value,PREC::value,elevation";

    String SiteCSVUrl = url1 + sid + ":" + sstate + url2;
    List<String> lines;
    final siteData = new List<String>();
    File csvFile;
    print("async file from nrcs report generator");
    var data = await DefaultCacheManager().getSingleFile(SiteCSVUrl);
    csvFile = new File(data.path);
    lines = csvFile.readAsLinesSync();
    //loop through each result skipping commented lines
    lines.forEach((l) {
      if (l[0] != "#") {
        siteData.add(l);
      }
    });
    return siteData;
  }

  Widget createLayout(BuildContext context, AsyncSnapshot snapshot) {
    //Date, TempObs(F), TempMax, TempMin, SnowDepth(in),SnowDepth(PrevYear),SWE(in)
    var csv = List();
    List<String> val = snapshot.data;
    for (final v in val) {
      print(v.split(","));
      csv.add(v.split(","));
    }
    //get this # so we get the most recent value for the updated date
    int lastrecord = csv.length - 1;
    return Container(
      color: Colors.black12,
      child: Column(
        children: <Widget>[
          // Container(
          //   width: MediaQuery.of(context).size.width,
          //   color: Colors.redAccent,
          //   child: Center(
          //     child: Padding(
          //       padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
          //       child: Text("Elevation: ${widget.siteelevation}ft - Updated: " +
          //           csv[lastrecord][0]),
          //     ),
          //   ),
          // ),
          Container(
            height: 200.0,
            width: MediaQuery.of(context).size.width,
            child: FadeInImage.assetNetwork(
              fit: BoxFit.cover,
              placeholder: "assets/images/wallows.jpg",
              image:
                  "https://lh3.googleusercontent.com/xdNgtIUkktVc2exkG2NIR0WKcNHtAaJKBOv3HAm9r6uNCzlq9Lkeo6ZhrqZRXtWIWsQd-Aq1R1aBbQRK8cwcx6zAn3Hy4tJ4b3QK9GMVuIosk82ubRKzDrEwzS-Ju2Sim4qSSeJx1YA=s733-no",
              imageSemanticLabel: "Image of the Mountains",
            ),
          ),
          Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0.0, -5.0),
                    blurRadius: 3.0,
                  ),
                ],
              ),
              transform: Matrix4.translationValues(0.0, -35.0, 0.0),
              width: MediaQuery.of(context).size.width - 20,
              height: 500,
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.redAccent,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(5, 8, 5, 8),
                        child: Text(
                            "Elevation: ${widget.siteelevation}ft - Updated: " +
                                csv[lastrecord][0]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: <Widget>[
                        //Date, TempObs(F), TempMax, TempMin, SnowDepth(in),SnowDepth(PrevYear),SWE(in)
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Text("Snow Depth"),
                                  Text(csv[lastrecord][5]),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text("Snow Depth \n (Last Year)"),
                                  Text(csv[lastrecord][6]),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text("Snow Depth \n (Last Year)"),
                                  Text(csv[lastrecord][1]),
                                ],
                              ),
                            ]),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[]),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );

    // return SingleChildScrollView(
    //   child: Row(children: <Widget>[
    //     Text("Date: " + csv[1][0]),
    //     Text("Current Temp (degF): " + csv[1][1]),
    //     Text("Snow Depth: " + csv[1][5]),
    //     //for (final i in val) Text(i),
    //   ]),
    // );
  }
}
