import 'package:flutter/material.dart';
import '../data/models/photo_model.dart';

class PhotoCard extends StatelessWidget {
  const PhotoCard({
    super.key,
    required this.photo,
  });

  final PhotoModel photo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Add navigation logic
      },
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            photo.imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
