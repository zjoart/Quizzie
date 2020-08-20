import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:joart/src/ads/helper.dart';
import 'package:joart/src/resources/apigetter.dart';


// ignore: must_be_immutable
class ResultPage extends StatefulWidget {
  int marks;
  ResultPage({Key key, @required this.marks}) : super(key: key);
  @override
  _ResultPageState createState() => _ResultPageState(marks);
}

class _ResultPageState extends State<ResultPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  BannerAd _bannerAd;
  
  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady;
  bool _isRewardedAdReady;

  void _loadBannerAd() {
    _bannerAd
      ..load()
      ..show(anchorType: AnchorType.top);
  }

 

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
        _moveToHome();
        break;
      default:
      // do nothing
    }
  }

  @override
  void initState() {
    super.initState();
    if (marks < 20) {
      image = images[2];
      message = "You Should Try Harder..\n" + "You Scored $marks";
    } else if (marks < 35) {
      image = images[1];
      message = "You Can Do Better..\n" + "You Scored $marks";
    } else {
      image = images[0];
      message = "You Did Very Well..\n" + "You Scored $marks";
    }
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.fullBanner,
    );
   

    _loadBannerAd();
   
    _isInterstitialAdReady = false;

    _interstitialAd = InterstitialAd(
      adUnitId: AdManager.interstitialAdUnitId,
      listener: _onInterstitialAdEvent,
    );
    _isRewardedAdReady = false;

    RewardedVideoAd.instance.listener = _onRewardedAdEvent;
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    RewardedVideoAd.instance.listener = null;
    super.dispose();
  }

  int marks;
  _ResultPageState(this.marks);

  List<String> images = [
    "images/success.png",
    "images/good.png",
    "images/bad.png",
  ];

  String message;
  String image;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 8,
              child: Material(
                elevation: 5.0,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Material(
                        child: Container(
                          width: width,
                          height: 300.0,
                          child: ClipRect(
                            child: Image(
                              image: AssetImage(
                                image,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 15.0,
                          ),
                          child: Center(
                            child: Text(
                              message,
                              style: TextStyle(
                                fontSize: 25.0,
                                fontFamily: "Montserrat-Medium",
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  OutlineButton(
                    onPressed: () async {
                      _loadInterstitialAd();
                      if (_isInterstitialAdReady) {
                        _interstitialAd.show();
                        return;
                      }
                     Navigator.of(context).pushNamed('/home');
                    },
                    child: Text(
                      "Home",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 25.0,
                    ),
                    borderSide: BorderSide(width: 3.0, color: Colors.orange),
                    splashColor: Colors.orangeAccent,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  OutlineButton(
                    onPressed: () {
                      if (_isRewardedAdReady) {
                        RewardedVideoAd.instance.show();
                        return;
                      }
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => QuizApi()));
                    },
                    child: Text(
                      "Reset Quiz",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 25.0,
                    ),
                    borderSide: BorderSide(width: 3.0, color: Colors.orange),
                    splashColor: Colors.orangeAccent,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _moveToHome() {
    Navigator.pushNamedAndRemoveUntil(
        _scaffoldKey.currentContext, '/', (_) => false);
  }
}
