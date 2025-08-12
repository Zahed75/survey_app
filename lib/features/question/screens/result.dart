import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_app/features/question/controller/survey_result_controller.dart';
import 'package:survey_app/features/question/screens/widgets/categoryScoreSurvey.dart';
import 'package:survey_app/features/question/screens/widgets/result_header.dart';
import 'package:survey_app/navigation_menu.dart';
import 'package:survey_app/utils/constants/sizes.dart';

class ResultScreen extends StatefulWidget {
  final int responseId;

  const ResultScreen({super.key, required this.responseId});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final controller = Get.put(SurveyResultController());

  // result.dart (ResultScreen)
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1) Try to show cached result instantly
      await controller.loadCachedResult(widget.responseId);
      // 2) Then refresh in background
      await controller.loadResult(widget.responseId);
      GetStorage().write('last_response_id', widget.responseId);
    });
  }


  @override
  void dispose() {
    controller.clearResult();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Center(child: Text("Survey Result")),
          actions: [
            IconButton(
              onPressed: () {
                final nav = Get.find<NavigationController>();
                nav.selectedIndex.value = 0;
                Get.offAll(() => const NavigationMenu());
              },
              icon: const Icon(Icons.close),
              tooltip: 'Close and go Home',
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = controller.result.value;
          if (data == null) {
            return const Center(child: Text("Failed to load survey result"));
          }

          final totalScore = data.overall.obtainedMarks;
          final maxScore = data.overall.totalMarks;
          final String resultPercent =
              '${(data.overall.percentage).toStringAsFixed(1)}%';

          final List<Map<String, dynamic>> categoryScores = data.categories
              .map((cat) {
                final questions = cat.questions
                    .where((q) => q.type != 'remarks')
                    .toList();
                return {
                  "name": cat.name,
                  "score": cat.obtainedMarks,
                  "total": cat.totalMarks,
                  "questions": questions,
                };
              })
              .where((cat) => (cat['questions'] as List).isNotEmpty)
              .toList();

          // 📝 Extract remarks
          String feedback = "No feedback submitted.";
          try {
            final remarks = data.categories
                .expand((cat) => cat.questions)
                .firstWhere((q) => q.type == 'remarks' && q.answer != null);
            feedback = remarks.answer!;
          } catch (_) {}

          return SingleChildScrollView(
            padding: const EdgeInsets.all(USizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SurveyResultHeader(
                  totalScore: totalScore.toInt(),
                  maxScore: maxScore.toInt(),
                  resultPercent: resultPercent,
                  siteCode: data.siteCode ?? 'N/A',
                  siteName: data.siteName, // ✅ new
                  timestamp: data.timestamp ?? data.submittedAt,
                ),



                const SizedBox(height: USizes.spaceBtwSections),
                const Divider(),
                const SizedBox(height: USizes.spaceBtwSections),

                Text(
                  "Category Scores",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: USizes.spaceBtwItems),

                SurveyCategoryScore(
                  categoryScores: categoryScores,
                  isDark: isDark,
                ),

                const SizedBox(height: USizes.spaceBtwSections),
                Text(
                  "Submitted Feedback",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feedback,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
