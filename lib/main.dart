import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joart/src/quiz/home.dart';
import 'package:joart/src/resources/apigetter.dart';
import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';

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
       
        primarySwatch: Colors.orange,
        fontFamily: 'Montserrat-Medium',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: QuizSplash(),
       routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => QuizzHome(),
        '/api': (BuildContext context) => QuizApi(),
        '/splash': (BuildContext context) =>  QuizSplash()
      },
    );
  }
}

class QuizSplash extends StatefulWidget {
  @override
  _QuizSplashState createState() => _QuizSplashState();
}

class _QuizSplashState extends State<QuizSplash> {
  
  @override
  void initState(){
    super.initState();
    Timer(Duration(seconds:10), (){
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => QuizzHome(),
      ));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.orange,
      body: Center(
        child: TextLiquidFill(
        text: 'QUIZZIE',
        waveColor: Colors.white,
        //boxBackgroundColor: Colors.black,
        textStyle: TextStyle(
          fontSize: 80.0,
          fontWeight: FontWeight.bold,
        ),
        boxHeight: 300.0,
  ),
      ),
    );
  }
}