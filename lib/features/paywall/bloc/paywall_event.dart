import 'package:equatable/equatable.dart';
import '../../../core/subscription/subscription_product.dart';

abstract class PaywallEvent extends Equatable {
  const PaywallEvent();

  @override
  List<Object?> get props => [];
}

class PaywallLoadProducts extends PaywallEvent {
  const PaywallLoadProducts();
}

class PaywallPurchase extends PaywallEvent {
  const PaywallPurchase(this.product);

  final SubscriptionProduct product;

  @override
  List<Object?> get props => [product];
}

class PaywallRestore extends PaywallEvent {
  const PaywallRestore();
}

class PaywallClose extends PaywallEvent {
  const PaywallClose();
}
