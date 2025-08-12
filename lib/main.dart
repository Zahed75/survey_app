// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:survey_app/data/services/auth_service.dart';
// import 'package:survey_app/my_app.dart';
// import 'package:survey_app/utils/theme/theme_controller.dart';
// import 'package:survey_app/features/site/controller/site_controller.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:survey_app/data/services/update_service.dart';
// import 'package:survey_app/features/question/controller/survey_controller.dart';
// import 'package:survey_app/navigation_menu.dart';
//
// Future<void> _requestPermissions() async {
//   await [
//     Permission.camera,
//     Permission.location,
//     Permission.storage,
//     Permission.manageExternalStorage,
//     Permission.photos,
//     Permission.notification,
//     Permission.mediaLibrary,
//   ].request();
// }
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await GetStorage.init();
//   await _requestPermissions();
//
//   // ⛔ Check for mandatory update before app starts
//   final shouldExit = await UpdateService.checkAndInstallBlockingUpdate();
//   if (shouldExit) return;
//
//   // ✅ Initialize services
//   await Get.putAsync(() => AuthService().init());
//   Get.put(ThemeController());
//   Get.put(NavigationController());
//   Get.put(SurveyController());
//
//   if (!Get.isRegistered<SiteController>()) {
//     Get.put(SiteController());
//   }
//
//   runApp(const MyApp());
// }
//
//
//



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:survey_app/data/services/auth_service.dart';
import 'package:survey_app/my_app.dart';
import 'package:survey_app/utils/theme/theme_controller.dart';
import 'package:survey_app/features/site/controller/site_controller.dart';
import 'package:survey_app/features/question/controller/survey_controller.dart';

import 'navigation_menu.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await GetStorage.init();

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
