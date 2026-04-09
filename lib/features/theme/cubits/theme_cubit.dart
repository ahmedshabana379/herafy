import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/core/networks/cache_helper.dart';

class ThemeCubit extends Cubit<bool> {
  ThemeCubit() : super(false) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final isDarkMode = await CacheHelper.getThemeMode();
    emit(isDarkMode);
  }

  Future<void> toggleTheme() async {
    final newMode = !state;
    await CacheHelper.setThemeMode(newMode);
    emit(newMode);
  }

  void setThemeMode(bool isDarkMode) async {
    await CacheHelper.setThemeMode(isDarkMode);
    emit(isDarkMode);
  }
}
