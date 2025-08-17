// navigation_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:survey_app/features/dashboard/screens/coming_soon.dart';

import 'features/home/screens/survey/home.dart';
import 'features/profile/screens/profile.dart';
import 'features/question/screens/result.dart';
import 'utils/constants/colors.dart';
import 'utils/helpers/helper_function.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final bool dark = UHelperFunctions.isDarkMode(context);

    // Modern surface colors
    final surface = dark ? UColors.dark : UColors.light;
    final indicator = dark
        ? UColors.light.withValues(alpha: 0.08)
        : UColors.dark.withValues(alpha: 0.08);

    return Scaffold(
      // Smooth body transition between tabs (no logic change)
      body: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: controller.screens[controller.selectedIndex.value],
        ),
      ),

      // Modern, “carded” bottom bar (same destinations & behavior)
      bottomNavigationBar: Obx(() {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // Soft shadow + glassy surface
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(dark ? 0.35 : 0.08),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(
                      color:
                          (dark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.05))
                              .withOpacity(0.08),
                    ),
                  ),
                  child: NavigationBar(
                    height: 64,
                    elevation: 0,
                    backgroundColor: surface,
                    indicatorColor: indicator,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                    selectedIndex: controller.selectedIndex.value,
                    onDestinationSelected: (index) {
                      // haptic for delight (no logic change)
                      HapticFeedback.lightImpact();
                      controller.selectedIndex.value = index;
                    },
                    destinations: [
                      const NavigationDestination(
                        icon: Icon(Iconsax.home),
                        label: 'Home',
                      ),

                      // History tab — we add a tiny “dot” when there is no last result yet
                      NavigationDestination(
                        icon: _HistoryIcon(),
                        label: 'History',
                      ),

                      const NavigationDestination(
                        icon: Icon(Iconsax.menu_board),
                        label: 'Dashboard',
                      ),
                      const NavigationDestination(
                        icon: Icon(Iconsax.user),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// A small composable that shows a subtle dot over the History icon
/// when the user hasn't submitted any survey yet (purely visual; no logic change).
class _HistoryIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lastId = GetStorage().read('last_response_id');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Iconsax.shop),
        if (lastId == null)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();
  RxInt selectedIndex = 0.obs;

  void resetToHome() {
    selectedIndex.value = 0;
  }

  List<Widget> get screens => const [
    HomeScreen(),
    _ResultTabEntryPoint(), // same order & behavior
    // Dashboard screen intentionally replaced with ComingSoon in your code
    ComingSoon(),
    ProfileScreen(),
  ];
}

/// We keep the “History” tab logic identical:
/// - If there is a last_response_id, show ResultScreen(responseId: ...)
/// - Otherwise, show the placeholder screen.
/// This wrapper avoids rebuilding the whole NavigationMenu when GetStorage changes.
class _ResultTabEntryPoint extends StatelessWidget {
  const _ResultTabEntryPoint();

  @override
  Widget build(BuildContext context) {
    final lastId = GetStorage().read('last_response_id');
    if (lastId != null) {
      return ResultScreen(responseId: lastId);
    } else {
      return const ResultPlaceholderScreen();
    }
  }
}

/// Placeholder shown when there's no response ID (unchanged UX)
class ResultPlaceholderScreen extends StatelessWidget {
  const ResultPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Survey Result')),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
            ),
          ),
          child: const Text(
            "Submit a survey to view results here.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.5),
          ),
        ),
      ),
    );
  }
}
