import 'package:denta_clinic/Models/DentaEvent.dart';
import 'package:denta_clinic/Providers/TimerProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

final databaseReference = FirebaseDatabase.instance.reference();
FirebaseApp app;
DatabaseReference eventRF;
class Storage{

  init(FirebaseApp appSettings){
    app=appSettings;
    final FirebaseDatabase database = new FirebaseDatabase(app: app);
    eventRF = database.reference().child("event");
  }

  saveEvent(Map <String,dynamic> event) async {
    print(event);
    eventRF.push().set(event);
  }

  getEvent(context){
    List<DentaEvent> eventList=[];
    eventRF.once().then((snapshot) {
      snapshot.value.forEach((key, value) => {
        eventList.add(DentaEvent.fromJson(value))
      });
    });
    Provider.of<TimerProvider>(context, listen: false).getEvent(eventList);
  }

 loadEvent(context){
 eventRF.limitToLast(1).onChildAdded.listen((event) {
   if(event.snapshot.value!=null) {
     Provider.of<TimerProvider>(context, listen: false).initMeetings(DentaEvent.fromJson(event.snapshot.value));
   }
   });
  }
}