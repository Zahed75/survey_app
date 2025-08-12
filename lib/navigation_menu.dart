import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:survey_app/features/dashboard/screens/coming_soon.dart';

import 'features/dashboard/screens/dashboard_screen.dart';
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

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),

      bottomNavigationBar: Obx(
        () => NavigationBar(
          elevation: 0,
          backgroundColor: dark ? UColors.dark : UColors.light,
          indicatorColor: dark
              ? UColors.light.withValues(alpha: 0.1)
              : UColors.dark.withValues(alpha: 0.1),
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) {
            controller.selectedIndex.value = index;
          },
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
            NavigationDestination(icon: Icon(Iconsax.shop), label: 'History'),
            NavigationDestination(
              icon: Icon(Iconsax.menu_board),
              label: 'Dashboard',
            ),
            NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();
  RxInt selectedIndex = 0.obs;

  void resetToHome() {
    selectedIndex.value = 0;
  }

  List<Widget> get screens => [
    const HomeScreen(),
    _buildResultScreen(),
    // const DashboardScreen(),
    const ComingSoon(),
    const ProfileScreen(),
  ];

  Widget _buildResultScreen() {
    final lastId = GetStorage().read('last_response_id');
    if (lastId != null) {
      return ResultScreen(responseId: lastId);
    } else {
      return const ResultPlaceholderScreen();
    }
  }
}

/// Placeholder shown when there's no response ID (like static nav tap)
class ResultPlaceholderScreen extends StatelessWidget {
  const ResultPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Survey Result')),
      body: const Center(
        child: Text(
          "Submit a survey to view results here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
