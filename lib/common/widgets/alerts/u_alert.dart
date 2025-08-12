import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UAlert {
  /// Flash-style popup alert for success, error, info
  static void show({
    required String title,
    required String message,
    Color? bgColor,
    Color? textColor,
    IconData icon = Icons.info_outline_rounded,
    Color? iconColor,
    bool isDismissible = true,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: bgColor ?? Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: iconColor ?? Colors.blueAccent),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor?.withValues(alpha: 0.8) ?? Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor ?? Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("OK", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: isDismissible,
    );
  }
}
