import 'package:background_eraser/core/shared/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';

class UploadPhoto extends StatelessWidget {
  const UploadPhoto({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      height: 100,
      borderRadius: 24,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_photo_alternate, size: 40),
          const SizedBox(width: 12),
          Text(
            'Upload new photo',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
