import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Thay bằng Logo của bạn sau này
            Icon(Icons.calendar_month_outlined, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              "Note Calendar",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(), // Vòng xoay loading
          ],
        ),
      ),
    );
  }
}