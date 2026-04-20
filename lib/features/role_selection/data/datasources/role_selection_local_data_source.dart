import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/domain/entities/user_role.dart';

abstract class RoleSelectionLocalDataSource {
  Future<void> saveRole(UserRole role);
  Future<UserRole?> getRole();
}

class RoleSelectionLocalDataSourceImpl implements RoleSelectionLocalDataSource {
  static const _key = 'selected_role';

  final SharedPreferences sharedPreferences;
  RoleSelectionLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveRole(UserRole role) async {
    await sharedPreferences.setString(_key, role.name);
  }

  @override
  Future<UserRole?> getRole() async {
    final value = sharedPreferences.getString(_key);
    if (value == null) return null;
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.user,
    );
  }
}
