
import 'package:denta_clinic/Models/DentaEvent.dart';
import 'package:flutter/cupertino.dart';

class TimerProvider with ChangeNotifier{

  DateTime startTime;
  List<DentaEvent> meetings=[];

  initMeetings(DentaEvent newEvent){

    meetings.add(newEvent);
    notifyListeners();
  }

  setStartTime(value){
    startTime = value;
    notifyListeners();
  }

  clearTime(){
    startTime=null;
    notifyListeners();
  }

  getEvent(List<DentaEvent> list){
    meetings = list;
    notifyListeners();
  }

  addEvent(name, surName, phone, time, duration){
    DateTime endTime = time.add( Duration(minutes: duration));
    DentaEvent newEvent;
    newEvent = new DentaEvent(
        name: name,
        surName: surName,
        phone: phone,
        eventName: 'Сеанс',
        from: time,
        duration: duration.toString(),
        to: endTime
       );
    meetings.add(newEvent);
    return newEvent;
  }
}