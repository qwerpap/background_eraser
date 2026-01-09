/// Доменная модель продукта подписки.
///
/// Инкапсулирует информацию о продукте без зависимости от SDK.
class SubscriptionProduct {
  /// Идентификатор продукта (например, sonicforge_weekly).
  final String id;

  /// Название продукта.
  final String title;

  /// Цена продукта (форматированная строка).
  final String price;

  /// Код валюты (например, USD, EUR).
  final String currencyCode;

  const SubscriptionProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.currencyCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionProduct &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          price == other.price &&
          currencyCode == other.currencyCode;

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ price.hashCode ^ currencyCode.hashCode;

  @override
  String toString() {
    return 'SubscriptionProduct(id: $id, title: $title, price: $price, currencyCode: $currencyCode)';
  }
}
