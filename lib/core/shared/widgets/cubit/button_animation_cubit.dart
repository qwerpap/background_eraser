import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class ButtonAnimationState extends Equatable {
  final bool isPressed;
  final double scale;

  const ButtonAnimationState({this.isPressed = false, this.scale = 1.0});

  ButtonAnimationState copyWith({bool? isPressed, double? scale}) {
    return ButtonAnimationState(
      isPressed: isPressed ?? this.isPressed,
      scale: scale ?? this.scale,
    );
  }

  @override
  List<Object> get props => [isPressed, scale];
}

class ButtonAnimationCubit extends Cubit<ButtonAnimationState> {
  ButtonAnimationCubit() : super(const ButtonAnimationState());

  static const double _pressedScale = 0.95;
  static const double _normalScale = 1.0;

  void press() {
    emit(state.copyWith(isPressed: true, scale: _pressedScale));
  }

  void release() {
    emit(state.copyWith(isPressed: false, scale: _normalScale));
  }
}
