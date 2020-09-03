import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:joart/src/ads/helper.dart';
import 'package:joart/src/quiz/home.dart';
import 'package:joart/src/resources/apigetter.dart';

// ignore: must_be_immutable
class ResultPage extends StatefulWidget {
  int marks;
  ResultPage({Key key, @required this.marks}) : super(key: key);
  @override
  _ResultPageState createState() => _ResultPageState(marks);
}

class _ResultPageState extends State<ResultPage> {
 
  BannerAd _bannerAd;

  bool _isRewardedAdReady;

  void _loadBannerAd() {
    _bannerAd
      ..load()
      ..show(anchorType: AnchorType.top);
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

 

  double percent = 0;
  int finalscore = 100;
  @override
  void initState() {
    super.initState();
    percent = ((marks / finalscore) * 100);
    if (marks < 35) {
      image = images[2];
      message =
          "You Should Try Harder..\n" + "You Scored $marks\nThat's $percent%";
    } else if (marks < 60) {
      image = images[1];
      message = "You Can Do Better..\n" + "You Scored $marks\nThat's $percent%";
    } else {
      image = images[0];
      message = "You Did Very Well..\n" + "You Scored $marks\nThat's $percent%";
    }
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.fullBanner,
    );

    _loadBannerAd();

    
    _isRewardedAdReady = false;

    RewardedVideoAd.instance.listener = _onRewardedAdEvent;
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    RewardedVideoAd.instance.listener = null;
    super.dispose();
  }

  int marks;
  _ResultPageState(this.marks);

  List<String> images = [
    "images/success.png",
    "images/grade.png",
    "images/sad.png",
  ];

  String message;
  String image;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.orange[700],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Card(
            elevation: 5,
            child: Container(
              color: Colors.orange[700],
              width: width,
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 100,
                    child: Image.asset(image),
                  ),
                  SizedBox(height: 30),
                  Text(
                    message,
                    style: TextStyle(fontSize: 25.0, color: Colors.white),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlineButton(
                onPressed: () {
                  if (_isRewardedAdReady) {
                    RewardedVideoAd.instance.show();
                    return;
                  }
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => QuizApi(),
                  ));
                },
                child: Text(
                  marks < 35 ? "Try Again" : "Reset Quiz",
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25.0,
                ),
                borderSide: BorderSide(width: 3.0, color: Colors.white),
                splashColor: Colors.orangeAccent,
              ),
              SizedBox(
                width: 30,
              ),
              OutlineButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => QuizzHome(),
                  ));
                },
                child: Text(
                  "Home",
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 25.0,
                ),
                borderSide: BorderSide(width: 3.0, color: Colors.white),
                splashColor: Colors.orangeAccent,
              ),
            ],
          )
        ],
      ),
    );
  }


}
