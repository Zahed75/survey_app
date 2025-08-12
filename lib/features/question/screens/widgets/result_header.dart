import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SurveyResultHeader extends StatelessWidget {
  const SurveyResultHeader({
    super.key,
    required this.totalScore,
    required this.maxScore,
    required this.resultPercent,
    required this.siteCode,
    required this.siteName,
    required this.timestamp,
  });

  final int totalScore;
  final int maxScore;
  final String resultPercent;
  final String siteCode;
  final String? siteName;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    final double progress = totalScore / (maxScore == 0 ? 1 : maxScore);
    final formattedDate = DateFormat('MMMM d, y').format(timestamp);

    return Row(
      children: [
        /// Left Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line 1: Site code
              Text(
                "$siteCode",
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // Line 2: Site name (with ellipsis if long)
              Text(
                "${siteName ?? ''}",
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Date
              Text(
                "$formattedDate",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),

              // Total Score
              Text(
                "Total Score: $totalScore / $maxScore",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        /// Animated Circular Score
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress),
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          builder: (context, animatedValue, _) {
            return SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background Circle
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade200,
                      ),
                    ),
                  ),

                  // Foreground Progress
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: animatedValue,
                      strokeWidth: 10,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                  // Center Percentage Text
                  Text(
                    '$resultPercent',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
