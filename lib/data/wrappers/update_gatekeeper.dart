
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/update_service.dart';


class UpdateGatekeeper extends StatefulWidget {
  final Widget child;
  const UpdateGatekeeper({super.key, required this.child});

  @override
  State<UpdateGatekeeper> createState() => _UpdateGatekeeperState();
}

class _UpdateGatekeeperState extends State<UpdateGatekeeper> {
  bool _shouldBlock = false;

  @override
  void initState() {
    super.initState();
    _checkIfBlocked();
  }

  Future<void> _checkIfBlocked() async {
    final box = GetStorage();
    final latestBuild = box.read('latest_build');
    final currentBuild = int.tryParse((await PackageInfo.fromPlatform()).buildNumber) ?? 0;

    if (latestBuild != null && currentBuild < latestBuild) {
      setState(() => _shouldBlock = true);
      await Future.delayed(Duration.zero);
      await UpdateService.forceUpdateIfAvailable(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldBlock) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}
