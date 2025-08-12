import 'package:flutter/material.dart';
import 'package:survey_app/utils/constants/sizes.dart';

class SurveyCategoryScore extends StatelessWidget {
  const SurveyCategoryScore({
    super.key,
    required this.categoryScores,
    required this.isDark,
  });

  final List<Map<String, dynamic>> categoryScores;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: categoryScores
          .where(
            (cat) => (cat['questions'] as List).any((q) => q.type != 'remarks'),
          )
          .map((category) {
            final questions = category['questions']
                .where((q) => q.type != 'remarks')
                .toList();

            return Container(
              margin: const EdgeInsets.only(bottom: USizes.spaceBtwItems),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category['name'] ?? 'General',
                      style: theme.textTheme.bodyLarge,
                    ),
                    Text(
                      "${category['score']} / ${category['total']}",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                children: questions.map<Widget>((q) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Question
                        Text(
                          q.text ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),

                        /// Answer
                        if (q.selectedChoice != null)
                          Text(
                            "Answer: ${q.selectedChoice.text}",
                            style: theme.textTheme.bodySmall,
                          )
                        else if (q.answer != null &&
                            q.answer.toString().isNotEmpty)
                          Text(
                            "Answer: ${q.answer}",
                            style: theme.textTheme.bodySmall,
                          )
                        else if (q.location != null)
                          Text(
                            "Location: ${q.location.lat}, ${q.location.lon}",
                            style: theme.textTheme.bodySmall,
                          )
                        else if (q.imageUrl != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Answer: Image uploaded",
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  "https://survey-backend.shwapno.app/media/${q.imageUrl}",
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Text('⚠️ Failed to load image'),
                                ),
                              ),
                            ],
                          )
                        else
                          Text("Answer: N/A", style: theme.textTheme.bodySmall),

                        /// Marks
                        if (q.marks != null)
                          Text(
                            "Marks: ${q.obtained} / ${q.marks}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          })
          .toList(),
    );
  }
}
