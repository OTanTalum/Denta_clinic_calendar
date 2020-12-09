import 'package:denta_clinic/Models/Event.dart';
import 'package:flutter/cupertino.dart';

class TimerProvider with ChangeNotifier {

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

  addEvent(time){
    DateTime endTime = time.add(const Duration(hours: 1));
    meetings.add(
        Event(
            'Сеанс', time, endTime, const Color(0xFF0F8644), false));
    notifyListeners();
  }
}