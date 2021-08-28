import 'package:denta_clinic/API/Storage.dart';
import 'package:denta_clinic/Models/DentaEvent.dart';
import 'package:denta_clinic/Providers/TimerProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final scaffoldState = GlobalKey<ScaffoldState>();
  TextEditingController surNameController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController durationController = new TextEditingController();
  ScrollController scrollController = new ScrollController();
  PersistentBottomSheetController bscontroller;

  String surName = '';
  String name = '';
  String phone = '';
  String duration = '';

  bool isOpen = false;


  @override
  void initState() {
    surNameController.addListener(() => surName = surNameController.text);
    nameController.addListener(() => name = nameController.text);
    phoneController.addListener(() => phone = phoneController.text);
    durationController.addListener(() => duration = durationController.text);
    Storage().loadEvent(context);
    super.initState();
  }

  @override
  void dispose() {
    surNameController.dispose();
    nameController.dispose();
    phoneController.dispose();
    durationController.dispose();
    scrollController.dispose();
     bscontroller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
       // resizeToAvoidBottomPadding: false,
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
          showNavigationArrow: true,
          timeSlotViewSettings: TimeSlotViewSettings(
            startHour: 6,
            endHour: 22,
            timeIntervalHeight: 75,
          ),
          dataSource:
              MeetingDataSource(Provider.of<TimerProvider>(context).meetings),
          onLongPress: (CalendarLongPressDetails details) =>
              createNewEvent(details),
          onTap: (CalendarTapDetails details) async => {
            await showDialogAction(details, context),
          },
        ));
  }

  showDialogAction(CalendarTapDetails details, context){
    DentaEvent meet;
  if(details.appointments?.first==null){

   if(bscontroller!=null){
       try {
         bscontroller.close();
       }catch(e) {
         print(e);
       }
         bscontroller=null;
         return;
   }
  return;
  }
  else {
    meet =  details.appointments.first;
  }
  bscontroller = scaffoldState.currentState
      .showBottomSheet((context) =>
      Container(
        height: MediaQuery.of(context).size.height*0.3,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(25.0),
              topRight: const Radius.circular(25.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top:12.0),
              child: Text("${meet.eventName}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                )
              ),
            ),
            _buildTime(meet.from, meet.to),
            _buildTile(Icons.person, "${meet.surName[0].toUpperCase()}${meet.surName.substring(1)} ${meet.name[0].toUpperCase()}${meet.name.substring(1)} "),
            _buildTile(Icons.phone, "${meet.phone}"),
          ],
        ),
      )
  );
  }

  _buildTime(from, to){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
       child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
         children: [
           Icon(Icons.access_time),
           SizedBox(width: 15,),
           Text("${(from.toString()).split(":")[0]}:${(from.toString()).split(":")[1]} - ${(to.toString()).split(" ")[1].split(":00.000")[0]}",
               style: TextStyle(
                 fontSize: 18,
                 fontWeight: FontWeight.w400,
               )
           )
         ],
        ),
    );
  }

  _buildTile(icon, value){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
       child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
         children: [
           Icon(icon),
           SizedBox(width: 15,),
           Text(value.toString(),
               style: TextStyle(
                 fontSize: 18,
                 fontWeight: FontWeight.w400,
               )
           )
         ],
        ),
    );
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
                width: MediaQuery.of(context).size.width * 0.9,
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
                  onPressed: () async{
                    DentaEvent newEvent = _getDataSource(nameController.text, surNameController.text, phoneController.text, durationController.text);
                    await sendData(newEvent);
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


  sendData(DentaEvent createdEvent) async{
    await Storage().saveEvent(createdEvent.toJson());
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

  _getDataSource(name, surName, phone, value) {
    DateTime time =
        Provider.of<TimerProvider>(context, listen: false).startTime;
    int duration = int.parse(value);
    return Provider.of<TimerProvider>(context, listen: false).addEvent(name, surName, phone, time, duration);
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<DentaEvent> source) {
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

}
