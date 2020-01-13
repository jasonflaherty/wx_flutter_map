import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:weather_graph/constants.dart';
import 'package:weather_graph/mainog.dart';

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

Future<List<String>> nrcsCSVData() async {
  String url1 =
      "http://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customSingleStationReport/daily/";
  String url2 =
      ":SNTL%7Cid=%22%22%7Cname/-6,0/TOBS::value,TMAX::value,TMIN::value,SNWD::value,SNWD::prevValue,WTEQ::value,PREC::value,elevation";

  String SiteCSVUrl = url1 + "1000:OR" + url2;

  var from = "N/A";
  String csvdocinstring;
  List<String> lines;
  List<String> siteData = List<String>();
  FileInfo fileInfo;
  String error;
  File csvFile;

  DefaultCacheManager().getFile(SiteCSVUrl).listen((f) {
    if (fileInfo != null) {
      from = fileInfo.file.path;
      csvFile = new File(from);
      lines = csvFile.readAsLinesSync();
      lines.forEach((l) {
        print(l[0]);
        if (l[0] != "#") {
          siteData.add(l);
        }
      });
    }
  });
  return siteData;
}

class NrcsData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'NRCS Data',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new NoaaApiData(),
    );
  }
}

class NoaaApiData extends StatefulWidget {
  NoaaApiData({Key key}) : super(key: key);

  @override
  _NoaaApiDataState createState() => _NoaaApiDataState();
}

class _NoaaApiDataState extends State<NoaaApiData> {
  FileInfo fileInfo;
  String error;
  File data;
  _downloadFile() {
    String url1 =
        "http://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customSingleStationReport/daily/";
    String url2 =
        ":SNTL%7Cid=%22%22%7Cname/-6,0/TOBS::value,TMAX::value,TMIN::value,SNWD::value,SNWD::prevValue,WTEQ::value,PREC::value,elevation";

    String SiteCSVUrl = url1 + "1000:OR" + url2;

    DefaultCacheManager().getFile(SiteCSVUrl).listen((f) {
      setState(() {
        fileInfo = f;
        error = null;
      });
    }).onError((e) {
      setState(() {
        fileInfo = null;
        error = e.toString();
      });
    });
  }

  @override
  initState() {
    super.initState();
    nrcsCSVData();
    //_downloadFile();
    // Add listeners to this class
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder(
      future: nrcsCSVData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return new Text("connection state none");
          case ConnectionState.waiting:
            return new Text('loading...');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return createListView(context, snapshot);
        }
      },
    );
    return Scaffold(appBar: AppBar(title: Text("Site")), body: futureBuilder);
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<String> values = snapshot.data;
    print(snapshot.toString());
    return new ListView.builder(
      itemCount: values.length,
      itemBuilder: (BuildContext context, int index) {
        return new Column(
          children: <Widget>[
            new ListTile(
              title: new Text(values[index]),
            ),
            new Divider(
              height: 2.0,
            ),
          ],
        );
      },
    );
  }
}
