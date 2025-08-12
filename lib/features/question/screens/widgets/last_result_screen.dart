import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../navigation_menu.dart';
import '../result.dart';


class LastResultScreen extends StatelessWidget {
  const LastResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final int? responseId = storage.read('last_response_id');

    if (responseId != null) {
      return ResultScreen(responseId: responseId);
    } else {
      return const ResultPlaceholderScreen();
    }
  }
}
