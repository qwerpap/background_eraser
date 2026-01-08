import 'package:background_eraser/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:background_eraser/core/shared/widgets/cubit/button_animation_cubit.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height = 52,
    this.width,
    this.padding,
    this.borderRadius = 12,
    this.transparent = false,
  }) : assert(
         text != null || child != null,
         'Either text or child must be provided',
       ),
       assert(
         onPressed != null || text != null || child != null,
         'onPressed can be null for disabled buttons',
       );

  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final double height;
  final double? width;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final bool transparent;

  @override
  Widget build(BuildContext context) {
    final bool useGradient = backgroundColor == null && !transparent;
    final bool isTransparent =
        backgroundColor == Colors.transparent || transparent;

    return BlocProvider(
      create: (_) => ButtonAnimationCubit(),
      child: BlocBuilder<ButtonAnimationCubit, ButtonAnimationState>(
        builder: (context, animationState) {
          final cubit = context.read<ButtonAnimationCubit>();

          final bool isEnabled = onPressed != null;

          return GestureDetector(
            onTapDown: isEnabled ? (_) => cubit.press() : null,
            onTapUp: isEnabled
                ? (_) {
                    cubit.release();
                    onPressed?.call();
                  }
                : null,
            onTapCancel: isEnabled ? () => cubit.release() : null,
            child: AnimatedScale(
              scale: animationState.scale,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              child: Container(
                height: height,
                width: width,
                padding: padding,
                decoration: BoxDecoration(
                  gradient: isEnabled && useGradient ? AppColors.buttonColor : null,
                  color: useGradient
                      ? null
                      : (transparent ? Colors.transparent : backgroundColor),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: isTransparent
                      ? Border.all(color: AppColors.whiteColor, width: 2)
                      : null,
                  boxShadow: isEnabled && useGradient && !transparent
                      ? [
                          BoxShadow(
                            color: animationState.isPressed
                                ? AppColors.pinkColor.withOpacity(0.5)
                                : AppColors.pinkColor.withOpacity(0.3),
                            blurRadius: animationState.isPressed ? 12 : 8,
                            offset: Offset(0, animationState.isPressed ? 2 : 4),
                            spreadRadius: animationState.isPressed ? 2 : 0,
                          ),
                        ]
                      : null,
                ),
                  child: Opacity(
                    opacity: isEnabled ? 1.0 : 0.5,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onPressed,
                        borderRadius: BorderRadius.circular(borderRadius),
                        splashColor: AppColors.whiteColor.withOpacity(0.3),
                        highlightColor: AppColors.whiteColor.withOpacity(0.2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          alignment: Alignment.center,
                          child:
                              this.child ??
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  text!,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: textColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
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
  }
}
