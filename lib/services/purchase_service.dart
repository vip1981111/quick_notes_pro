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
  ProductDetails? _premiumProduct;

  final _premiumController = StreamController<bool>.broadcast();
  Stream<bool> get premiumStream => _premiumController.stream;
  bool get isPremium => _isPremium;
  ProductDetails? get premiumProduct => _premiumProduct;

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
      AppConstants.premiumProductId,
    });

    if (response.error != null) {
      debugPrint('Error loading products: ${response.error}');
      return;
    }

    if (response.productDetails.isNotEmpty) {
      _premiumProduct = response.productDetails.first;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == AppConstants.premiumProductId) {
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

  Future<bool> purchasePremium() async {
    if (!_isAvailable || _premiumProduct == null) return false;
    final purchaseParam = PurchaseParam(productDetails: _premiumProduct!);
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
