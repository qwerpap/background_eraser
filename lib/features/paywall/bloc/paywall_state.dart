import 'package:equatable/equatable.dart';
import '../../../core/subscription/subscription_product.dart';

abstract class PaywallState extends Equatable {
  const PaywallState();

  @override
  List<Object?> get props => [];
}

class PaywallInitial extends PaywallState {
  const PaywallInitial();
}

class PaywallLoading extends PaywallState {
  const PaywallLoading();
}

class PaywallLoaded extends PaywallState {
  const PaywallLoaded(this.products);

  final List<SubscriptionProduct> products;

  @override
  List<Object?> get props => [products];
}

class PaywallPurchasing extends PaywallState {
  const PaywallPurchasing(this.product);

  final SubscriptionProduct product;

  @override
  List<Object?> get props => [product];
}

class PaywallPurchaseSuccess extends PaywallState {
  const PaywallPurchaseSuccess();
}

class PaywallRestoring extends PaywallState {
  const PaywallRestoring();
}

class PaywallRestoreSuccess extends PaywallState {
  const PaywallRestoreSuccess();
}

class PaywallError extends PaywallState {
  const PaywallError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
