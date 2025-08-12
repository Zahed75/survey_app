import 'package:flutter/material.dart';
import 'package:survey_app/utils/constants/sizes.dart';
import 'package:survey_app/utils/constants/texts.dart';

class ULoginHeader extends StatelessWidget {
  const ULoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          UTexts.loginTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: USizes.sm),
        Text(
          UTexts.loginSubTitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
