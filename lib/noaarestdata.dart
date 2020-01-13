import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:weather_graph/constants.dart';

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

Future<String> noaaCSVData() async {
  String csvurl =
      "https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customMultiTimeSeriesGroupByStationReport/hourly/start_of_period/343:OR:SNTL%7Cid=%22%22%7Cname/-167,0/SNWD::value,WTEQ::value,WTEQ::qcFlag";

  var csvdata = await DefaultCacheManager().getSingleFile(csvurl);

  //var csvdata = await http.get(csvurl);
  print(csvdata);
  return csvdata.toString();
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
    String csvurl =
        "https://wcc.sc.egov.usda.gov/reportGenerator/view_csv/customMultiTimeSeriesGroupByStationReport/hourly/start_of_period/343:OR:SNTL%7Cid=%22%22%7Cname/-167,0/SNWD::value,WTEQ::value,WTEQ::qcFlag";

    DefaultCacheManager().getFile(csvurl).listen((f) {
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
    _downloadFile();
    // Add listeners to this class
  }

  @override
  Widget build(BuildContext context) {
    var from = "N/A";
    if(fileInfo != null){
      from = fileInfo.toString();
      File(from).readAsString().then((c) => print(c));
    }
    return MaterialApp(home: _ResResults());
  }
}

class _ResResults extends StatelessWidget {
  const _ResResults({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          alignment: Alignment(0, 0),
          color: Colors.black,
          child: FutureBuilder<String>(
            future: noaaCSVData(), // a Future<String> or null
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return new Text('Press button to start');
                case ConnectionState.waiting:
                  return new Text('Awaiting result...');
                default:
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  else
                    return new Text(
                      'Result: ${snapshot.data}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    );
              }
            },
          ),
        ),
      ),
    );
  }
}
