import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iconsax/iconsax.dart';
import 'package:survey_app/utils/constants/colors.dart';
import 'package:survey_app/utils/constants/sizes.dart';
import 'package:survey_app/utils/helpers/device_helpers.dart';
import 'package:survey_app/utils/helpers/helper_function.dart';

class UAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UAppBar({
    super.key,
    this.title,
    this.showBackArrow = false,
    this.onBackPressed,
    this.leadingIcon,
    this.actions,
    this.LeadingOnPressed,
    this.height,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? LeadingOnPressed;
  final VoidCallback? onBackPressed;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final dark = UHelperFunctions.isDarkMode(context);
    return AppBar(
      toolbarHeight:
          height ?? UDeviceHelper.getAppBarHeight(), // 👈 Use toolbarHeight
      automaticallyImplyLeading: false,
      leading: showBackArrow
          ? IconButton(
              onPressed: LeadingOnPressed ?? Get.back,
              icon: Icon(
                Iconsax.arrow_left,
                color: dark ? UColors.white : UColors.dark,
              ),
            )
          : leadingIcon != null
          ? IconButton(onPressed: LeadingOnPressed, icon: Icon(leadingIcon))
          : null,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: USizes.md),
        child: title,
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(height ?? UDeviceHelper.getAppBarHeight());
}
