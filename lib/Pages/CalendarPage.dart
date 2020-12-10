import 'package:denta_clinic/Models/Event.dart';
import 'package:denta_clinic/Providers/TimerProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  TextEditingController surNameController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController durationController = new TextEditingController();
  ScrollController scrollController = new ScrollController();

  String surName = '';
  String name = '';
  String phone = '';
  String duration = '';

  @override
  void initState() {
    surNameController.addListener(() => surName = surNameController.text);
    nameController.addListener(() => name = nameController.text);
    phoneController.addListener(() => phone = phoneController.text);
    durationController.addListener(() => duration = durationController.text);
    super.initState();
  }

  @override
  void dispose() {
    surNameController.dispose();
    nameController.dispose();
    phoneController.dispose();
    durationController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              size: 24,
            ),
          ),
        ),
        body: SfCalendar(
          firstDayOfWeek: 1,
          view: CalendarView.week,
          timeSlotViewSettings: TimeSlotViewSettings(
            startHour: 6,
            endHour: 22,
          ),
          dataSource:
              MeetingDataSource(Provider.of<TimerProvider>(context).meetings),
          onLongPress: (CalendarLongPressDetails details) =>
              createNewEvent(details),
        ));
  }

  createNewEvent(CalendarLongPressDetails details) {
    var provider = Provider.of<TimerProvider>(context, listen: false);
    Provider.of<TimerProvider>(context, listen: false)
        .setStartTime(details.date);
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Center(
                child: Text(
                  "Створити нову зустріч",
                  style: GoogleFonts.ptSansNarrow(
                    textStyle: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                ),
              ),
              content: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            "Введіть дані про пацієнта",
                            style: GoogleFonts.ptSansNarrow(
                              textStyle:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ),
                        buildTextField("Прізвище", surNameController),
                        buildTextField("Ім'я", nameController),
                        buildTextField("Номер телефону", phoneController),
                        SizedBox(
                          height: 12,
                        ),
                        _buildButton(
                            onPressed: () async {
                              await buildTimePicker(details.date);
                              setState(() {});
                            },
                            buttonName: "Назначити годину"),
                        provider.startTime != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  "Вибраний час   ${provider.startTime.hour}:${provider.startTime.minute < 10 ? "0${provider.startTime.minute}" : provider.startTime.minute}",
                                  style: GoogleFonts.ptSansNarrow(
                                    textStyle: TextStyle(
                                        color: Colors.black, fontSize: 20),
                                  ),
                                ),
                              )
                            : Container(),
                        buildDuration(durationController)
                      ]),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Готово'),
                  onPressed: () {
                    _getDataSource(durationController.text);
                    provider.clearTime();
                    nameController.text='';
                    surNameController.text='';
                    phoneController.text='';
                    durationController.text="60";
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
        });
  }

  buildDuration(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Довжина сеансу : ",
            style: GoogleFonts.ptSansNarrow(
              textStyle: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: 48,
            child: TextField(
                onTap: () => scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 300),
                    ),
                keyboardType: TextInputType.phone,
                controller: controller,
                decoration: new InputDecoration(
                  suffixText: "хв.",
                  suffixStyle: GoogleFonts.ptSansNarrow(
                    textStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  prefix: SizedBox(
                    width: 16,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.black, width: 3.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                ),
                style: GoogleFonts.ptSansNarrow(
                  textStyle: TextStyle(
                    textBaseline: null,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  _buildButton({Function onPressed, String buttonName}) {
    return RaisedButton(
      textColor: Colors.white,
      color: Colors.black,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: 48,
        child: Center(child: Text(buttonName)),
      ),
      onPressed: onPressed,
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
      ),
    );
  }

  buildTimePicker(DateTime time) {
    DateTime startTime = null;
    return showModalBottomSheet(
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
                  startTime = new DateTime(time.year, time.month, time.day,
                      changedTimer.inHours, changedTimer.inMinutes % 60);
                },
              ));
        }).then((value) {
      Provider.of<TimerProvider>(context, listen: false)
          .setStartTime(startTime);
    });
  }

  buildTextField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
          keyboardType: controller == phoneController
              ? TextInputType.phone
              : TextInputType.text,
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
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            hintStyle: GoogleFonts.ptSansNarrow(
              textStyle: TextStyle(
                color: Colors.black12,
              ),
            ),
            hintText: hint,
          ),
          style: GoogleFonts.ptSansNarrow(
            textStyle: TextStyle(
              textBaseline: null,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
            ),
          )),
    );
  }

  List<Event> _getDataSource(value) {
    DateTime time =
        Provider.of<TimerProvider>(context, listen: false).startTime;
    int duration = int.parse(value);
    Provider.of<TimerProvider>(context, listen: false).addEvent(time, duration);
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Event> source) {
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
