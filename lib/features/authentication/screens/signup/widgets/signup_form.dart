import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:survey_app/common/widgets/button/elevated_button.dart';
import 'package:survey_app/features/authentication/controllers/signup/register_controller.dart';
import 'package:survey_app/utils/constants/colors.dart';
import 'package:survey_app/utils/constants/sizes.dart';
import 'package:survey_app/utils/constants/texts.dart';
import 'package:survey_app/utils/helpers/helper_function.dart';

class USignupForm extends StatefulWidget {
  const USignupForm({super.key});

  @override
  State<USignupForm> createState() => _USignupFormState();
}

class _USignupFormState extends State<USignupForm> {
  bool _obscurePassword = true;
  String? _selectedDesignation;

  final designations = [
    'Zonal Manager (ZM)',
    'Outlet Manager (OM)',
    'Inventory & Cash Management Officer (ICMO)',
    'Back store Manager (BSM)',
    'Manager',
    'Sales',
    'Support',
    'HR',
    'Developer',
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());
    final dark = UHelperFunctions.isDarkMode(context);

    return Column(
      children: [
        TextFormField(
          controller: controller.name,
          decoration: const InputDecoration(
            labelText: UTexts.firstName,
            prefixIcon: Icon(Iconsax.direct_right),
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        TextFormField(
          controller: controller.email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: UTexts.email,
            prefixIcon: Icon(Iconsax.direct_right),
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        TextFormField(
          controller: controller.phoneNumber,
          keyboardType: TextInputType.number,
          maxLength: 11,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          decoration: const InputDecoration(
            prefixIcon: Icon(Iconsax.call),
            prefixText: '+88 ',
            labelText: UTexts.phoneNumber,
            counterText: '',
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        TextFormField(
          controller: controller.staffId,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: const InputDecoration(
            labelText: UTexts.staffId,
            prefixIcon: Icon(Iconsax.direct_right),
            counterText: '',
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        DropdownButtonFormField<String>(
          value: _selectedDesignation,
          isExpanded: true,
          icon: const Icon(Iconsax.arrow_down_1),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          style: Theme.of(context).textTheme.bodyMedium,
          items: designations.map((role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Row(
                children: [
                  const Icon(Iconsax.user, size: 18, color: UColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      role,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDesignation = value;
              controller.designation.text = value ?? '';
            });
          },
          decoration: InputDecoration(
            labelText: UTexts.designation,
            prefixIcon: const Icon(Iconsax.briefcase),
            filled: true,
            fillColor: dark ? Colors.black12 : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        TextFormField(
          controller: controller.password,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            prefixIcon: const Icon(Iconsax.password_check),
            labelText: UTexts.password,
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Iconsax.eye : Iconsax.eye_slash),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: USizes.spaceBtwInputFields),

        Row(
          children: [
            Checkbox(value: true, onChanged: (value) {}),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: UTexts.iAgreeTo),
                    TextSpan(
                      text: ' ${UTexts.privacyPolicy}',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: dark ? UColors.white : UColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(
                      text: ' ${UTexts.and} ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextSpan(
                      text: UTexts.termsOfUse,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: dark ? UColors.white : UColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: USizes.spaceBtwItems / 2),

        Obx(
          () => UElevatedButton(
            onPressed: controller.registerUser,
            child: controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(UTexts.createAccount),
          ),
        ),
      ],
    );
  }
}
