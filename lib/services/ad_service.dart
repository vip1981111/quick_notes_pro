import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInitialized = false;
  bool _isPremium = false;
  int _actionCount = 0;

  bool get isBannerAdLoaded => _bannerAd != null;
  BannerAd? get bannerAd => _bannerAd;

  Future<void> init() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
    if (!_isPremium) {
      await loadBannerAd();
      await loadInterstitialAd();
    }
  }

  void setPremium(bool value) {
    _isPremium = value;
    if (_isPremium) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _interstitialAd?.dispose();
      _interstitialAd = null;
    }
  }

  String get _bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    return Platform.isAndroid
        ? AppConstants.bannerAdUnitIdAndroid
        : AppConstants.bannerAdUnitIdIOS;
  }

  String get _interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    return Platform.isAndroid
        ? AppConstants.interstitialAdUnitIdAndroid
        : AppConstants.interstitialAdUnitIdIOS;
  }

  Future<void> loadBannerAd() async {
    if (_isPremium) return;

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Banner ad loaded'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed: $error');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );
    await _bannerAd?.load();
  }

  Future<void> loadInterstitialAd() async {
    if (_isPremium) return;

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint('Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void incrementActionCount() {
    if (_isPremium) return;
    _actionCount++;
    if (_actionCount >= 5) {
      showInterstitialAd();
      _actionCount = 0;
    }
  }

  Future<void> showInterstitialAd() async {
    if (_isPremium || _interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitialAd();
      },
    );
    await _interstitialAd!.show();
    _interstitialAd = null;
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}
