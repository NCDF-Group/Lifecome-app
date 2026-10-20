/// A shop category filter (screen pack 105).
enum ShopCategory {
  all('All products'),
  supplements('Supplements'),
  essentials('Everyday essentials');

  const ShopCategory(this.label);
  final String label;
}

/// One product in the Wellbeing Shop (screen pack 105-106).
class ShopProduct {
  const ShopProduct({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.pricePence,
    required this.label,
    required this.category,
    this.blue = false,
  });

  final String id;
  final String name;

  /// Pack size or format, e.g. "30 tablets · food supplement".
  final String subtitle;
  final String description;
  final int pricePence;

  /// The short word printed on the product's artwork.
  final String label;
  final ShopCategory category;

  /// Artwork tint: blue, or green when false.
  final bool blue;

  bool get isSupplement => category == ShopCategory.supplements;

  static const all = [
    ShopProduct(
      id: 'd3',
      name: 'Vitamin D3',
      subtitle: '30 tablets · food supplement',
      description:
          'A simple daily supplement. Read the full product label and ask a '
          'pharmacist if you are unsure whether it is suitable for you.',
      pricePence: 800,
      label: 'D3',
      category: ShopCategory.supplements,
      blue: true,
    ),
    ShopProduct(
      id: 'magnesium',
      name: 'Magnesium',
      subtitle: '60 capsules · food supplement',
      description:
          'A magnesium food supplement. The product page will show the '
          'approved ingredients, directions, allergens and supplier.',
      pricePence: 1200,
      label: 'Mg',
      category: ShopCategory.supplements,
    ),
    ShopProduct(
      id: 'journal',
      name: 'Wellbeing journal',
      subtitle: 'A5 · 90 undated pages',
      description:
          'A space to reflect on routines, set personal goals and celebrate '
          'progress, with daily prompts and a weekly reflection page.',
      pricePence: 1600,
      label: 'JOURNAL',
      category: ShopCategory.essentials,
      blue: true,
    ),
    ShopProduct(
      id: 'bottle',
      name: 'Everyday water bottle',
      subtitle: '500 ml · reusable',
      description: 'A reusable bottle for your everyday routine.',
      pricePence: 1800,
      label: 'LIVE',
      category: ShopCategory.essentials,
    ),
  ];

  static ShopProduct byId(String id) => all.firstWhere((p) => p.id == id);
}

/// Where an order goes (screen pack 108).
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
}

/// Delivery pricing: £3.95, free from £30.
abstract final class ShopPricing {
  static const deliveryPence = 395;
  static const freeFromPence = 3000;

  static int deliveryFor(int subtotalPence) =>
      subtotalPence >= freeFromPence ? 0 : deliveryPence;
}

/// One line of an order.
class ShopOrderLine {
  const ShopOrderLine({required this.product, required this.quantity});

  final ShopProduct product;
  final int quantity;

  int get totalPence => product.pricePence * quantity;
}

/// A placed order (screen pack 111-114).
class ShopOrder {
  const ShopOrder({
    required this.reference,
    required this.placedAt,
    required this.lines,
    required this.delivery,
  });

  final String reference;
  final DateTime placedAt;
  final List<ShopOrderLine> lines;
  final ShopDelivery delivery;

  int get subtotalPence => lines.fold(0, (sum, l) => sum + l.totalPence);
  int get deliveryPence => ShopPricing.deliveryFor(subtotalPence);
  int get totalPence => subtotalPence + deliveryPence;
  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);
}

/// A return the person asked for (screen pack 115-116).
class ShopReturnRequest {
  const ShopReturnRequest({
    required this.reference,
    required this.orderReference,
    required this.item,
    required this.reason,
    this.detail,
  });

  final String reference;
  final String orderReference;
  final String item;
  final String reason;
  final String? detail;

  static const reasons = [
    'Changed my mind',
    'Item arrived damaged',
    'Incorrect item',
    'Other',
  ];
}
