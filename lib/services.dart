import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
