import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:herafy/features/theme/cubits/theme_cubit.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDarkMode) {
        return Center(
          child: IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.yellow[600] : Colors.orange,
              size: 28,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
            splashRadius: 24,
          ),
        );
      },
    );
  }
}
