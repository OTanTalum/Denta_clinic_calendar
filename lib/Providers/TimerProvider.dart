import 'package:denta_clinic/Models/Event.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class TimerProvider with ChangeNotifier{

  DateTime startTime;
  List<Event> meetings=[];

  setStartTime(value){
    startTime = value;
    notifyListeners();
  }

  clearTime(){
    startTime=null;
    notifyListeners();
  }

  addEvent(time, duration){
    DateTime endTime = time.add( Duration(minutes: duration));
    meetings.add(
        Event(
            'Сеанс', time, endTime, const Color(0xFF0F8644), false));
    notifyListeners();
  }
}