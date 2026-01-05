import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'services/ad_service.dart';
import 'services/purchase_service.dart';
import 'providers/notes_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseService = DatabaseService();
  await databaseService.init();

  final adService = AdService();
  await adService.init();

  final purchaseService = PurchaseService();
  await purchaseService.init();

  runApp(MyApp(databaseService: databaseService));
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;

  const MyApp({super.key, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider(databaseService)),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          AdService().setPremium(settings.isPremium);
          return MaterialApp(
            title: 'Quick Notes Pro',
            debugShowCheckedModeBanner: false,
            theme: settings.theme,
            locale: settings.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
