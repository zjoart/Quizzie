import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:joart/src/errors/apierror.dart';
import 'package:joart/src/quiz/quizpage.dart';
import 'dart:convert';
import 'dart:io';
import 'data.dart';

class QuizApi extends StatefulWidget {
  @override
  _QuizApiState createState() => _QuizApiState();
}

class _QuizApiState extends State<QuizApi> {
  String baseUrl =
      'https://opentdb.com/api.php?amount=50&category=9&type=multiple';

  Future<List<Results>> getQuiz() async {
    return await http.get(baseUrl).then((response) {
      Data an = Data.fromJson(json.decode(response.body.toString()));
      // print(response.body);
      return an.results;
    });
  }

  @override
  initState() {
    super.initState();
    getQuiz();
  }

  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {

          try {
            if (snapshot.data != null) {
             final List<Results> results = snapshot.data;
              return QuizPage(results: results);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          } on SocketException catch (_) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => ErrorPage(
                          message:
                              "Can't reach the servers, \n Please check your internet connection.",
                        )));
          } catch (e) {
            print(e.message);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => ErrorPage(
                          message:
                              "Unexpected error trying to connect to the API",
                        )));
          }
        
        },
        future: getQuiz(),
      ),
    );
  }

  //will pass in different functions to load error,waiting and quizpage view


}
