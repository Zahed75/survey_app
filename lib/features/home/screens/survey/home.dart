import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:survey_app/data/services/update_service.dart';
import 'package:survey_app/features/home/screens/survey/widgets/survey_info.dart';
import 'package:survey_app/features/question/screens/question.dart';
import 'package:survey_app/utils/constants/colors.dart';
import 'package:survey_app/utils/constants/texts.dart';

import '../../../../migration_helper.dart';
import '../../../question/controller/survey_controller.dart';
import '../../../site/screens/site/home_site_location.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = GetStorage();
  final controller = Get.find<SurveyController>();

  List<dynamic> surveys = [];
  bool isLoading = true;
  String siteCode = 'Loading...';

  final updater = ShorebirdUpdater();
  bool isUpdateAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadSiteCode();
    fetchSurveys();

    // After first frame: 1) check mismatch; 2) prompt uninstall old app (if present)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Dialog shows only when server != device build
      await UpdateService.promptIfVersionMismatch(context);

      if (mounted) _promptUninstallOldIfNeeded(context);
    });

    // Optional lightweight hint
    MigrationHelper.isOldInstalled().then((installed) {
      if (!mounted || !installed) return;
      Get.snackbar(
        'Old version detected',
        'Tap to uninstall the old app',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
        mainButton: TextButton(
          onPressed: () => MigrationHelper.uninstallOld(),
          child: const Text('Uninstall'),
        ),
      );
    });
  }

  /// Strong modal prompting the user to uninstall the *old* app (different package)
  Future<void> _promptUninstallOldIfNeeded(BuildContext context) async {
    final box = GetStorage();

    final mustPrompt = box.read('post_install_prompt_uninstall_old') == true;

    bool oldInstalled = false;
    try {
      oldInstalled = await MigrationHelper.isOldInstalled();
    } catch (_) {
      oldInstalled = false;
    }

    if (!oldInstalled) {
      if (mustPrompt) {
        try {
          box.write('post_install_prompt_uninstall_old', false);
        } catch (_) {}
      }
      return;
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (_) => AlertDialog(
        title: const Text('Remove old Shwapno Survey'),
        content: const Text(
          'We found the previous app installed.\n\n'
              'Please uninstall it to avoid confusion and ensure you always use the latest version.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              try {
                await MigrationHelper.uninstallOld();
              } catch (_) {}

              await Future.delayed(const Duration(seconds: 3));

              if (!mounted) return;
              bool stillThere = false;
              try {
                stillThere = await MigrationHelper.isOldInstalled();
              } catch (_) {}

              if (stillThere) {
                Get.snackbar(
                  'Uninstall not completed',
                  'Please try again.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                try {
                  box.write('post_install_prompt_uninstall_old', false);
                } catch (_) {}
                Get.snackbar(
                  'Done',
                  'Old app removed successfully.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Uninstall now'),
          ),
        ],
      ),
    );
  }

  void _loadSiteCode() {
    final stored = storage.read('selected_site_code');
    siteCode = stored ?? 'Unknown Site';
    debugPrint(
      '[HomeScreen] _loadSiteCode stored="$stored" (display="$siteCode")',
    );
  }

  Future<void> fetchSurveys() async {
    setState(() => isLoading = true);
    final stored = storage.read('selected_site_code');
    debugPrint(
      '[HomeScreen] fetchSurveys() start, storage.selected_site_code="$stored" '
          '(display="$siteCode")',
    );

    await controller.fetchSurveys();

    if (!mounted) return;
    setState(() {
      surveys = controller.surveys; // RxList -> List
      isLoading = false;
    });
    debugPrint('[HomeScreen] fetchSurveys() done: count=${surveys.length}');
  }

  Future<void> _selectSite() async {
    debugPrint('[HomeScreen] opening HomeSiteLocation…');
    await Get.to(() => const HomeSiteLocation(isSelectionMode: true));

    final updatedCode = storage.read('selected_site_code');
    debugPrint(
      '[HomeScreen] returned from HomeSiteLocation, updatedCode="$updatedCode"',
    );

    if (updatedCode != null) {
      setState(() => siteCode = updatedCode);
      debugPrint(
        '[HomeScreen] set display siteCode="$siteCode"; fetching surveys…',
      );
      await fetchSurveys();
    } else {
      debugPrint('[HomeScreen] no updatedCode; skipping fetchSurveys');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final textColor = isDark ? UColors.white : UColors.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/circleIcon.png', width: 24, height: 24),
                  Text(
                    'Home',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w900,
                      color: UColors.warning,
                    ),
                  ),
                  GestureDetector(
                    onTap: _selectSite,
                    child: Row(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            siteCode,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                              color: UColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Iconsax.arrow_down_1,
                          color: UColors.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black12 : Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                  onRefresh: fetchSurveys,
                  child: surveys.isEmpty
                      ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Text(
                          'No surveys available.',
                          style: TextStyle(color: subtitleColor),
                        ),
                      ),
                    ],
                  )
                      : ListView.builder(
                    itemCount: surveys.length,
                    itemBuilder: (context, index) {
                      final survey = surveys[index];
                      final qLen =
                          (survey['questions'] as List?)?.length ?? 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12, top: 8),
                              child: Text(
                                UTexts.availabileSurvey,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          SurveyInfo(
                            title: survey['title'] ?? '',
                            totalQuestions: qLen,
                            estimatedTime: '${qLen * 1} min',
                            onStart: () {
                              Get.to(
                                    () => QuestionScreen(surveyData: survey),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
