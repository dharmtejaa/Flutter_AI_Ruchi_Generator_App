import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();

  factory AdService() {
    return _instance;
  }

  AdService._internal();

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // --- Ad Unit IDs (Test IDs) ---
  // Replace these with real AdMob IDs in release
  // Android Test IDs
  static const String _androidBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _androidInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  // iOS Test IDs
  static const String _iosBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosInterstitialId =
      'ca-app-pub-3940256099942544/4411468910';

  String get bannerAdUnitId {
    if (Platform.isAndroid) return _androidBannerId;
    if (Platform.isIOS) return _iosBannerId;
    throw UnsupportedError('Unsupported platform');
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) return _androidInterstitialId;
    if (Platform.isIOS) return _iosInterstitialId;
    throw UnsupportedError('Unsupported platform');
  }

  // --- Interstitial Logic ---
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          debugPrint('Interstitial ad loaded.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    final completer = Completer<void>();

    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialAdReady = false;
          if (!completer.isCompleted) completer.complete();
          // Load the next one
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isInterstitialAdReady = false;
          if (!completer.isCompleted) completer.complete();
          loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
    } else {
      // If ad not ready, just proceed
      if (!completer.isCompleted) completer.complete();
      // Try loading for next time
      loadInterstitialAd();
    }

    return completer.future;
  }
}
