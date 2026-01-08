sealed class Either<L, R> {
  const Either();

  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight);
  bool get isLeft;
  bool get isRight;
  L? get left;
  R? get right;
}

class Left<L, R> extends Either<L, R> {
  const Left(this._value);
  final L _value;

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onLeft(_value);
  }

  @override
  bool get isLeft => true;

  @override
  bool get isRight => false;

  @override
  L? get left => _value;

  @override
  R? get right => null;
}

class Right<L, R> extends Either<L, R> {
  const Right(this._value);
  final R _value;

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onRight(_value);
  }

  @override
  bool get isLeft => false;

  @override
  bool get isRight => true;

  @override
  L? get left => null;

  @override
  R? get right => _value;
}
