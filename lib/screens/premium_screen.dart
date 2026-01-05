import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/purchase_service.dart';
import '../services/ad_service.dart';
import '../providers/settings_provider.dart';
import '../l10n/generated/app_localizations.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _purchaseService.premiumStream.listen((isPremium) {
      if (isPremium && mounted) {
        Provider.of<SettingsProvider>(context, listen: false).setPremium(true);
        AdService().setPremium(true);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your purchase!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final product = _purchaseService.premiumProduct;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.workspace_premium, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.getPremium,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              _buildFeature(Icons.block, l10n.noAds),
              _buildFeature(Icons.mic, l10n.unlimitedRecordings),
              _buildFeature(Icons.favorite, 'Support Developer'),
              const Spacer(),
              Text(
                product?.price ?? l10n.price,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _purchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            l10n.getPremium,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _restore,
                child: Text(
                  l10n.restorePurchases,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 28),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }

  Future<void> _purchase() async {
    setState(() => _isLoading = true);
    await _purchaseService.purchasePremium();
    setState(() => _isLoading = false);
  }

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    await _purchaseService.restorePurchases();
    setState(() => _isLoading = false);
  }
}
