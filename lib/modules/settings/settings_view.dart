import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt")),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => controller.logout(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade100,
            foregroundColor: Colors.red,
          ),
          icon: const Icon(Icons.logout),
          label: const Text("Đăng xuất (Logout)"),
        ),
      ),
    );
  }
}