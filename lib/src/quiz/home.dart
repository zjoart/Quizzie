import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:joart/src/ads/helper.dart';


import 'package:joart/src/resources/apigetter.dart';

class QuizzHome extends StatefulWidget {
  @override
  _QuizzHomeState createState() => _QuizzHomeState();
}

class _QuizzHomeState extends State<QuizzHome> {
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
        QuizApi();
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

  @override
  void initState() {
    super.initState();
    _initAdMob();
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
     double height = MediaQuery.of(context).size.height/100;
    return Scaffold(
      backgroundColor: Colors.orange[700],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
           maxRadius: 100,
           minRadius: 50,
            child: Image.asset('images/quiz.png'),
          ),
          SizedBox(
            height: height < 500 ? 25 : 50,
          ),
          Text(
            'General Quiz',
            style: width > 500 ? TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                fontFamily: 'impact',
                color: Colors.white) : TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                fontFamily: 'impact',
                color: Colors.white)
          ),
          Text(
              'Test Your Self',
              style:  width > 500 ? TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat-Medium',
                color: Colors.white) : TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat-Medium',
                color: Colors.white)
            ),
          SizedBox(
            height: height < 500 ? 50 : 100,
          ),
          Padding(
            padding: width < 600 ? const EdgeInsets.only(left: 50, right: 50) : const EdgeInsets.only(left: 30, right: 30),
            child: GestureDetector(
              onTap: startQuiz,
              child: Container(
                alignment: Alignment.center,
                width: width,
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(50)),
                child: Text(
                  'Start Quiz',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'impact',
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initAdMob() {
    return FirebaseAdMob.instance.initialize(appId: AdManager.appId);
  }

  void startQuiz() {
      if (_isRewardedAdReady) {
        RewardedVideoAd.instance.show();
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => QuizApi()));
    }
}
