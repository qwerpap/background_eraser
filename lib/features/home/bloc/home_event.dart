import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'dart:io';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadPhotos extends HomeEvent {
  const HomeLoadPhotos();
}

class HomeImageSourceSelected extends HomeEvent {
  const HomeImageSourceSelected(this.source);

  final picker.ImageSource source;

  @override
  List<Object?> get props => [source];
}

class HomeSavePhoto extends HomeEvent {
  const HomeSavePhoto(this.imageFile);

  final File imageFile;

  @override
  List<Object?> get props => [imageFile];
}


