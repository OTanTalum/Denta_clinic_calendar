import 'package:denta_clinic/API/Storage.dart';
import 'package:denta_clinic/Auth/auth.dart';
import 'package:denta_clinic/Auth/authProvider.dart';
import 'package:denta_clinic/Pages/CalendarPage.dart';
import 'package:denta_clinic/Providers/TimerProvider.dart';
import 'package:denta_clinic/Providers/UserProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Pages/AuthPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
    options: FirebaseOptions(
      appId: '1:478781549663:android:1b22d1d4b3c682ba097fea',
      apiKey: 'AIzaSyBmgzIg5LaLktUFooQhnpHqGk2ksrNgXOs',
      messagingSenderId: '478781549663',
      projectId: 'denta-clinic-6a35c',
      databaseURL: 'https://denta-clinic-6a35c-default-rtdb.europe-west1.firebasedatabase.app',

    ),
  );
  Storage().init(app);
  FirebaseAuthorization.init(app);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: new MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

}
class _MyAppState extends State<MyApp> {

  String uid;

  @override
  void setState(VoidCallback fn) {
    Future.microtask(() async  {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      uid = prefs.getString("uid");
    });

    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
        supportedLocales: [
          const Locale('en'), // English
          const Locale('ru'), // Hebrew
          const Locale('uk'), // Chinese *See Advanced Locales below*
      ],
      debugShowCheckedModeBanner: false,
      //locale: const Locale('uk'),
      title: 'My Dental Clinic',
      theme: ThemeData(
        fontFamily: 'Piazzolla',
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: uid==null?AuthPage(callback:()=>setState(() { })):MyHomePage(),

      //AuthPage(),
   //   home:MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String uid='';

  @override
  void initState() {
    Future.microtask(() async{
      Storage().getEvent(context);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        uid = prefs.getString("uid");
      });

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("uid: $uid"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Hello '),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (_)=>CalendarPage())),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
