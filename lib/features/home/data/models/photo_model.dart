import 'package:equatable/equatable.dart';

class PhotoModel extends Equatable {
  final String id;
  final String imagePath;
  final DateTime createdAt;

  const PhotoModel({
    required this.id,
    required this.imagePath,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, imagePath, createdAt];
}
