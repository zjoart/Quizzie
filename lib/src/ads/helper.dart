import 'dart:io';

class AdManager {

  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-9055930023868276~5097993486";
    } else if (Platform.isIOS) {
      return "ca-app-pub-9055930023868276~1623822331";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-9055930023868276/4377591142";
    } else if (Platform.isIOS) {
      return "ca-app-pub-9055930023868276/1276322060";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-9055930023868276/5146913181";
    } else if (Platform.isIOS) {
      return "ca-app-pub-9055930023868276/2397832045";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-9055930023868276/8097344306";
    } else if (Platform.isIOS) {
      return "ca-app-pub-9055930023868276/4832423693";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}