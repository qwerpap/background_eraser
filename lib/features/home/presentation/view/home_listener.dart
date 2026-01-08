import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:background_eraser/core/shared/widgets/custom_popup.dart';
import 'package:background_eraser/core/shared/widgets/custom_snackbar.dart';
import 'package:background_eraser/core/navigation/data/constants/navigation_constants.dart';
import 'package:background_eraser/features/home/bloc/home_bloc.dart';
import 'package:background_eraser/features/home/bloc/home_event.dart';
import 'package:background_eraser/features/home/bloc/home_state.dart';

class HomeListener extends StatelessWidget {
  const HomeListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeImagePicked) {
          context.push(NavigationConstants.eraser, extra: state.imageFile);
        } else if (state is HomePhotoSaved) {
          CustomSnackbar.show(
            context: context,
            message: 'Photo saved successfully!',
          );
        } else if (state is HomeError) {
          _handleError(context, state);
        }
      },
      child: child,
    );
  }

  void _handleError(BuildContext context, HomeError state) {
    CustomPopup.show(
      context: context,
      title: 'Error',
      message: state.message,
      confirmText: 'OK',
      cancelText: ' ',
      onConfirm: () {
        if (context.read<HomeBloc>().state is! HomeLoaded) {
          context.read<HomeBloc>().add(const HomeLoadPhotos());
        }
      },
      onCancel: null,
    );
  }
}
