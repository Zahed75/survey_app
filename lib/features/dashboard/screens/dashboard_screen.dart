import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:survey_app/common/widgets/appBar/appbar.dart';
import 'package:survey_app/features/dashboard/controller/survey_report_controller.dart';
import 'package:survey_app/utils/constants/sizes.dart';

import '../../../navigation_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final controller = Get.put(SurveyReportController());
  bool isMyOutletSelected = true;
  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  void fetchReport() {
    final now = DateTime.now();

    final start = selectedRange?.start ?? DateTime(now.year, now.month, 1);
    final end = selectedRange?.end ?? DateTime(now.year, now.month + 1, 0);

    final startStr = DateFormat('MM/dd/yyyy').format(start);
    final endStr = DateFormat('MM/dd/yyyy').format(end);

    print("📅 Fetching reports from $startStr to $endStr, level: ${isMyOutletSelected ? 'myoutlet' : 'national'}");

    controller.fetchReports(
      level: isMyOutletSelected ? 'myoutlet' : 'national',
      startDate: startStr,
      endDate: endStr,
    );
  }

  void _openDatePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      initialDateRange: selectedRange ??
          DateTimeRange(
            start: DateTime(DateTime.now().year, DateTime.now().month, 1),
            end: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
          ),
    );
    if (picked != null) {
      setState(() => selectedRange = picked);
      fetchReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UAppBar(
        showBackArrow: true,
        onBackPressed: () {
          final id = controller.reportList.firstOrNull?.responseId;
          if (id != null) {
            GetStorage().write('last_response_id', id);
            Get.offAll(() => const NavigationMenu(), arguments: {'selectedIndex': 1});
          } else {
            Get.back();
          }
        },
        title: const Center(child: Text("Dashboard")),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = controller.reportList;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(USizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Row
              Row(
                children: [
                  IconButton(
                    onPressed: _openDatePicker,
                    icon: const Icon(Iconsax.filter),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => isMyOutletSelected = true);
                        fetchReport();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMyOutletSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        foregroundColor: isMyOutletSelected ? Colors.white : Colors.black,
                      ),
                      child: const Text("My Outlets"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => isMyOutletSelected = false);
                        fetchReport();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isMyOutletSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        foregroundColor: !isMyOutletSelected ? Colors.white : Colors.black,
                      ),
                      child: const Text("Nationals"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: USizes.spaceBtwSections),
              const Divider(),
              const SizedBox(height: USizes.spaceBtwSections),

              Text(
                isMyOutletSelected ? "My Outlet Scores" : "National Scores",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: USizes.spaceBtwItems),

              if (reports.isEmpty)
                const Text("No data available for the selected date range."),
              if (reports.isNotEmpty)
                ...reports.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  return _buildScoreCard(
                    context,
                    index: index,
                    outlet: item.siteCode,
                    score: item.score,
                    total: 100,
                    showPosition: isMyOutletSelected,
                    timestamp: item.timestamp,
                  );
                }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildScoreCard(
      BuildContext context, {
        required int index,
        required String outlet,
        required int score,
        required int total,
        required bool showPosition,
        required DateTime timestamp,
      }) {
    final localTime = timestamp.toLocal();
    final formattedTime = DateFormat('hh:mm a, dd MMM yyyy').format(localTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showPosition ? "$index. $outlet" : outlet,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  "Time: $formattedTime",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            "$score / $total",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
