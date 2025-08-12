import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_app/data/models/user_model.dart';
import 'package:survey_app/data/repository/user_reposiotry.dart';
import 'package:survey_app/utils/constants/storage_keys.dart';
import '../../../common/widgets/alerts/u_alert.dart';
import '../../../data/repository/update_apk_repository.dart';

class UserController extends GetxController {
  final _repo = UserRepository();
  final _box = GetStorage();
  final _updateRepo = UpdateRepository();
  var version = ''.obs;
  var buildNumber = ''.obs;

  var user = Rxn<UserModel>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedUser(); // Load local data
    _fetchAppVersion();
    fetchUserProfile(); // Fetch from server
  }

  /// ✅ Load user from GetStorage cache
  void _loadCachedUser() {
    final cached = _box.read(StorageKeys.user);
    if (cached != null && cached is Map<String, dynamic>) {
      try {
        final extracted = cached['user'] ?? cached;
        user.value = UserModel.fromJson(Map<String, dynamic>.from(extracted));
      } catch (e) {
        print('❌ Failed to load cached user: $e');
      }
    }
  }

  /// ✅ Fetch user profile from server and update local
  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;

      final fetchedUser = await _repo.fetchUserProfile();
      user.value = fetchedUser;
      user.refresh();

      await _box.write(StorageKeys.user, {'user': fetchedUser.toJson()});
    } catch (e) {
      UAlert.show(title: 'Error', message: 'Failed to load profile');
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Update profile and sync
  Future<void> updateUserProfile({
    required String name,
    required String email,
    String? password,
  }) async {
    try {
      isLoading.value = true;

      final updated = await _repo.updateUserProfile(
        name: name,
        email: email,
        password: password,
      );

      user.value = updated;
      user.refresh();

      await _box.write(StorageKeys.user, {'user': updated.toJson()});
      UAlert.show(title: 'Success', message: 'Profile updated successfully');
    
      await fetchUserProfile(); // Refresh again
    } catch (e) {
      UAlert.show(title: 'Error', message: 'Update failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAppVersion() async {
    final result = await _updateRepo.fetchAppVersion();
    if (result != null) {
      version.value = result.version;
      buildNumber.value = '+${result.buildNumber}';
    }
  }
}
