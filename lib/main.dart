import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joart/src/quiz/home.dart';
import 'package:joart/src/resources/api_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizzie',
      theme: ThemeData(
       
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat-Medium',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: QuizzHome(),
       routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => QuizzHome(),
        '/api': (BuildContext context) => QuizApi()
      },
    );
  }
}

