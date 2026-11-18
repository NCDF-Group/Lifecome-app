import '../../../core/network/api_client.dart';
import '../domain/shop_models.dart';

class ShopCheckout {
  const ShopCheckout({required this.orderId, required this.orderNumber, required this.checkoutUrl});

  factory ShopCheckout.fromJson(Map<String, dynamic> json) {
    final order = json['order'] as Map<String, dynamic>? ?? const {};
    return ShopCheckout(
      orderId: order['id'] as String? ?? '',
      orderNumber: order['orderNumber'] as String? ?? '',
      checkoutUrl: json['checkoutUrl'] as String? ?? '',
    );
  }

  final String orderId;
  final String orderNumber;
  final String checkoutUrl;
}

abstract interface class ShopRepository {
  Future<List<ShopProduct>> listProducts();
  Future<ShopBasket> getBasket();
  Future<ShopBasket> addItem(String productId, int quantity);
  Future<ShopBasket> setQuantity(String productId, int quantity);
  Future<List<ShopOrder>> listOrders();
  Future<ShopOrder> getOrder(String id);
  Future<ShopCheckout> checkout({
    required ShopDelivery delivery,
    required String email,
    required bool acceptTerms,
  });
  Future<ShopOrder> confirmPayment(String orderId);
  Future<ShopReturnRequest> requestReturn({
    required ShopOrder order,
    required ShopOrderLine line,
    required String reason,
    required String details,
  });
}

class DioShopRepository implements ShopRepository {
  DioShopRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<ShopProduct>> listProducts() async => [
    for (final row in await _client.getList('/shop/products'))
      if (row is Map<String, dynamic>) ShopProduct.fromJson(row),
  ];

  @override
  Future<ShopBasket> getBasket() async =>
      ShopBasket.fromJson(await _client.get('/shop/basket'));

  @override
  Future<ShopBasket> addItem(String productId, int quantity) async =>
      ShopBasket.fromJson(await _client.post(
        '/shop/basket/items',
        data: {'productId': productId, 'quantity': quantity},
      ));

  @override
  Future<ShopBasket> setQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await _client.delete('/shop/basket/items/$productId');
      return getBasket();
    }
    return ShopBasket.fromJson(await _client.patch(
      '/shop/basket/items/$productId',
      data: {'quantity': quantity},
    ));
  }

  @override
  Future<List<ShopOrder>> listOrders() async => [
    for (final row in await _client.getList('/shop/orders'))
      if (row is Map<String, dynamic>) ShopOrder.fromJson(row),
  ];

  @override
  Future<ShopOrder> getOrder(String id) async =>
      ShopOrder.fromJson(await _client.get('/shop/orders/$id'));

  @override
  Future<ShopCheckout> checkout({
    required ShopDelivery delivery,
    required String email,
    required bool acceptTerms,
  }) async => ShopCheckout.fromJson(await _client.post(
    '/shop/orders',
    data: {
      'shippingAddress': delivery.toApiJson(),
      'contactEmail': email,
      'acceptTerms': acceptTerms,
    },
  ));

  @override
  Future<ShopOrder> confirmPayment(String orderId) async =>
      ShopOrder.fromJson(await _client.post('/shop/orders/$orderId/confirm-payment'));

  @override
  Future<ShopReturnRequest> requestReturn({
    required ShopOrder order,
    required ShopOrderLine line,
    required String reason,
    required String details,
  }) async => ShopReturnRequest.fromJson(await _client.post(
    '/shop/orders/${order.id}/returns',
    data: {
      'items': [
        {'orderItemId': line.id, 'quantity': line.quantity},
      ],
      'reason': ShopReturnRequest.reasonToApi(reason),
      if (details.trim().isNotEmpty) 'details': details.trim(),
      'acceptTerms': true,
    },
  ));
}
