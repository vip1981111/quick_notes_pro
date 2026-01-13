import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../utils/constants.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  bool _isPremium = false;
  ProductDetails? _monthlyProduct;
  ProductDetails? _yearlyProduct;

  final _premiumController = StreamController<bool>.broadcast();
  Stream<bool> get premiumStream => _premiumController.stream;
  bool get isPremium => _isPremium;
  ProductDetails? get monthlyProduct => _monthlyProduct;
  ProductDetails? get yearlyProduct => _yearlyProduct;

  Future<void> init() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      debugPrint('In-app purchases not available');
      return;
    }

    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) => debugPrint('Purchase error: $error'),
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response = await _inAppPurchase.queryProductDetails({
      AppConstants.monthlySubscriptionId,
      AppConstants.yearlySubscriptionId,
    });

    if (response.error != null) {
      debugPrint('Error loading products: ${response.error}');
      return;
    }

    for (final product in response.productDetails) {
      if (product.id == AppConstants.monthlySubscriptionId) {
        _monthlyProduct = product;
      } else if (product.id == AppConstants.yearlySubscriptionId) {
        _yearlyProduct = product;
      }
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == AppConstants.monthlySubscriptionId ||
            purchase.productID == AppConstants.yearlySubscriptionId) {
          _setPremium(true);
        }
        if (purchase.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchase);
        }
      }
    }
  }

  void _setPremium(bool value) {
    _isPremium = value;
    _premiumController.add(value);
  }

  Future<bool> purchaseMonthly() async {
    if (!_isAvailable || _monthlyProduct == null) return false;
    final purchaseParam = PurchaseParam(productDetails: _monthlyProduct!);
    return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<bool> purchaseYearly() async {
    if (!_isAvailable || _yearlyProduct == null) return false;
    final purchaseParam = PurchaseParam(productDetails: _yearlyProduct!);
    return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    await _inAppPurchase.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
    _premiumController.close();
  }
}
