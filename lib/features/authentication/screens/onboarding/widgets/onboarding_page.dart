import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:survey_app/utils/helpers/device_helpers.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.animation,
    required this.title,
    required this.Subtitle,
  });

  final String animation;
  final String title;
  final String Subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: UDeviceHelper.getAppBarHeight()),
      child: Column(
        children: [
          Lottie.asset(animation),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          Text(Subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
