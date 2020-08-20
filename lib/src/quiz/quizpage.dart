import 'dart:async';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:joart/src/ads/helper.dart';
import 'package:joart/src/quiz/result.dart';
import 'package:joart/src/resources/data.dart';

// ignore: must_be_immutable
class QuizPage extends StatefulWidget {
  final List<Results> results;

  QuizPage({Key key, @required this.results}) : super(key: key);
  @override
  _QuizPageState createState() => _QuizPageState(results);
}

class _QuizPageState extends State<QuizPage> {
  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady;
  bool _isRewardedAdReady;

 

  void _loadInterstitialAd() {
    _interstitialAd.load();
  }

  void _loadRewardedAd() {
    RewardedVideoAd.instance.load(
      targetingInfo: MobileAdTargetingInfo(),
      adUnitId: AdManager.rewardedAdUnitId,
    );
  }

  void _onRewardedAdEvent(RewardedVideoAdEvent event,
      {String rewardType, int rewardAmount}) {
    switch (event) {
      case RewardedVideoAdEvent.loaded:
        setState(() {
          _isRewardedAdReady = true;
        });
        break;
      case RewardedVideoAdEvent.closed:
        setState(() {
          _isRewardedAdReady = false;
        });
        _loadRewardedAd();
        break;
      case RewardedVideoAdEvent.failedToLoad:
        setState(() {
          _isRewardedAdReady = false;
        });
        print('Failed to load a rewarded ad');
        break;
      case RewardedVideoAdEvent.rewarded:
        Text('USE YOUR HEADD'.toUpperCase());
        break;
      default:
      // do nothing
    }
  }

  void _onInterstitialAdEvent(MobileAdEvent event) {
    switch (event) {
      case MobileAdEvent.loaded:
        _isInterstitialAdReady = true;
        break;
      case MobileAdEvent.failedToLoad:
        _isInterstitialAdReady = false;
        print('Failed to load an interstitial ad');
        break;
      case MobileAdEvent.closed:
        QuizPage(results: results);
        break;
      default:
      // do nothing
    }
  }

  final TextStyle _questionStyle = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white);
  int _currentIndex = 0;

  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final List<Results> results;
  _QuizPageState(this.results);

  Color colortoshow = Colors.orange;
  Color right = Colors.green;
  Color wrong = Colors.red;
  Color btnColor = Colors.white;
  int marks = 0;

  int timer = 30;
  String showtimer = "30";

  bool canceltimer = false;

  @override
  void initState() {
    starttimer();
   
    _isInterstitialAdReady = false;

    _interstitialAd = InterstitialAd(
      adUnitId: AdManager.interstitialAdUnitId,
      listener: _onInterstitialAdEvent,
    );
    _isRewardedAdReady = false;

    RewardedVideoAd.instance.listener = _onRewardedAdEvent;
    _loadRewardedAd();
    super.initState();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    RewardedVideoAd.instance.listener = null;
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void starttimer() async {
    const onesec = Duration(seconds: 1);
    Timer.periodic(onesec, (Timer t) {
      setState(() {
        if (timer < 1) {
          t.cancel();
          _nextSubmit();
        } else if (canceltimer == true) {
          t.cancel();
        } else {
          timer = timer - 1;
        }
        showtimer = timer.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Results question = widget.results[_currentIndex];
    final List<dynamic> options = question.allAnswers;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        return showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    "Quizzie",
                  ),
                  content: Text("You Can't Go Back At This Stage."),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Ok',
                      ),
                    )
                  ],
                ));
      },
          child: Scaffold(
        key: _key,
        body: Column(
          children: <Widget>[
            ClipPath(
              clipper: CircularClipper(),
              child: Container(
                width: width,
                height: 370,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.orange[500],
                    Colors.orange,
                  ],
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(50.0)),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                            "Question ${_currentIndex + 1} of ${results.length}",
                            style: new TextStyle(
                                fontSize: 25.0, color: Colors.white),
                          ),
                          SizedBox(
                            width: 180,
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Center(
                                child: Text(
                                  showtimer,
                                  style: TextStyle(
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(25.0)),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Text(
                        widget.results[_currentIndex].question,
                        softWrap: true,
                        style: width > 800
                            ? _questionStyle.copyWith(fontSize: 30.0)
                            : _questionStyle.copyWith(fontSize: 20.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ...options.map(
                  (option) => choiceButton("a", option),
                )
              ],
            )),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (clickedButton = true) _nextSubmit();
                    });
                  },
                  child: Container(
                    width: width,
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.orange[500],
                            Colors.orange,
                          ],
                        )),
                    child: Center(
                      child: Text(
                        _currentIndex == (widget.results.length - 1)
                            ? "Submit"
                            : "Next",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool clickedButton = false;
  bool isCorrect = false;
  void checkanswer(String b, String k) {
    if (clickedButton == false) {
      if (b == (widget.results[_currentIndex].correctAnswer)) {
        marks = marks + 5;
        print(' correct');
        setState(() {
          colortoshow = right;
          clickedButton = true;
          isCorrect = true;
        });
      } else {
        print(' incorrect');
        setState(() {
          colortoshow = wrong;
          clickedButton = true;
        });
      }
    }
    setState(() {
      btnColor = colortoshow;
      canceltimer = true;
    });
  }

  void _nextSubmit() {
    canceltimer = false;
    timer = 30;

    setState(() {
      if (_currentIndex < (widget.results.length - 1)) {
        _currentIndex++;
      
      }
       else { if (_isRewardedAdReady) {
          RewardedVideoAd.instance.show();
          return;
        }
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ResultPage(marks: marks),
        ));
       }
      if (_currentIndex > 15) {
        _loadInterstitialAd();
        if (_currentIndex > 15) if (_isInterstitialAdReady) {
          _interstitialAd.show();
        }
      }
      btnColor = Colors.white;
    });
    starttimer();
  }

  Widget choiceButton(String k, String b) {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 10),
      child: Card(
        elevation: 3,
        child: MaterialButton(
          onPressed: () => checkanswer(b, k),
          child: Text(
            b,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          color: btnColor,
          height: 70.0,
          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
      ),
    );
  }
}

class CircularClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
