import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:survey_app/utils/constants/sizes.dart';
import 'package:survey_app/utils/helpers/helper_function.dart';
import '../../../common/widgets/alerts/u_alert.dart';
import '../../../data/services/auth_service.dart';
import '../../../utils/theme/theme_controller.dart';
import '../../authentication/screens/login/login.dart';
import '../controller/user_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = UHelperFunctions.isDarkMode(context);
    final themeController = Get.find<ThemeController>();
    final controller = Get.put(UserController(), permanent: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.user.value;

        /// ⛔ Prevent UI build if user is null
        if (user == null) {
          return const Center(child: Text('No user data found.'));
        }

        return ListView(
          padding: const EdgeInsets.all(USizes.defaultSpace),
          children: [
            /// Profile Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(20),
                    backgroundImage: const AssetImage(
                      'assets/logo/appLogo.png',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name ?? "No Name",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? "No Email",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.phone ?? "No Phone",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: USizes.spaceBtwSections),
            const Divider(),

            /// Update Name
            ListTile(
              leading: const Icon(Iconsax.edit),
              title: const Text('Update Name'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                final nameController = TextEditingController(
                  text: user.name ?? '',
                );

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Update Name'),
                    content: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final newName = nameController.text.trim();
                          if (newName.isEmpty) {
                            UAlert.show(
                              title: 'Error',
                              message: 'Name is required',
                            );
                            return;
                          }

                          await controller.updateUserProfile(
                            name: newName,
                            email: user.email ?? '',
                          );
                          Get.back();
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
              },
            ),

            /// Update Email
            ListTile(
              leading: const Icon(Iconsax.sms),
              title: const Text('Update Email'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                final emailController = TextEditingController(
                  text: user.email ?? '',
                );

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Update Email'),
                    content: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final newEmail = emailController.text.trim();
                          if (newEmail.isEmpty || !GetUtils.isEmail(newEmail)) {
                            UAlert.show(
                              title: 'Error',
                              message: 'Enter a valid email address',
                            );
                            return;
                          }

                          await controller.updateUserProfile(
                            name: user.name ?? '',
                            email: newEmail,
                          );
                          Get.back();
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
              },
            ),

            /// Update Password
            ListTile(
              leading: const Icon(Iconsax.lock),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                final passwordController = TextEditingController();

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Update Password'),
                    content: TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                      ),
                      obscureText: true,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final newPass = passwordController.text.trim();
                          if (newPass.length < 6) {
                            UAlert.show(
                              title: 'Error',
                              message: 'Password must be at least 6 characters',
                            );
                            return;
                          }

                          await controller.updateUserProfile(
                            name: user.name ?? '',
                            email: user.email ?? '',
                            password: newPass,
                          );
                          Get.back();
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
              },
            ),

            /// Toggle Theme
            ListTile(
              leading: const Icon(Iconsax.moon),
              title: const Text('Toggle Theme'),
              trailing: Switch(
                value: themeController.isDarkMode,
                onChanged: (value) => themeController.toggleTheme(value),
              ),
            ),

            /// Logout
            ListTile(
              leading: Icon(Iconsax.logout, color: Colors.grey.shade800),
              title: const Text('Logout'),
              onTap: () async {
                await Get.find<AuthService>().clearToken();
                Get.offAll(() => const LoginScreen());
              },
            ),

            /// App Version
            Obx(
              () => Column(
                children: [
                  ListTile(
                    leading: const Icon(Iconsax.information),
                    title: const Text('App Version'),
                    trailing: Text(
                      controller.version.value.isNotEmpty
                          ? controller.version.value
                          : 'N/A',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Iconsax.code),
                    title: const Text('Build Number'),
                    trailing: Text(
                      controller.buildNumber.value.isNotEmpty
                          ? controller.buildNumber.value
                          : 'N/A',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
