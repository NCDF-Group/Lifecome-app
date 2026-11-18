/// Product categories exposed by `/shop/categories`.
enum ShopCategory {
  all('All products', ''),
  supplements('Supplements', 'supplements'),
  essentials('Everyday essentials', 'everyday_wellbeing');

  const ShopCategory(this.label, this.apiId);
  final String label;
  final String apiId;

  static ShopCategory fromApi(Object? value) => switch (value) {
    'supplements' => ShopCategory.supplements,
    'everyday_wellbeing' => ShopCategory.essentials,
    _ => ShopCategory.essentials,
  };
}

/// A shop product returned by the admin-managed API catalogue.
class ShopProduct {
  const ShopProduct({
    required this.id,
    required this.sku,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.pricePence,
    required this.label,
    required this.category,
    required this.stockQuantity,
    this.imageUrl,
    this.ingredients,
    this.usageInstructions,
    this.warnings,
    this.blue = false,
  });

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String? ?? '').trim();
    final sku = (json['sku'] as String? ?? '').trim();
    final category = ShopCategory.fromApi(json['category']);
    return ShopProduct(
      id: json['productId'] as String? ?? json['id'] as String? ?? '',
      sku: sku,
      name: name,
      subtitle: [json['packSize'], json['productType']]
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .join(' · '),
      description: (json['description'] as String? ?? '').trim(),
      pricePence: (json['pricePence'] as num?)?.toInt() ?? 0,
      label: (sku.isEmpty ? name : sku).toUpperCase(),
      category: category,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String?,
      ingredients: json['ingredients'] as String?,
      usageInstructions: json['usageInstructions'] as String?,
      warnings: json['warnings'] as String?,
      blue: category == ShopCategory.essentials,
    );
  }

  final String id;
  final String sku;
  final String name;
  final String subtitle;
  final String description;
  final int pricePence;
  final String label;
  final ShopCategory category;
  final int stockQuantity;
  final String? imageUrl;
  final String? ingredients;
  final String? usageInstructions;
  final String? warnings;
  final bool blue;

  bool get isSupplement => category == ShopCategory.supplements;
  bool get isAvailable => stockQuantity > 0;
}

class ShopDelivery {
  const ShopDelivery({
    required this.recipient,
    required this.line,
    required this.city,
    required this.postcode,
    this.instructions,
  });

  final String recipient;
  final String line;
  final String city;
  final String postcode;
  final String? instructions;

  String get oneLine => '$line, $city $postcode';

  Map<String, dynamic> toApiJson() => {
    'recipientName': recipient,
    'addressLine1': line,
    'city': city,
    'postcode': postcode,
    'country': 'GB',
    if (instructions?.trim().isNotEmpty == true)
      'deliveryInstructions': instructions!.trim(),
  };

  factory ShopDelivery.fromJson(Map<String, dynamic> json) => ShopDelivery(
    recipient: json['recipientName'] as String? ?? '',
    line: json['addressLine1'] as String? ?? '',
    city: json['city'] as String? ?? '',
    postcode: json['postcode'] as String? ?? '',
    instructions: json['deliveryInstructions'] as String?,
  );
}

class ShopOrderLine {
  const ShopOrderLine({
    required this.id,
    required this.product,
    required this.quantity,
  });

  factory ShopOrderLine.fromJson(Map<String, dynamic> json) => ShopOrderLine(
    id: json['id'] as String? ?? json['orderItemId'] as String? ?? '',
    product: ShopProduct.fromJson({
      'id': json['productId'],
      'name': json['productName'] ?? json['name'],
      'sku': '',
      'category': 'everyday_wellbeing',
      'description': '',
      'pricePence': json['unitPricePence'],
      'stockQuantity': 0,
      'packSize': json['packSize'],
      'imageUrl': json['imageUrl'],
    }),
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  );

  final String id;
  final ShopProduct product;
  final int quantity;

  int get totalPence => product.pricePence * quantity;
}

class ShopOrder {
  const ShopOrder({
    required this.id,
    required this.reference,
    required this.placedAt,
    required this.lines,
    required this.delivery,
    required this.subtotalPence,
    required this.deliveryPence,
    required this.totalPence,
    required this.status,
    required this.paymentStatus,
    this.trackingCarrier,
    this.trackingNumber,
    this.receiptUrl,
    this.returns = const [],
  });

  factory ShopOrder.fromJson(Map<String, dynamic> json) {
    final address = json['shippingAddress'];
    return ShopOrder(
      id: json['id'] as String? ?? '',
      reference: json['orderNumber'] as String? ?? '',
      placedAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      lines: [
        for (final item in json['items'] as List<dynamic>? ?? const [])
          if (item is Map<String, dynamic>) ShopOrderLine.fromJson(item),
      ],
      delivery: address is Map<String, dynamic>
          ? ShopDelivery.fromJson(address)
          : const ShopDelivery(recipient: '', line: '', city: '', postcode: ''),
      subtotalPence: (json['subtotalPence'] as num?)?.toInt() ?? 0,
      deliveryPence: (json['deliveryPence'] as num?)?.toInt() ?? 0,
      totalPence: (json['totalPence'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? '',
      trackingCarrier: json['trackingCarrier'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      returns: [
        for (final item in json['returns'] as List<dynamic>? ?? const [])
          if (item is Map<String, dynamic>) ShopReturnRequest.fromJson(item),
      ],
    );
  }

  final String id;
  final String reference;
  final DateTime placedAt;
  final List<ShopOrderLine> lines;
  final ShopDelivery delivery;
  final int subtotalPence;
  final int deliveryPence;
  final int totalPence;
  final String status;
  final String paymentStatus;
  final String? trackingCarrier;
  final String? trackingNumber;
  final String? receiptUrl;
  final List<ShopReturnRequest> returns;

  int get itemCount => lines.fold(0, (sum, item) => sum + item.quantity);
}

class ShopReturnRequest {
  const ShopReturnRequest({
    required this.id,
    required this.reference,
    required this.orderReference,
    required this.item,
    required this.reason,
    this.detail,
  });

  factory ShopReturnRequest.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? const [];
    final item = items.isNotEmpty && items.first is Map<String, dynamic>
        ? items.first as Map<String, dynamic>
        : const <String, dynamic>{};
    return ShopReturnRequest(
      id: json['id'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      orderReference: json['orderNumber'] as String? ?? '',
      item: item['productName'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      detail: json['details'] as String?,
    );
  }

  final String id;
  final String reference;
  final String orderReference;
  final String item;
  final String reason;
  final String? detail;

  static const reasons = [
    'Changed my mind',
    'Item arrived damaged',
    'Incorrect item',
    'Not as described',
    'Other',
  ];

  static String reasonToApi(String value) => switch (value) {
    'Changed my mind' => 'changed_mind',
    'Item arrived damaged' => 'arrived_damaged',
    'Incorrect item' => 'wrong_item',
    'Not as described' => 'not_as_described',
    _ => 'other',
  };
}

class ShopBasketLine {
  const ShopBasketLine({required this.product, required this.quantity});

  factory ShopBasketLine.fromJson(Map<String, dynamic> json) => ShopBasketLine(
    product: ShopProduct.fromJson(json),
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  );

  final ShopProduct product;
  final int quantity;

  int get totalPence => product.pricePence * quantity;
}

class ShopBasket {
  const ShopBasket({
    this.lines = const [],
    this.itemCount = 0,
    this.subtotalPence = 0,
    this.deliveryPence = 0,
    this.totalPence = 0,
    this.freeDeliveryFromPence = 0,
  });

  factory ShopBasket.fromJson(Map<String, dynamic> json) => ShopBasket(
    lines: [
      for (final item in json['items'] as List<dynamic>? ?? const [])
        if (item is Map<String, dynamic>) ShopBasketLine.fromJson(item),
    ],
    itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
    subtotalPence: (json['subtotalPence'] as num?)?.toInt() ?? 0,
    deliveryPence: (json['deliveryPence'] as num?)?.toInt() ?? 0,
    totalPence: (json['totalPence'] as num?)?.toInt() ?? 0,
    freeDeliveryFromPence:
        (json['freeDeliveryFromPence'] as num?)?.toInt() ?? 0,
  );

  final List<ShopBasketLine> lines;
  final int itemCount;
  final int subtotalPence;
  final int deliveryPence;
  final int totalPence;
  final int freeDeliveryFromPence;
}
