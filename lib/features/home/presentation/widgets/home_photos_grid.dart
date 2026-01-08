import 'package:flutter/material.dart';
import 'package:background_eraser/features/home/data/models/photo_model.dart';
import 'package:background_eraser/features/home/presentation/widgets/photo_card.dart';

class HomePhotosGrid extends StatelessWidget {
  const HomePhotosGrid({super.key, required this.photos});

  final List<PhotoModel> photos;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          return PhotoCard(photo: photos[index]);
        }, childCount: photos.length),
      ),
    );
  }
}
