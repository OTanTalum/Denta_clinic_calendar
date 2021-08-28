import 'package:flutter/material.dart';

class DentaEvent {
  DentaEvent({
    this.eventName,
    this.phone,
    this.surName,
    this.name,
    this.duration,
    this.from,
    this.to
  });

  String surName ;
  String name ;
  String phone ;
  String duration;
  String eventName;
  DateTime from;
  DateTime to;


  DentaEvent.fromJson(json){
    name=json["name"];
    surName=json["surName"];
    phone=json["phone"];
    duration = json["duration"].toString();
    eventName = json["event_name"];
    from = DateTime.parse(json["from"]);
    to = DateTime.parse(json["to"]);
  }

  Map<String,dynamic> toJson(){
    Map<String,dynamic> data={};
    data["name"]=this.name;
    data["surName"]=this.surName;
    data["phone"]=this.phone;
    data["duration"]=this.duration??"60";
    data["event_name"]=this.eventName;
    data["from"]=this.from.toString();
    data["to"]=this.to.toString();

    return data;
  }
}
