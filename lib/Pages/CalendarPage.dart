import 'package:denta_clinic/Models/Event.dart';
import 'package:denta_clinic/Providers/TimerProviser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          dataSource: MeetingDataSource(Provider.of<TimerProvider>(context).meetings),
          onLongPress: (CalendarLongPressDetails details) =>
              createNewEvent(details, context),
        ));
  }


  void createNewEvent(CalendarLongPressDetails details, context) {
    DateTime numb;
    Provider.of<TimerProvider>(context, listen: false).setStartTime(details.date);
    print(Provider.of<TimerProvider>(context, listen: false).startTime);
    showDialog(
      context: context,
      builder: (_) =>
      AlertDialog(
        title: new Text(
          "Створити нову зустріч",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24
          ),
        ),
        content: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text("Введіть дані про пацієнта"),
            ),
            buildTextField("Прізвище", surNameController),
            buildTextField("Ім'я", nameController),
            buildTextField("Номер телефону", phoneController),
             SizedBox(height: 12,),
             RaisedButton(
                  textColor: Colors.white,
                  color: Colors.black,
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.5,
                    height: 48,
                    child:Center(child: Text("Назначити годину")),
                  ),
                  onPressed: () async {
                    numb = await  buildTimePicker(details.date);
                    Provider.of<TimerProvider>(context, listen: false).setStartTime(numb);
                    print("___${Provider.of<TimerProvider>(context, listen: false).startTime}");
                  },
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
            ),
          ]),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Готово'),
            onPressed: () {
              _getDataSource();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  buildTimePicker( DateTime time) async {
    DateTime startTime=null;
    return await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: 300,
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                minuteInterval: 1,
                secondInterval: 1,
                initialTimerDuration: Duration(hours: time.hour),
                onTimerDurationChanged: (Duration changedTimer) {
                    startTime = new DateTime(time.year, time.month, time.day, changedTimer.inHours, changedTimer.inMinutes%60);
                },
              )
          );
        }
    ).then((value) {
      return startTime;
    });
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
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.black, width: 3.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
                color: Colors.black,
                width: 1.0),
          ),
          hintStyle: TextStyle(
            color: Colors.black12,
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

  List<Event> _getDataSource() {
    DateTime time =  Provider.of<TimerProvider>(context, listen: false).startTime;
    Provider.of<TimerProvider>(context, listen: false).addEvent(time);
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
