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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object> get props => [id, imagePath, createdAt];
}
