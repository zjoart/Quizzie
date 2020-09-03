import 'dart:async';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:joart/src/ads/helper.dart';
import 'package:joart/src/quiz/result.dart';
import 'package:joart/src/resources/data.dart';
import 'package:html_unescape/html_unescape.dart';

class SizeConfig {
  static double yMargin(BuildContext context, double height) {
    double screenHeight = MediaQuery.of(context).size.height / 100;
    return height * screenHeight;
  }

  static double xMargin(BuildContext context, double width) {
    double screenWidth = MediaQuery.of(context).size.width / 100;
    return width * screenWidth;
  }

  static double textSize(BuildContext context, double textSize) {
    double screenHeight = MediaQuery.of(context).size.height / 100;
    double screenWidth = MediaQuery.of(context).size.width / 100;
    if (screenWidth > screenHeight) return textSize * screenHeight;
    return textSize * screenWidth;
  }
}

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
        ResultPage(marks: marks);
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
      fontSize: 25.0, fontWeight: FontWeight.w500, color: Colors.white);
  int _currentIndex = 0;

  //final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final List<Results> results;
  _QuizPageState(this.results);

  Color right = Colors.green;
  Color btnColor1 = Colors.white;
  Color btnColor2 = Colors.white;
  Color btnColor3 = Colors.white;
  Color btnColor4 = Colors.white;

  Color wrong1 = Colors.red;
  Color wrong2 = Colors.red;
  Color wrong3 = Colors.red;
  Color wrong4 = Colors.red;

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
    _loadInterstitialAd();
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
   // double height = MediaQuery.of(context).size.height;
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
        backgroundColor: Colors.orange[700],
        body: Column(
          children: <Widget>[
            Container(
              width: SizeConfig.xMargin(context, width),
              height: SizeConfig.yMargin(context, 35),
              color: Colors.orange[700],
              child: Column(
                children: <Widget>[
                  SizedBox(height: SizeConfig.yMargin(context, 10)),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 20),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Question ${_currentIndex + 1} of ${results.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConfig.textSize(context, 4),
                          ),
                        ),
                        SizedBox(width: SizeConfig.xMargin(context, 35)),
                        Expanded(
                          flex: 1,
                          child: Container(
                            child: Center(
                              child: Text(
                                showtimer,
                                style: TextStyle(
                                    fontSize: SizeConfig.textSize(context, 5),
                                    fontFamily: 'impact',
                                    // fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.yMargin(context, 4),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Text(
                      HtmlUnescape()
                          .convert(widget.results[_currentIndex].question),
                      softWrap: true,
                      style: width > 800
                          ? _questionStyle.copyWith(
                              fontSize: SizeConfig.textSize(context, 7),
                            )
                          : _questionStyle.copyWith(
                              fontSize: SizeConfig.textSize(context, 5)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: SizeConfig.xMargin(context, width),
                height: SizeConfig.yMargin(context, 65),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50)),
                    color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    choiceButton(HtmlUnescape().convert(options[0])),
                    choiceButton1(HtmlUnescape().convert(options[1])),
                    choiceButton2(HtmlUnescape().convert(options[2])),
                    choiceButton3(HtmlUnescape().convert(options[3])),
                    SizedBox(
                      height: SizeConfig.yMargin(context, 4),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (clickedButton == true) _nextSubmit();
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: SizeConfig.xMargin(context, width),
                          height: SizeConfig.yMargin(context, 7),
                          decoration: BoxDecoration(
                              color: Colors.orange[700],
                              borderRadius: BorderRadius.circular(50)),
                          child: Text(
                            _currentIndex == (widget.results.length - 1)
                                ? "Submit"
                                : "Next",
                            style: TextStyle(
                                fontSize:SizeConfig.textSize(context, 7),
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool clickedButton = false;
  void _nextSubmit() {
    canceltimer = false;
    timer = 30;
    setState(() {
      if (_currentIndex == (widget.results.length - 1)) {
        if (_isRewardedAdReady) {
          RewardedVideoAd.instance.show();
        }
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ResultPage(marks: marks),
        ));
      } else if (_currentIndex < (widget.results.length - 1)) {
        btnColor1 = Colors.white;
        btnColor2 = Colors.white;
        btnColor3 = Colors.white;
        btnColor4 = Colors.white;
        _currentIndex++;
        clickedButton = false;
      } else {
        _currentIndex += 0;
      }

      if (_isInterstitialAdReady) {
        if (_currentIndex > 10) {
          _interstitialAd.show();
          return;
        }
        if (_currentIndex > 20) {
          _interstitialAd.show();
          return;
        }
        if (_currentIndex > 30) {
          _interstitialAd.show();
          return;
        }
        if (_currentIndex > 40) {
          _interstitialAd.show();
          return;
        }
      }
    });
    starttimer();
  }

  Widget choiceButton(String b) {
    //double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 20),
      child: MaterialButton(
        elevation: 5,
        onPressed: () {
          if (clickedButton == false) {
            if (b == (widget.results[_currentIndex].correctAnswer)) {
              marks = marks + 2;
              print('correct');
              setState(() {
                clickedButton = true;
                btnColor1 = right;
              });
            } else {
              print(' incorrect');
              setState(() {
                clickedButton = true;
                btnColor1 = wrong1;
              });
            }
          }
          setState(() {
            canceltimer = true;
          });
          Timer(Duration(seconds: 1), _nextSubmit);
        },
        child: Text(
          b,
          style: TextStyle(
            fontSize: SizeConfig.textSize(context, 4.2),
            //color: Colors.white,
          ),
        ),
        color: btnColor1,
        height: SizeConfig.yMargin(context, 8),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      ),
    );
  }

  Widget choiceButton1(String b) {
   // double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 20),
      child: MaterialButton(
        elevation: 5,
        onPressed: () {
          if (clickedButton == false) {
            if (b == (widget.results[_currentIndex].correctAnswer)) {
              marks = marks + 2;
              print('correct');
              setState(() {
                clickedButton = true;
                btnColor2 = right;
              });
            } else {
              print(' incorrect');
              setState(() {
                clickedButton = true;
                btnColor2 = wrong2;
              });
            }
          }
          setState(() {
            canceltimer = true;
          });
          Timer(Duration(seconds: 1), _nextSubmit);
        },
        child: Text(
          b,
          style: TextStyle(
            fontSize: SizeConfig.textSize(context, 4.2),
            // color: Colors.white,
          ),
        ),
        color: btnColor2,
        height:SizeConfig.yMargin(context, 8),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      ),
    );
  }

  Widget choiceButton2(String b) {
    //double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 20),
      child: MaterialButton(
        elevation: 5,
        onPressed: () {
          if (clickedButton == false) {
            if (b == (widget.results[_currentIndex].correctAnswer)) {
              marks = marks + 2;
              print('correct');
              setState(() {
                clickedButton = true;
                btnColor3 = right;
              });
            } else {
              print(' incorrect');
              setState(() {
                clickedButton = true;
                btnColor3 = wrong3;
              });
            }
          }
          setState(() {
            canceltimer = true;
          });
          Timer(Duration(seconds: 1), _nextSubmit);
        },
        child: Text(
          b,
          style: TextStyle(
            fontSize: SizeConfig.textSize(context, 4.2),
          ),
        ),
        color: btnColor3,
        height: SizeConfig.yMargin(context, 8),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      ),
    );
  }

  Widget choiceButton3(String b) {
    //double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(
        left: 50,
        right: 50,
      ),
      child: MaterialButton(
        elevation: 5,
        onPressed: () {
          if (clickedButton == false) {
            if (b == (widget.results[_currentIndex].correctAnswer)) {
              marks = marks + 2;
              print('correct');
              setState(() {
                clickedButton = true;
                btnColor4 = right;
              });
            } else {
              print('incorrect');
              setState(() {
                clickedButton = true;
                btnColor4 = wrong4;
              });
            }
          }
          setState(() {
            canceltimer = true;
          });
          Timer(Duration(seconds: 1), _nextSubmit);
        },
        child: Text(
          b,
          style: TextStyle(
            fontSize:SizeConfig.textSize(context, 4.2),
          ),
        ),
        color: btnColor4,
        height:SizeConfig.yMargin(context, 8),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      ),
    );
  }
}
