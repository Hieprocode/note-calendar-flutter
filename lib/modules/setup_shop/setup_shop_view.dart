import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'setup_shop_controller.dart';

class SetupShopView extends GetView<SetupShopController> {
  const SetupShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tạo Cửa Hàng")),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar (Giữ nguyên)
                Center(
                  child: GestureDetector(
                    onTap: () => controller.pickImage(),
                    child: Obx(() {
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: controller.selectedImage.value != null
                            ? FileImage(controller.selectedImage.value!)
                            : null,
                        child: controller.selectedImage.value == null
                            ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                            : null,
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(child: Text("Chạm để tải logo", style: TextStyle(color: Colors.grey))),
                
                const SizedBox(height: 30),

                // Tên Shop
                TextField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: "Tên cửa hàng",
                    hintText: "Ví dụ: Sân bóng Hùng Cường",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.store),
                  ),
                ),
                
                const SizedBox(height: 20),

                // --- THAY ĐỔI Ở ĐÂY: TextField nhập ngành nghề ---
                TextField(
                  controller: controller.industryController,
                  decoration: const InputDecoration(
                    labelText: "Ngành nghề kinh doanh",
                    hintText: "VD: Spa, Nail, Bói bài, Cho thuê xe...",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work),
                  ),
                ),
                // ------------------------------------------------

                const SizedBox(height: 40),

                // Nút Tạo
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => controller.createShop(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("HOÀN TẤT & BẮT ĐẦU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          Obx(() => controller.isLoading.value 
            ? Container(
                color: Colors.black54, 
                child: const Center(child: CircularProgressIndicator(color: Colors.white)))
            : const SizedBox.shrink()
          ),
        ],
      ),
    );
  }
}