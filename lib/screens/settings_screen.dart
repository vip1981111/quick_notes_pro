import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';
import '../l10n/generated/app_localizations.dart';
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

          // Remove Ads
          if (!settings.isPremium)
            ListTile(
              leading: const Icon(Icons.workspace_premium, color: Colors.amber),
              title: Text(l10n.removeAds),
              subtitle: Text(l10n.getPremium),
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
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language / اللغة'),
        content: RadioGroup<String>(
          groupValue: settings.locale.languageCode,
          onChanged: (v) {
            settings.setLocale(Locale(v!));
            Navigator.pop(context);
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
      ),
    );
  }

  void _restorePurchases(BuildContext context) {
    // Will be implemented in Part 4
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checking purchases...')),
    );
  }

  void _rateApp() {
    // TODO: Add actual store links
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
