import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_app/features/home/screens/survey/widgets/survey_info.dart';
import 'package:survey_app/features/question/screens/question.dart';
import 'package:survey_app/utils/constants/colors.dart';
import 'package:survey_app/utils/constants/texts.dart';
import '../../../../data/services/update_service.dart';
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
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   UpdateService.forceUpdateIfAvailable(context);
    // });
    _loadSiteCode();
    fetchSurveys();
  }

  void _loadSiteCode() {
    siteCode = storage.read('selected_site_code') ?? 'Unknown Site';
  }

  Future<void> fetchSurveys() async {
    setState(() => isLoading = true);
    await controller.fetchSurveys();
    if (!mounted) return;
    setState(() {
      surveys = controller.surveys;
      isLoading = false;
    });
  }

  Future<void> _selectSite() async {
    await Get.to(() => const HomeSiteLocation(isSelectionMode: true));
    final updatedCode = storage.read('selected_site_code');
    if (updatedCode != null) {
      setState(() {
        siteCode = updatedCode;
      });
      fetchSurveys();
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      final status = await updater.checkForUpdate();
      if (status == UpdateStatus.outdated) {
        setState(() => isUpdateAvailable = true);
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }
  }

  void _startUpdateCheckTimer() {
    Future.delayed(Duration(seconds: 10), () async {
      await _checkForUpdates();
      if (isUpdateAvailable) _showUpdateBanner();
    });
  }

  void _showUpdateBanner() {
    if (!isUpdateAvailable) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('A new update is available. Tap here to update!'),
        action: SnackBarAction(
          label: 'Update Now',
          onPressed: () async => await _applyUpdate(),
        ),
        duration: Duration(days: 1),
      ),
    );
  }

  Future<void> _applyUpdate() async {
    try {
      await GetStorage().erase();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await updater.update();
      SystemNavigator.pop();
    } catch (e) {
      print("❌ Error applying update: $e");
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo/appLogo.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    'Home',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: UColors.darkerGrey,
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
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black12 : Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : surveys.isEmpty
                    ? Center(
                        child: Text(
                          'No surveys available.',
                          style: TextStyle(color: subtitleColor),
                        ),
                      )
                    : ListView.builder(
                        itemCount: surveys.length,
                        itemBuilder: (context, index) {
                          final survey = surveys[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index == 0)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 12,
                                    top: 8,
                                  ),
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
                                title: survey['title'],
                                totalQuestions:
                                    survey['questions']?.length ?? 0,
                                estimatedTime:
                                    '${(survey['questions']?.length ?? 0) * 1} min',
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
          ],
        ),
      ),
    );
  }
}
