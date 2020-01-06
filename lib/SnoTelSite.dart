import 'package:weather_graph/constants.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_graph/mainog.dart';

class SnoTelSite {
  String name;
  String lat;
  String lng;
  String siteID;
  String uSState;
  String stationType;
  String elevation;

  SnoTelSite(
      {this.name,
      this.lat,
      this.lng,
      this.siteID,
      this.uSState,
      this.stationType,
      this.elevation});

  // SnoTelSite.fromJson(Map<String, dynamic> json) {
  //   name = json['Name'];
  //   lat = json['Lat'];
  //   lng = json['Lng'];
  //   siteID = json['SiteID'];
  //   uSState = json['USState'];
  //   stationType = json['StationType'];
  //   elevation = json['Elevation'];
  // }

  factory SnoTelSite.fromJson(Map<String, dynamic> json) {
    return SnoTelSite(
      name : json['Name'] as String,
      lat : json['Lat'] as String,
      lng : json['Lng'] as String,
      siteID : json['SiteID'] as String,
      uSState : json['USState'] as String,
      stationType : json['StationType'] as String,
      elevation : json['Elevation'] as String,
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
  
  Future<SnoTelSite> getSnoTelSiteLocations() async {
    
    // Retrieve the locations of Google offices
    final response = await http.get(snotelsitesjsonUrl);
    if (response.statusCode == 200) {
      return SnoTelSite.fromJson(json.decode(response.body));
    } else {
      throw HttpException(
          'Unexpected status code ${response.statusCode}:'
          ' ${response.reasonPhrase}',
          uri: Uri.parse(snotelsitesjsonUrl));
    }
  }
  
}

class SitesList {
  final List<SnoTelSite> sites;

  SitesList({
    this.sites,
  });
  factory SitesList.fromJson(List<dynamic> parsedJson) {

    List<SnoTelSite> sites = new List<SnoTelSite>();
    sites = parsedJson.map((i)=>SnoTelSite.fromJson(i)).toList();
    //print(sites.length);
    return new SitesList(
       sites: sites,
    );
  }
}