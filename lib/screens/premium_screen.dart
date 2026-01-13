import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/purchase_service.dart';
import '../services/ad_service.dart';
import '../providers/settings_provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/constants.dart';

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
          const SnackBar(content: Text('Thank you for subscribing!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final monthlyProduct = _purchaseService.monthlyProduct;
    final yearlyProduct = _purchaseService.yearlyProduct;

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 24),
                Text(
                  l10n.getPremium,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                _buildFeature(Icons.block, l10n.noAds),
                _buildFeature(Icons.mic, l10n.unlimitedRecordings),
                _buildFeature(Icons.favorite, 'Support Developer'),
                const SizedBox(height: 40),
                // Yearly Subscription - Best Value
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildSubscriptionCard(
                    title: 'Yearly',
                    titleAr: 'سنوي',
                    price: yearlyProduct?.price ?? '\$14.99',
                    period: '/year',
                    periodAr: '/سنة',
                    savings: 'Save 37%',
                    savingsAr: 'وفر 37%',
                    isRecommended: true,
                    onTap: _isLoading ? null : _purchaseYearly,
                  ),
                ),
                const SizedBox(height: 16),
                // Monthly Subscription
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildSubscriptionCard(
                    title: 'Monthly',
                    titleAr: 'شهري',
                    price: monthlyProduct?.price ?? '\$1.99',
                    period: '/month',
                    periodAr: '/شهر',
                    isRecommended: false,
                    onTap: _isLoading ? null : _purchaseMonthly,
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _restore,
                  child: Text(
                    l10n.restorePurchases,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Subscriptions auto-renew unless cancelled 24 hours before the end of the current period.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Privacy Policy & Terms of Service links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => _openUrl(AppConstants.privacyPolicyUrl),
                      child: Text(
                        l10n.privacyPolicy,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    Text(
                      ' | ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _openUrl(AppConstants.termsOfServiceUrl),
                      child: Text(
                        l10n.termsOfService,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSubscriptionCard({
    required String title,
    required String titleAr,
    required String price,
    required String period,
    required String periodAr,
    String? savings,
    String? savingsAr,
    required bool isRecommended,
    VoidCallback? onTap,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isRecommended ? Colors.amber : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: isRecommended ? null : Border.all(color: Colors.white30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isArabic ? titleAr : title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isRecommended ? Colors.black : Colors.white,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isArabic ? (savingsAr ?? '') : (savings ?? ''),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$price${isArabic ? periodAr : period}',
                    style: TextStyle(
                      fontSize: 16,
                      color: isRecommended ? Colors.black87 : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isRecommended ? Colors.black54 : Colors.white54,
            ),
          ],
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

  Future<void> _purchaseMonthly() async {
    setState(() => _isLoading = true);
    await _purchaseService.purchaseMonthly();
    setState(() => _isLoading = false);
  }

  Future<void> _purchaseYearly() async {
    setState(() => _isLoading = true);
    await _purchaseService.purchaseYearly();
    setState(() => _isLoading = false);
  }

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    await _purchaseService.restorePurchases();
    setState(() => _isLoading = false);
  }
}
