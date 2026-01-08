import '../models/photo_model.dart';

class HomeMockData {
  HomeMockData._();

  static List<PhotoModel> getMockPhotos() {
    return [
      PhotoModel(
        id: '1',
        imagePath: 'assets/png/blank.png',
        createdAt: DateTime(2024, 1, 15, 10, 30),
      ),
      PhotoModel(
        id: '2',
        imagePath: 'assets/png/blank.png',
        createdAt: DateTime(2024, 1, 14, 15, 45),
      ),
      PhotoModel(
        id: '3',
        imagePath: 'assets/png/blank.png',
        createdAt: DateTime(2024, 1, 13, 9, 20),
      ),
      PhotoModel(
        id: '4',
        imagePath: 'assets/png/blank.png',
        createdAt: DateTime(2024, 1, 12, 14, 10),
      ),
      PhotoModel(
        id: '5',
        imagePath: 'assets/png/blank.png',
        createdAt: DateTime(2024, 1, 11, 11, 0),
      ),
      PhotoModel(
        id: '6',
        imagePath: 'assets/png/blank.png',
        createdAt: DateTime(2024, 1, 10, 16, 30),
      ),
    ];
  }
}

