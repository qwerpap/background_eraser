import 'package:background_eraser/core/core.dart';
import 'package:background_eraser/core/shared/widgets/custom_snackbar.dart';
import 'package:background_eraser/features/home/data/models/photo_model.dart';
import 'package:background_eraser/features/home/presentation/widgets/image_source_bottom_sheet.dart';
import 'package:background_eraser/features/home/presentation/widgets/home_header_section.dart';
import 'package:background_eraser/features/home/presentation/widgets/home_empty_state.dart';
import 'package:background_eraser/features/home/presentation/widgets/home_loading_state.dart';
import 'package:background_eraser/features/home/presentation/widgets/home_photos_grid.dart';
import 'package:background_eraser/features/home/presentation/view/home_listener.dart';
import 'package:background_eraser/features/home/bloc/home_bloc.dart';
import 'package:background_eraser/features/home/bloc/home_event.dart';
import 'package:background_eraser/features/home/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(const HomeLoadPhotos());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<HomeBloc>().state;
    if (state is! HomeLoaded &&
        state is! HomeLoading &&
        state is! HomeImagePicked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<HomeBloc>().add(const HomeLoadPhotos());
        }
      });
    }
  }

  void _handleUploadPhoto(BuildContext context) {
    _showImageSourceBottomSheet(context);
  }

  void _showImageSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      enableDrag: true,
      builder: (bottomSheetContext) => ImageSourceBottomSheet(
        onSourceSelected: (source) {
          Navigator.of(bottomSheetContext).pop();
          context.read<HomeBloc>().add(HomeImageSourceSelected(source));
        },
        onClose: () {
          Navigator.of(bottomSheetContext).pop();
        },
      ),
    );
  }

  List<PhotoModel> _getPhotosFromState(HomeState state) {
    if (state is HomeLoaded) {
      return state.photos;
    } else if (state is HomePhotoSaved) {
      return state.photos;
    }
    return [];
  }

  bool _isLoadingState(HomeState state) {
    return state is HomeLoading;
  }

  @override
  Widget build(BuildContext context) {
    return HomeListener(
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final photos = _getPhotosFromState(state);
          final isLoading = _isLoadingState(state);
          final hasPhotos = photos.isNotEmpty;

          return Stack(
            children: [
              CustomScaffold(
                body: SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      HomeHeaderSection(
                        onUploadPhoto: () => _handleUploadPhoto(context),
                      ),
                      if (isLoading && !hasPhotos)
                        const HomeLoadingState()
                      else if (!hasPhotos)
                        const HomeEmptyState()
                      else
                        HomePhotosGrid(photos: photos),
                      const SliverPadding(
                        padding: EdgeInsets.only(bottom: 150),
                      ),
                    ],
                  ),
                ),
              ),
              const CustomSnackbar(),
            ],
          );
        },
      ),
    );
  }
}
