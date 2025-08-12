import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../navigation_menu.dart';
import '../../controller/site_controller.dart';

class HomeSiteLocation extends StatelessWidget {
  final bool isSelectionMode;

  const HomeSiteLocation({super.key, required this.isSelectionMode});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SiteController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Select Your Site',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      body: Obx(() {
        // make Obx depend on search too
        // inside Obx(() { ... })
        final _ = controller.searchQuery.value; // keep this to react on search
        final sites = controller.sites; // filtered snapshot
        final hasAssigned = controller.assignedSites.isNotEmpty;

        if (!hasAssigned && !controller.isLoading.value) {
          return const Center(child: Text('Contact Admin for assign sites'));
        }

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                onChanged: controller.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search by site code or name',
                  prefixIcon: const Icon(Icons.search),
                  // 🔹 tap the X to clear search & instantly restore full list
                  suffixIcon: controller.searchQuery.value.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => controller.setSearchQuery(''),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 🔹 If there ARE assigned sites but the filter returned nothing, show 'No results'
              if (hasAssigned && sites.isEmpty)
                const Expanded(child: Center(child: Text('No results')))
              else
                Expanded(
                  child: GridView.builder(
                    controller: controller.scrollController,
                    itemCount: sites.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.2,
                        ),
                    itemBuilder: (context, index) {
                      final site = sites[index];
                      final siteCode = site['site_code'];
                      final siteName = site['name'] ?? '';

                      return GestureDetector(
                        onTap: () {
                          controller.setSelectedSite(siteCode);
                          NavigationController.instance.resetToHome();
                          Get.offAll(() => const NavigationMenu());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(1, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                siteCode,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                siteName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
