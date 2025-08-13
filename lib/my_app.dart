import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:survey_app/features/authentication/screens/login/login.dart';
import 'package:survey_app/features/authentication/screens/onboarding/onboarding.dart';
import 'package:survey_app/navigation_menu.dart';
import 'package:survey_app/utils/theme/theme.dart';
import 'package:survey_app/data/services/auth_service.dart';
import 'package:survey_app/utils/theme/theme_controller.dart';
import 'package:survey_app/utils/constants/storage_keys.dart';
import 'package:survey_app/data/services/update_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final themeController = Get.find<ThemeController>();
    final box = GetStorage();

    return Obx(
          () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: UAppTheme.lightTheme,
        darkTheme: UAppTheme.darkTheme,
        themeMode: themeController.themeMode,
        home: _AppRoot(
          authService: authService,
          seenOnboarding: box.read(StorageKeys.onboardingSeen) == true,
        ),
      ),
    );
  }
}

class _AppRoot extends StatefulWidget {
  final AuthService authService;
  final bool seenOnboarding;

  const _AppRoot({
    required this.authService,
    required this.seenOnboarding,
  });

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  late Future<bool> loginFuture;

  // Minimal “startup” permissions; ask others just-in-time on the screen that needs them
  Future<void> _requestStartupPermissions() async {
    final toRequest = <Permission>[
      if (Platform.isAndroid) Permission.notification,
      // If you truly MUST ask these at launch, uncomment:
      // Permission.camera,
      // Permission.location,
    ];
    for (final p in toRequest) {
      await p.request();
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  @override
  void initState() {
    super.initState();
    loginFuture = widget.authService.isLoggedIn();

    // Run post-frame so dialogs show over a live widget tree
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ✅ Show the first frame immediately
      FlutterNativeSplash.remove();

      // ✅ Fire-and-forget; don't block the UI thread waiting for update check
      unawaited(_requestStartupPermissions());

      // ✅ Fire-and-forget update prompt. Using root navigator keeps it stable
      unawaited(UpdateService.forceUpdateIfAvailable(Get.overlayContext ?? context));
    });
  }


  @override
  Widget build(BuildContext context) {
    if (!widget.seenOnboarding) {
      return const OnboardingScreen();
    }

    return FutureBuilder<bool>(
      future: loginFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data == true) {
          return const NavigationMenu();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
