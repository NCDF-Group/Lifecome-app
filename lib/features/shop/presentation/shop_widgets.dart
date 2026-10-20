import 'package:flutter/material.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/layout/app_header_bar.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../domain/shop_models.dart';

/// Says plainly that the shop is a preview.
class ShopPreviewNotice extends StatelessWidget {
  const ShopPreviewNotice({super.key});

  @override
  Widget build(BuildContext context) => const InfoBanner(
    tone: BannerTone.warning,
    message:
        'The Wellbeing Shop is in preview. Orders stay in this app: no '
        'payment is taken and nothing is shipped. Products and prices are '
        'examples.',
  );
}

/// The scaffold every Shop screen shares.
class ShopPage extends StatelessWidget {
  const ShopPage({
    super.key,
    required this.children,
    this.backFallback = RoutePaths.shop,
  });

  final List<Widget> children;
  final String backFallback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          children: [
            AppHeaderBar(showBack: true, backFallback: backFallback),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A product's artwork (the screen pack's `.product-art` and `.bottle`): a
/// soft tinted panel with a labelled container drawn on it.
class ProductArt extends StatelessWidget {
  const ProductArt({
    super.key,
    required this.product,
    this.height = 130,
    this.scale = 1,
    this.radius = 0,
  });

  final ShopProduct product;
  final double height;
  final double scale;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tint = product.blue ? palette.tintBlue : palette.tintGreen;
    final tint2 = product.blue
        ? palette.tintBlueStrong
        : palette.tintGreenStrong;
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, tint2],
        ),
      ),
      alignment: Alignment.center,
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          width: 57,
          height: 90,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 11,
                child: Container(
                  width: 53,
                  height: 78,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9D6333),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(7),
                      bottom: Radius.circular(11),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF734221).withValues(alpha: 0.1),
                        blurRadius: 13,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 57,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xFFE5E9EE)),
                ),
              ),
              Positioned(
                top: 36,
                left: 2,
                right: 2,
                child: Container(
                  color: const Color(0xFFFFFCF5),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    product.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111534),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Items, delivery and total rows.
class ShopTotals extends StatelessWidget {
  const ShopTotals({
    super.key,
    required this.subtotalPence,
    required this.deliveryPence,
  });

  final int subtotalPence;
  final int deliveryPence;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        DetailList(
          rows: [
            ('Items', Formatters.money(subtotalPence)),
            (
              'Delivery',
              deliveryPence == 0 ? 'Free' : Formatters.money(deliveryPence),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.only(top: 14),
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: palette.line)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: palette.ink,
                  ),
                ),
              ),
              Text(
                Formatters.money(subtotalPence + deliveryPence),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: palette.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
