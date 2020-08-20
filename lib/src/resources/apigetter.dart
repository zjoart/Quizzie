import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:joart/src/quiz/quizpage.dart';
import 'dart:convert';

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
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              List<Results> results = snapshot.data;
              return QuizPage(results: results);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
        future: getQuiz(),
      ),
    );
  }
}

