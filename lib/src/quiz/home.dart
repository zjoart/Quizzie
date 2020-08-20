import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:joart/src/ads/helper.dart';
import 'package:joart/src/errors/apierror.dart';
import 'dart:io';

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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(padding: EdgeInsets.all(100.0)),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('images/quiz.jpg')),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: startQuiz,
                child: Container(
                  alignment: Alignment.center,
                  width: width,
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(50),
                      )),
                  child: Text(
                    'Start Quiz',
                    style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Montserrat-Medium'),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _initAdMob() {
    return FirebaseAdMob.instance.initialize(appId: AdManager.appId);
  }

  void startQuiz() {
    //will pass in different functions to load error,waiting and quizpage view
    try {
      Navigator.pop(context);
      if (_isRewardedAdReady) {
        RewardedVideoAd.instance.show();
        return;
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => QuizApi()));
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
                    message: "Unexpected error trying to connect to the API",
                  )));
    }
  }
}
