import 'package:background_eraser/core/core.dart';
import 'package:background_eraser/core/shared/widgets/custom_app_bar.dart';
import 'package:background_eraser/features/home/widgets/upload_photo.dart';
import 'package:background_eraser/features/home/widgets/title_text.dart';
import 'package:background_eraser/features/home/widgets/photo_card.dart';
import 'package:background_eraser/features/home/data/models/photo_model.dart';
import 'package:background_eraser/features/home/data/mock/home_mock_data.dart';
import 'package:flutter/material.dart';

void _handleUploadPhoto(BuildContext context) {
  // TODO: Add upload logic and navigate to eraser screen with image
  // Example: context.push(NavigationConstants.eraser, extra: imageFile);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<PhotoModel> photos = HomeMockData.getMockPhotos();
    final bool hasPhotos = photos.isNotEmpty;

    return CustomScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CustomAppBar(title: 'Background Eraser'),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: UploadPhoto(
                onPressed: () => _handleUploadPhoto(context),
              ),
            ),
            const TitleText(text: 'Last Edited'),
            const SizedBox(height: 24),
            if (!hasPhotos)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 64,
                        color: AppColors.white210Color,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No edited photos yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white210Color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your edited photos will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.white210Color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                itemCount: photos.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 150),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                ),
                itemBuilder: (context, index) {
                  return PhotoCard(photo: photos[index]);
                },
              ),
          ],
        ),
      ),
    );
  }
}
