import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:background_eraser/core/theme/app_colors.dart';
import 'package:background_eraser/core/shared/widgets/cubit/button_animation_cubit.dart';
import 'package:background_eraser/core/navigation/data/constants/navigation_constants.dart';

class EraserAppBar extends StatelessWidget {
  const EraserAppBar({super.key, this.onReset});

  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(NavigationConstants.home);
                  }
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.whiteColor,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Eraser',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            BlocProvider(
              create: (_) => ButtonAnimationCubit(),
              child: BlocBuilder<ButtonAnimationCubit, ButtonAnimationState>(
                builder: (context, animationState) {
                  final cubit = context.read<ButtonAnimationCubit>();

                  return GestureDetector(
                    onTapDown: (_) => cubit.press(),
                    onTapUp: (_) {
                      cubit.release();
                      onReset?.call();
                    },
                    onTapCancel: () => cubit.release(),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 1.0,
                        end: animationState.scale,
                      ),
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.aquaColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onReset,
                                borderRadius: BorderRadius.circular(8),
                                splashColor: AppColors.aquaColor.withOpacity(0.2),
                                highlightColor: AppColors.aquaColor.withOpacity(0.1),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    'Reset',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                      color: AppColors.aquaColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
