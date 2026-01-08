import 'package:equatable/equatable.dart';
import 'dart:io';
import '../data/models/photo_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.photos);

  final List<PhotoModel> photos;

  @override
  List<Object?> get props => [photos];
}

class HomeImagePicked extends HomeState {
  const HomeImagePicked(this.imageFile);

  final File imageFile;

  @override
  List<Object?> get props => [imageFile];
}

class HomePhotoSaved extends HomeState {
  const HomePhotoSaved(this.photo, this.photos);

  final PhotoModel photo;
  final List<PhotoModel> photos;

  @override
  List<Object?> get props => [photo, photos];
}

class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
