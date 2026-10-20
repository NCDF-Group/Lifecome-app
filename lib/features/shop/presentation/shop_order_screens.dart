import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/lists/timeline_item.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../application/shop_controller.dart';
import '../domain/shop_models.dart';
import 'shop_widgets.dart';

/// "Your orders" (screen pack 112).
class ShopOrdersScreen extends ConsumerWidget {
  const ShopOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final orders = ref.watch(shopProvider).orders;
    return ShopPage(
      children: [
        const ScreenTitle(
          title: 'Your orders',
          subtitle: 'Keep track of your wellbeing essentials.',
        ),
        const SizedBox(height: 14),
        if (orders.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border.all(color: palette.line),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              children: [
                LcIcon(LcIcons.bag, size: 36, color: palette.accent),
                const SizedBox(height: 10),
                Text(
                  'You have no orders yet.',
                  style: TextStyle(fontSize: 14, color: palette.inkMuted),
                ),
              ],
            ),
          )
        else
          for (final order in orders)
            RowCard(
              icon: LcIcons.bag,
              title: 'Order ${order.reference}',
              subtitle:
                  '${Formatters.date(order.placedAt)} · ${order.itemCount} '
                  '${order.itemCount == 1 ? 'item' : 'items'} · '
                  '${Formatters.money(order.totalPence)}',
              onTap: () => context.push(RoutePaths.shopOrder, extra: order),
            ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Browse the shop',
          onPressed: () => context.goBack(fallback: RoutePaths.shop),
        ),
      ],
    );
  }
}

/// One order (screen pack 113).
class ShopOrderScreen extends ConsumerWidget {
  const ShopOrderScreen({super.key, required this.order});

  final ShopOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returned = ref
        .watch(shopProvider)
        .returns
        .where((r) => r.orderReference == order.reference)
        .toList();
    return ShopPage(
      backFallback: RoutePaths.shopOrders,
      children: [
        ScreenTitle(
          title: 'Order ${order.reference}',
          subtitle: 'Placed ${Formatters.longDate(order.placedAt)}',
        ),
        const SizedBox(height: 12),
        const StatusBadge('Confirmed', tone: BadgeTone.blue),
        DetailList(
          rows: [
            for (final line in order.lines)
              (
                '${line.product.name} × ${line.quantity}',
                Formatters.money(line.totalPence),
              ),
          ],
        ),
        PanelCard(
          child: ShopTotals(
            subtotalPence: order.subtotalPence,
            deliveryPence: order.deliveryPence,
          ),
        ),
        DetailList(
          rows: [
            ('Payment', 'Not charged · preview'),
            ('Delivery', 'Standard · 3 to 5 working days'),
            ('Address', order.delivery.oneLine),
          ],
        ),
        if (returned.isNotEmpty) ...[
          const SizedBox(height: 8),
          InfoBanner(
            message:
                'Return ${returned.last.reference} requested for '
                '${returned.last.item}. The shop team will review it.',
          ),
        ],
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Track delivery',
          onPressed: () => context.push(RoutePaths.shopTracking, extra: order),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Request a return',
          onPressed: () => context.push(RoutePaths.shopReturn, extra: order),
        ),
        const SizedBox(height: 6),
        RowCard(
          icon: LcIcons.message,
          title: 'Order support',
          subtitle: 'Ask a question about your order',
          onTap: () => context.push(RoutePaths.newMessage),
        ),
      ],
    );
  }
}

/// "On its way to you" (screen pack 114).
class ShopTrackingScreen extends StatelessWidget {
  const ShopTrackingScreen({super.key, required this.order});

  final ShopOrder order;

  @override
  Widget build(BuildContext context) {
    return ShopPage(
      backFallback: RoutePaths.shopOrders,
      children: [
        ScreenTitle(
          title: 'On its way to you',
          subtitle: 'Order ${order.reference}',
        ),
        const StepTimeline(
          items: [
            ('Order confirmed', 'Your order details are ready.'),
            ('Preparing your items', 'The team prepares your package.'),
            ('Dispatched', 'Tracking appears when available.'),
            ('Delivered', 'Your order reaches its destination.'),
          ],
        ),
        PanelCard(title: 'Delivery address', body: order.delivery.oneLine),
        const InfoBanner(
          tone: BannerTone.warning,
          message:
              'While the shop is in preview, orders are not shipped, so there '
              'is no parcel to track.',
        ),
        const SizedBox(height: 16),
        SecondaryButton(
          label: 'Get order support',
          onPressed: () => context.push(RoutePaths.newMessage),
        ),
      ],
    );
  }
}

/// "Request a return" (screen pack 115). Eligibility is not assumed.
class ShopReturnScreen extends ConsumerStatefulWidget {
  const ShopReturnScreen({super.key, required this.order});

  final ShopOrder order;

  @override
  ConsumerState<ShopReturnScreen> createState() => _ShopReturnScreenState();
}

class _ShopReturnScreenState extends ConsumerState<ShopReturnScreen> {
  late String _item = widget.order.lines.first.product.name;
  String _reason = ShopReturnRequest.reasons.first;
  final _detail = TextEditingController();
  bool _understood = false;
  bool _showError = false;

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShopPage(
      backFallback: RoutePaths.shopOrders,
      children: [
        const ScreenTitle(
          title: 'Request a return',
          subtitle: 'The shop team will review eligibility and next steps.',
        ),
        const SizedBox(height: 10),
        SelectField(
          label: 'Item',
          options: [for (final l in widget.order.lines) l.product.name],
          value: _item,
          onChanged: (v) => setState(() => _item = v),
        ),
        SelectField(
          label: 'Reason',
          options: ShopReturnRequest.reasons,
          value: _reason,
          onChanged: (v) => setState(() => _reason = v),
        ),
        TextAreaField(
          label: 'Additional information',
          controller: _detail,
          optional: true,
          maxLines: 3,
        ),
        CheckRow(
          value: _understood,
          onChanged: (v) => setState(() {
            _understood = v;
            if (v) _showError = false;
          }),
          label:
              'I understand that whether an item can be returned depends on '
              'the product and the shop’s terms.',
        ),
        if (_showError)
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              'Please confirm to continue.',
              style: TextStyle(fontSize: 12.5, color: context.palette.danger),
            ),
          ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Send return request',
          onPressed: () {
            if (!_understood) {
              setState(() => _showError = true);
              return;
            }
            final detail = _detail.text.trim();
            final request = ref
                .read(shopProvider.notifier)
                .requestReturn(
                  order: widget.order,
                  item: _item,
                  reason: _reason,
                  detail: detail.isEmpty ? null : detail,
                );
            context.pushReplacement(RoutePaths.shopReturnSent, extra: request);
          },
        ),
      ],
    );
  }
}

/// "Your return request is in" (screen pack 116): received, not refunded.
class ShopReturnSentScreen extends StatelessWidget {
  const ShopReturnSentScreen({super.key, required this.request});

  final ShopReturnRequest request;

  @override
  Widget build(BuildContext context) {
    return ShopPage(
      backFallback: RoutePaths.shopOrders,
      children: [
        const SuccessIcon(),
        ScreenTitle(
          title: 'Your return request is in',
          subtitle:
              'Reference ${request.reference}. The shop team will review it '
              'before sending return instructions or arranging any refund.',
        ),
        const SizedBox(height: 10),
        DetailList(
          rows: [
            ('Order', request.orderReference),
            ('Item', request.item),
            ('Reason', request.reason),
          ],
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Return to order',
          onPressed: () => context.goBack(fallback: RoutePaths.shopOrders),
        ),
      ],
    );
  }
}
