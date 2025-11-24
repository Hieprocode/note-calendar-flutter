import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class SettingsController extends BaseController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  Future<void> logout() async {
    await _authRepo.logout();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}