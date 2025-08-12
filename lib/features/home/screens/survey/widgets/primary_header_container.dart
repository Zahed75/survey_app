import 'package:flutter/material.dart';
import 'package:survey_app/common/custom_shapes/circular_container.dart';
import 'package:survey_app/utils/constants/colors.dart';
import 'package:survey_app/utils/helpers/device_helpers.dart';


class UPrimaryHeaderContainer extends StatelessWidget {
  const UPrimaryHeaderContainer({super.key, required this.child, this.height});

  final Widget child;
  final double? height; // 👈 Add height parameter

  @override
  Widget build(BuildContext context) {
    final double containerHeight =
        height ?? UDeviceHelper.getScreenHeight(context) * 0.3;

    return Container(
      height: containerHeight,
      color: UColors.primary,
      child: Stack(
        children: [
          Positioned(
            top: -150,
            right: -160,
            child: UCircularContainer(
              height: containerHeight * 1.3,
              width: containerHeight * 1.3,
              backgroundColor: UColors.white.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            top: 50,
            right: -250,
            child: UCircularContainer(
              height: containerHeight * 1.3,
              width: containerHeight * 1.3,
              backgroundColor: UColors.white.withValues(alpha: 0.1),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
