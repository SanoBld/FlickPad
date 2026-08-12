import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final settings = AppSettings();
  await settings.load();

  runApp(
    ChangeNotifierProvider.value(
      value: settings,
      child: const FlickPadApp(),
    ),
  );
}
