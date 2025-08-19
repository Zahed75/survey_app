import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:survey_app/data/services/auth_service.dart';
import 'package:survey_app/data/services/update_service.dart'; // ⬅ reset + future checks
import 'package:survey_app/my_app.dart';
import 'package:survey_app/utils/theme/theme_controller.dart';
import 'package:survey_app/features/site/controller/site_controller.dart';
import 'package:survey_app/features/question/controller/survey_controller.dart';

import 'navigation_menu.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await GetStorage.init();
  GetStorage().write('update_installed_once', false);

  // ✅ Reset the “only-this-run” suppression flag on every cold start
  try {
    final box = GetStorage();
    box.write('update_installed_once', false);
  } catch (_) {}

  // ⛔ DO NOT request permissions or run blocking update here

  await Get.putAsync(() => AuthService().init());
  Get.put(ThemeController());
  Get.put(NavigationController());
  Get.put(SurveyController());
  if (!Get.isRegistered<SiteController>()) {
    Get.put(SiteController());
  }

  runApp(const MyApp());
}
