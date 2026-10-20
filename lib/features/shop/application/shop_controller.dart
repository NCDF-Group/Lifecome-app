import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../domain/shop_models.dart';

/// The basket, checkout details and orders.
///
/// The Wellbeing Shop has no backend yet, so this is preview data kept in
/// memory for the session (signing out clears it): no payment is taken and
/// nothing is shipped.
class ShopState {
  const ShopState({
    this.basket = const {},
    this.delivery,
    this.orders = const [],
    this.returns = const [],
  });

  /// Product id to quantity.
  final Map<String, int> basket;
  final ShopDelivery? delivery;

  /// Newest first.
  final List<ShopOrder> orders;
  final List<ShopReturnRequest> returns;

  List<ShopOrderLine> get lines => [
    for (final entry in basket.entries)
      ShopOrderLine(
        product: ShopProduct.byId(entry.key),
        quantity: entry.value,
      ),
  ];

  int get itemCount => basket.values.fold(0, (a, b) => a + b);
  int get subtotalPence => lines.fold(0, (sum, l) => sum + l.totalPence);
  int get deliveryPence => ShopPricing.deliveryFor(subtotalPence);
  int get totalPence => subtotalPence + deliveryPence;

  ShopState copyWith({
    Map<String, int>? basket,
    ShopDelivery? delivery,
    List<ShopOrder>? orders,
    List<ShopReturnRequest>? returns,
  }) => ShopState(
    basket: basket ?? this.basket,
    delivery: delivery ?? this.delivery,
    orders: orders ?? this.orders,
    returns: returns ?? this.returns,
  );
}

class ShopController extends Notifier<ShopState> {
  final _random = Random();

  @override
  ShopState build() {
    ref.watch(sessionEpochProvider);
    return const ShopState();
  }

  void add(ShopProduct product) =>
      setQuantity(product.id, (state.basket[product.id] ?? 0) + 1);

  /// Sets a basket quantity, removing the line at zero.
  void setQuantity(String productId, int quantity) {
    final basket = {...state.basket};
    if (quantity <= 0) {
      basket.remove(productId);
    } else {
      basket[productId] = quantity.clamp(1, 20);
    }
    state = state.copyWith(basket: basket);
  }

  void setDelivery(ShopDelivery delivery) =>
      state = state.copyWith(delivery: delivery);

  /// Turns the basket into an order and empties it.
  ShopOrder placeOrder() {
    final order = ShopOrder(
      reference: 'LC-SHOP-${1000 + _random.nextInt(9000)}',
      placedAt: DateTime.now(),
      lines: state.lines,
      delivery: state.delivery!,
    );
    state = state.copyWith(basket: const {}, orders: [order, ...state.orders]);
    return order;
  }

  ShopReturnRequest requestReturn({
    required ShopOrder order,
    required String item,
    required String reason,
    String? detail,
  }) {
    final request = ShopReturnRequest(
      reference: 'LC-RET-${1000 + _random.nextInt(9000)}',
      orderReference: order.reference,
      item: item,
      reason: reason,
      detail: detail,
    );
    state = state.copyWith(returns: [...state.returns, request]);
    return request;
  }
}

final shopProvider = NotifierProvider<ShopController, ShopState>(
  ShopController.new,
);
