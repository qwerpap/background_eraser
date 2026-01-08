import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class SnackbarState extends Equatable {
  const SnackbarState({
    this.message,
    this.isVisible = false,
  });

  final String? message;
  final bool isVisible;

  SnackbarState copyWith({
    String? message,
    bool? isVisible,
  }) {
    return SnackbarState(
      message: message ?? this.message,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  List<Object?> get props => [message, isVisible];
}

class SnackbarCubit extends Cubit<SnackbarState> {
  SnackbarCubit() : super(const SnackbarState());

  void show(String message) {
    emit(state.copyWith(message: message, isVisible: true));
  }

  void hide() {
    emit(state.copyWith(isVisible: false));
  }
}

