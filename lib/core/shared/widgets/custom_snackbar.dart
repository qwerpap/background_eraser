import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:background_eraser/core/theme/app_colors.dart';
import 'package:background_eraser/core/shared/widgets/cubit/snackbar_cubit.dart';

class CustomSnackbar extends StatelessWidget {
  const CustomSnackbar({super.key});

  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final cubit = context.read<SnackbarCubit>();
    cubit.show(message);

    Future.delayed(duration, () {
      if (context.mounted) {
        cubit.hide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SnackbarCubit, SnackbarState>(
      builder: (context, state) {
        if (!state.isVisible || state.message == null) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 100,
          left: 24,
          right: 24,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0.0,
              end: state.isVisible ? 1.0 : 0.0,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              final clampedValue = value.clamp(0.0, 1.0);
              return Transform.scale(
                scale: clampedValue,
                child: Opacity(
                  opacity: clampedValue,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.editPhotoBtnColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.aquaColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.message!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.read<SnackbarCubit>().hide(),
                          child: Icon(
                            Icons.close,
                            color: AppColors.white210Color,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

