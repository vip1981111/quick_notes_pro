import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import '../providers/settings_provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/constants.dart';
import 'premium_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Language
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(settings.locale.languageCode == 'ar' ? 'العربية' : 'English'),
            onTap: () => _showLanguageDialog(context, settings),
          ),

          // Dark Mode
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: Text(l10n.darkMode),
            value: settings.isDarkMode,
            onChanged: (value) => settings.setDarkMode(value),
          ),

          const Divider(),

          // Subscribe to Premium
          if (!settings.isPremium)
            ListTile(
              leading: const Icon(Icons.workspace_premium, color: Colors.amber),
              title: Text(l10n.removeAds),
              subtitle: Text(settings.locale.languageCode == 'ar'
                  ? 'شهري \$1.99 | سنوي \$14.99'
                  : 'Monthly \$1.99 | Yearly \$14.99'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              ),
            ),

          // Restore Purchases
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(l10n.restorePurchases),
            onTap: () => _restorePurchases(context),
          ),

          const Divider(),

          // Rate App
          ListTile(
            leading: const Icon(Icons.star),
            title: Text(l10n.rateApp),
            onTap: () => _rateApp(),
          ),

          // Share App
          ListTile(
            leading: const Icon(Icons.share),
            title: Text(l10n.shareApp),
            onTap: () => _shareApp(l10n),
          ),

          // Contact Us
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(l10n.contactUs),
            subtitle: const Text('vip1981.1@gmail.com'),
            onTap: () => _contactUs(),
          ),

          const Divider(),

          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text(l10n.privacyPolicy),
            onTap: () => _openUrl(AppConstants.privacyPolicyUrl),
          ),

          // Terms of Service
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(l10n.termsOfService),
            onTap: () => _openUrl(AppConstants.termsOfServiceUrl),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language / اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioGroup<String>(
              groupValue: settings.locale.languageCode,
              onChanged: (String? value) {
                if (value != null) {
                  settings.setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('English'),
                    leading: Radio<String>(value: 'en'),
                    onTap: () {
                      settings.setLocale(const Locale('en'));
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('العربية'),
                    leading: Radio<String>(value: 'ar'),
                    onTap: () {
                      settings.setLocale(const Locale('ar'));
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _restorePurchases(BuildContext context) {
    // Will be implemented in Part 4
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checking purchases...')),
    );
  }

  void _rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;

    try {
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      } else {
        // Fallback: فتح صفحة التطبيق في App Store مباشرة
        await inAppReview.openStoreListing(appStoreId: AppConstants.appStoreId);
      }
    } catch (e) {
      // Fallback إذا فشل كل شيء
      final uri = Uri.parse('https://apps.apple.com/app/id${AppConstants.appStoreId}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareApp(AppLocalizations l10n) {
    Share.share('Check out ${l10n.appTitle}! Download now.');
  }

  void _contactUs() async {
    final uri = Uri.parse('mailto:vip1981.1@gmail.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
