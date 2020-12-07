import 'package:denta_clinic/Models/Event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  TextEditingController surNameController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();

    String surName='';
    String name='';
    String phone='';

    var meetings = <Event>[];

  @override
  void initState() {
    surNameController.addListener(()=>surName=surNameController.text);
    nameController.addListener(()=>name=nameController.text);
    phoneController.addListener(()=>phone=phoneController.text);
    super.initState();
  }

  @override
  void dispose() {
    surNameController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, size: 24,),
          ),
        ),
        body: SfCalendar(
          firstDayOfWeek: 1,
          view: CalendarView.week,
          timeSlotViewSettings: TimeSlotViewSettings(
            startHour: 6,
            endHour: 22,
          ),
          dataSource: MeetingDataSource(meetings),
          onLongPress: (CalendarLongPressDetails details) =>
              createNewEvent(details, context),
        ));
  }


  void createNewEvent(CalendarLongPressDetails details, context) {
    showDialog(
      context: context,
      builder: (_) =>
      new AlertDialog(
        title: new Text(
          "Створити нову зустріч",
          style: TextStyle(
            color: Colors.deepOrange,
          ),
        ),
        content: Container(
          height: MediaQuery
              .of(context)
              .size
              .height * 0.4,
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text("Введіть дані про пацієнта"),
            ),
            buildTextField("Прізвище", surNameController),
            buildTextField("Ім'я", nameController),
            buildTextField("Номер телефону", phoneController),
          ]),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Готово'),
            onPressed: () {
              _getDataSource(details);
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  buildTextField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:8.0),
      child: TextField(
        keyboardType: controller==phoneController?TextInputType.phone:TextInputType.text,
        controller: controller,
        decoration: new InputDecoration(
          prefix: SizedBox(
            width: 16,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            borderSide: BorderSide(color: Colors.deepOrange, width: 3.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            borderSide: BorderSide(
                color: Colors.deepOrange,
                width: 1.0),
          ),
          hintStyle: TextStyle(
            color: Colors.orange,
          ),
          hintText: hint,
        ),
        style: TextStyle(
          textBaseline: null,
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
        ),
      ),
    );
  }

  List<Event> _getDataSource(CalendarLongPressDetails details) {
    print(details.date);
    final DateTime today = DateTime.now();
    final DateTime startTime = details.date;
   // DateTime(today.year, today.month, today.day, 9, 0, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 1));
    meetings.add(
        Event(
            'Сеанс', startTime, endTime, const Color(0xFF0F8644), false));
    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Event> source){
    appointments = source;
}

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}
