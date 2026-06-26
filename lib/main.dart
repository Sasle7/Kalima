import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:kalima/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Isar core native library before any Isar usage
  await Isar.initializeIsarCore();

  // Lock preferred orientations to landscape and portrait on tablets
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  // Set system UI overlay style for tablet-optimized experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const KalimaApp());
}
