import 'package:flutter/material.dart';
import 'package:background_eraser/core/shared/widgets/custom_app_bar.dart';
import 'package:background_eraser/features/home/widgets/upload_photo.dart';
import 'package:background_eraser/features/home/widgets/title_text.dart';

class HomeHeaderSection extends StatelessWidget {
  const HomeHeaderSection({super.key, required this.onUploadPhoto});

  final VoidCallback onUploadPhoto;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CustomAppBar(title: 'Background Eraser'),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: UploadPhoto(onPressed: onUploadPhoto),
            ),
            const TitleText(text: 'Last Edited'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
