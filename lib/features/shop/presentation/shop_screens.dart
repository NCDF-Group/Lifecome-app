import 'package:flutter/material.dart';
import 'package:lifecome_mobile/core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/app_popup.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/skeleton_loader.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../application/shop_controller.dart';
import '../domain/shop_models.dart';
import 'shop_widgets.dart';

/// "Your wellbeing, every day" — the Wellbeing Shop (screen pack 105).
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  ShopCategory _category = ShopCategory.all;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final shop = ref.watch(shopProvider);
    final count = shop.itemCount;
    final products = [
      for (final p in shop.products)
        if (_category == ShopCategory.all || p.category == _category) p,
    ];

    return ShopPage(
      backFallback: RoutePaths.wellbeing,
      children: [
        const ScreenTitle(
          eyebrow: 'Wellbeing shop',
          title: 'Your wellbeing, every day',
          subtitle: 'Products for your everyday routine.',
        ),
        const SizedBox(height: 14),
        if (shop.loading)
          const SkeletonLoader()
        else if (shop.error != null)
          ErrorState(
            error: shop.error!,
            onRetry: () => ref.read(shopProvider.notifier).refresh(),
          )
        else ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final category in ShopCategory.values) ...[
                  ChoiceChip(
                    label: Text(category.label),
                    selected: category == _category,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _category = category),
                    selectedColor: palette.accent,
                    backgroundColor: palette.elevated,
                    side: BorderSide(
                      color: category == _category
                          ? palette.accent
                          : palette.line,
                    ),
                    shape: const StadiumBorder(),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: category == _category
                          ? Colors.white
                          : palette.inkMuted,
                    ),
                  ),
                  const SizedBox(width: 7),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text(
                'No products are available in this category right now.',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.inkMuted),
              ),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 11,
              crossAxisSpacing: 11,
              childAspectRatio: 0.66,
              children: [for (final p in products) _ProductCard(product: p)],
            ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'View basket ($count)',
            onPressed: () => context.push(RoutePaths.shopBasket),
          ),
          const SizedBox(height: 4),
          RowCard(
            icon: LcIcons.truck,
            title: 'My orders',
            subtitle: 'Track deliveries and manage returns',
            onTap: () => context.push(RoutePaths.shopOrders),
          ),
          const SizedBox(height: 8),
          const InfoBanner(
            message:
                'Supplements are not a substitute for a balanced diet or '
                'clinical care.',
          ),
        ],
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ShopProduct product;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.elevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: BorderSide(color: palette.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RoutePaths.shopProduct, extra: product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProductArt(product: product),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: palette.inkMuted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.money(product.pricePence),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: palette.ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One product (screen pack 106).
class ShopProductScreen extends ConsumerWidget {
  const ShopProductScreen({super.key, required this.product});

  final ShopProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final shop = ref.watch(shopProvider);
    final count = shop.itemCount;
    return ShopPage(
      children: [
        ProductArt(product: product, height: 210, scale: 1.65, radius: 20),
        const SizedBox(height: 20),
        ScreenTitle(title: product.name, subtitle: product.subtitle),
        const SizedBox(height: 8),
        Text(
          Formatters.money(product.pricePence),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: palette.ink,
          ),
        ),
        PanelCard(title: 'About this product', body: product.description),
        if (product.stockQuantity == 0)
          const InfoBanner(message: 'This product is currently out of stock.'),
        if (product.ingredients?.isNotEmpty == true)
          PanelCard(title: 'Ingredients', body: product.ingredients),
        if (product.usageInstructions?.isNotEmpty == true)
          PanelCard(title: 'Directions', body: product.usageInstructions),
        if (product.warnings?.isNotEmpty == true)
          PanelCard(title: 'Warnings', body: product.warnings),
        if (product.isSupplement) ...[
          const InfoBanner(
            message:
                'Check suitability with a pharmacist or clinician, especially '
                'if you take medication or are pregnant.',
          ),
          const SizedBox(height: 6),
        ],
        const SizedBox(height: 10),
        PrimaryButton(
          label: 'Add to basket',
          onPressed: product.isAvailable && !shop.loading
              ? () async {
                  try {
                    await ref.read(shopProvider.notifier).add(product);
                    if (context.mounted) {
                      await showSuccessPopup(
                        context,
                        title: 'Added to basket',
                        message: '${product.name} is in your basket.',
                      );
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('$error')));
                    }
                  }
                }
              : null,
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'View basket ($count)',
          onPressed: () => context.push(RoutePaths.shopBasket),
        ),
        const SizedBox(height: 14),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              'Delivery & returns',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: palette.ink,
              ),
            ),
            expandedAlignment: Alignment.centerLeft,
            children: [
              Text(
                'Delivery costs and return eligibility are shown from the '
                'current order and shop terms at checkout.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.6,
                  color: palette.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "Your basket" (screen pack 107).
class ShopBasketScreen extends ConsumerWidget {
  const ShopBasketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final shop = ref.watch(shopProvider);
    final notifier = ref.read(shopProvider.notifier);

    return ShopPage(
      children: [
        ScreenTitle(
          title: 'Your basket',
          subtitle: shop.itemCount == 1 ? '1 item' : '${shop.itemCount} items',
        ),
        const SizedBox(height: 10),
        if (shop.loading)
          const SkeletonLoader()
        else if (shop.error != null)
          ErrorState(error: shop.error!, onRetry: () => notifier.refresh())
        else if (shop.itemCount == 0) ...[
          const SizedBox(height: 16),
          Center(child: LcIcon(LcIcons.bag, size: 44, color: palette.accent)),
          const SizedBox(height: 12),
          Text(
            'Your basket is empty',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: palette.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Explore products in the Wellbeing Shop.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: palette.inkMuted),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Browse the shop',
            onPressed: () => context.goBack(fallback: RoutePaths.shop),
          ),
        ] else ...[
          for (final line in shop.lines)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: palette.line)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 65,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ProductArt(
                        product: line.product,
                        height: 82,
                        scale: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.product.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: palette.ink,
                          ),
                        ),
                        Text(
                          '${Formatters.money(line.product.pricePence)} each',
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: palette.tintBlue,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Remove one ${line.product.name}',
                                visualDensity: VisualDensity.compact,
                                icon: Icon(
                                  AppIcons.remove,
                                  color: palette.accent,
                                ),
                                onPressed: () => notifier.setQuantity(
                                  line.product.id,
                                  line.quantity - 1,
                                ),
                              ),
                              Text(
                                '${line.quantity}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: palette.ink,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Add one ${line.product.name}',
                                visualDensity: VisualDensity.compact,
                                icon: Icon(AppIcons.add, color: palette.accent),
                                onPressed: () => notifier.setQuantity(
                                  line.product.id,
                                  line.quantity + 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.money(line.totalPence),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: palette.ink,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove ${line.product.name}',
                        icon: Icon(AppIcons.close, color: palette.inkMuted),
                        onPressed: () =>
                            notifier.setQuantity(line.product.id, 0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          ShopTotals(
            subtotalPence: shop.subtotalPence,
            deliveryPence: shop.deliveryPence,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Continue to delivery',
            onPressed: () => context.push(RoutePaths.shopDelivery),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Continue shopping',
            onPressed: () => context.goBack(fallback: RoutePaths.shop),
          ),
        ],
      ],
    );
  }
}
