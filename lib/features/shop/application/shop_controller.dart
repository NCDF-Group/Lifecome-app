import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/shop_repository.dart';
import '../domain/shop_models.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return DioShopRepository(ref.watch(apiClientProvider));
});

class ShopState {
  const ShopState({
    this.products = const [],
    this.basket = const ShopBasket(),
    this.delivery,
    this.orders = const [],
    this.checkout,
    this.loading = true,
    this.error,
  });

  final List<ShopProduct> products;
  final ShopBasket basket;
  final ShopDelivery? delivery;
  final List<ShopOrder> orders;
  final ShopCheckout? checkout;
  final bool loading;
  final Object? error;

  List<ShopBasketLine> get lines => basket.lines;
  int get itemCount => basket.itemCount;
  int get subtotalPence => basket.subtotalPence;
  int get deliveryPence => basket.deliveryPence;
  int get totalPence => basket.totalPence;

  ShopState copyWith({
    List<ShopProduct>? products,
    ShopBasket? basket,
    ShopDelivery? delivery,
    bool clearDelivery = false,
    List<ShopOrder>? orders,
    ShopCheckout? checkout,
    bool clearCheckout = false,
    bool? loading,
    Object? error,
    bool clearError = false,
  }) => ShopState(
    products: products ?? this.products,
    basket: basket ?? this.basket,
    delivery: clearDelivery ? null : delivery ?? this.delivery,
    orders: orders ?? this.orders,
    checkout: clearCheckout ? null : checkout ?? this.checkout,
    loading: loading ?? this.loading,
    error: clearError ? null : error ?? this.error,
  );
}

/// Shop catalogue, persistent basket, orders and returns from the backend.
class ShopController extends Notifier<ShopState> {
  @override
  ShopState build() {
    ref.watch(sessionEpochProvider);
    final repository = ref.watch(shopRepositoryProvider);
    Future.microtask(() => _load(repository));
    return const ShopState();
  }

  Future<void> _load(ShopRepository repository) async {
    try {
      final values = await Future.wait<Object>([
        repository.listProducts(),
        repository.getBasket(),
        repository.listOrders(),
      ]);
      state = ShopState(
        products: values[0] as List<ShopProduct>,
        basket: values[1] as ShopBasket,
        orders: values[2] as List<ShopOrder>,
        loading: false,
      );
    } catch (error) {
      state = state.copyWith(loading: false, error: error);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    await _load(ref.read(shopRepositoryProvider));
  }

  Future<void> add(ShopProduct product) async {
    try {
      final basket = await ref
          .read(shopRepositoryProvider)
          .addItem(product.id, 1);
      state = state.copyWith(basket: basket, clearError: true);
    } catch (error) {
      state = state.copyWith(error: error);
      rethrow;
    }
  }

  Future<void> setQuantity(String productId, int quantity) async {
    try {
      final basket = await ref
          .read(shopRepositoryProvider)
          .setQuantity(productId, quantity.clamp(0, 99));
      state = state.copyWith(basket: basket, clearError: true);
    } catch (error) {
      state = state.copyWith(error: error);
      rethrow;
    }
  }

  void setDelivery(ShopDelivery delivery) =>
      state = state.copyWith(delivery: delivery, clearCheckout: true);

  Future<ShopCheckout> checkout({
    required String email,
    required bool acceptTerms,
  }) async {
    final delivery = state.delivery;
    if (delivery == null) throw StateError('Add a delivery address first.');
    try {
      final result = await ref
          .read(shopRepositoryProvider)
          .checkout(delivery: delivery, email: email, acceptTerms: acceptTerms);
      state = state.copyWith(checkout: result, clearError: true);
      return result;
    } catch (error) {
      state = state.copyWith(error: error);
      rethrow;
    }
  }

  Future<ShopOrder> confirmPayment(String orderId) async {
    final order = await ref
        .read(shopRepositoryProvider)
        .confirmPayment(orderId);
    await refresh();
    return order;
  }

  Future<ShopReturnRequest> requestReturn({
    required ShopOrder order,
    required ShopOrderLine line,
    required String reason,
    required String details,
  }) async {
    final response = await ref
        .read(shopRepositoryProvider)
        .requestReturn(
          order: order,
          line: line,
          reason: reason,
          details: details,
        );
    final updated = await ref.read(shopRepositoryProvider).getOrder(order.id);
    state = state.copyWith(
      orders: [
        for (final item in state.orders) item.id == updated.id ? updated : item,
      ],
    );
    return ShopReturnRequest(
      id: response.id,
      reference: response.reference,
      orderReference: order.reference,
      item: line.product.name,
      reason: reason,
      detail: details.trim().isEmpty ? null : details.trim(),
    );
  }
}

final shopProvider = NotifierProvider<ShopController, ShopState>(
  ShopController.new,
);
