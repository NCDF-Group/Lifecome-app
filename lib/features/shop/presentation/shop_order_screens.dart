import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/router/safe_back.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/error_state.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/skeleton_loader.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/lists/row_card.dart';
import '../../../core/widgets/media/lc_icons.dart';
import '../application/shop_controller.dart';
import '../domain/shop_models.dart';
import 'shop_widgets.dart';

String _titleCase(String value) => value
    .split(RegExp(r'[_\s]+'))
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');

BadgeTone _shopStatusTone(String status) => switch (status) {
  'dispatched' || 'delivered' => BadgeTone.green,
  'cancelled' => BadgeTone.gray,
  _ => BadgeTone.blue,
};

/// "Your orders" (screen pack 112).
class ShopOrdersScreen extends ConsumerWidget {
  const ShopOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final shop = ref.watch(shopProvider);
    final orders = shop.orders;
    return ShopPage(
      children: [
        const ScreenTitle(
          title: 'Your orders',
          subtitle: 'Keep track of your wellbeing essentials.',
        ),
        const SizedBox(height: 14),
        if (shop.loading)
          const SkeletonLoader()
        else if (shop.error != null)
          ErrorState(
            error: shop.error!,
            onRetry: () => ref.read(shopProvider.notifier).refresh(),
          )
        else if (orders.isEmpty)
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
    final returned = order.returns;
    return ShopPage(
      backFallback: RoutePaths.shopOrders,
      children: [
        ScreenTitle(
          title: 'Order ${order.reference}',
          subtitle: 'Placed ${Formatters.longDate(order.placedAt)}',
        ),
        const SizedBox(height: 12),
        StatusBadge(
          _titleCase(order.status),
          tone: _shopStatusTone(order.status),
        ),
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
            ('Payment', _titleCase(order.paymentStatus)),
            ('Delivery', order.trackingCarrier ?? 'Standard delivery'),
            ('Address', order.delivery.oneLine),
            if (order.trackingNumber?.isNotEmpty == true)
              ('Tracking number', order.trackingNumber!),
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
        if (order.status == 'dispatched' || order.status == 'delivered') ...[
          PrimaryButton(
            label: 'Track delivery',
            onPressed: () =>
                context.push(RoutePaths.shopTracking, extra: order),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Request a return',
            onPressed: () => context.push(RoutePaths.shopReturn, extra: order),
          ),
        ],
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
        DetailList(
          rows: [
            ('Status', _titleCase(order.status)),
            if (order.trackingCarrier?.isNotEmpty == true)
              ('Carrier', order.trackingCarrier!),
            if (order.trackingNumber?.isNotEmpty == true)
              ('Tracking number', order.trackingNumber!),
          ],
        ),
        PanelCard(title: 'Delivery address', body: order.delivery.oneLine),
        if (order.trackingNumber?.isEmpty != false)
          const InfoBanner(
            message:
                'Tracking details will appear when the order is dispatched.',
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
  late ShopOrderLine _line = widget.order.lines.first;
  String _reason = ShopReturnRequest.reasons.first;
  final _detail = TextEditingController();
  bool _understood = false;
  bool _showError = false;
  bool _submitting = false;

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_understood) {
      setState(() => _showError = true);
      return;
    }
    setState(() => _submitting = true);
    try {
      final request = await ref
          .read(shopProvider.notifier)
          .requestReturn(
            order: widget.order,
            line: _line,
            reason: _reason,
            details: _detail.text.trim(),
          );
      if (mounted) {
        context.pushReplacement(RoutePaths.shopReturnSent, extra: request);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
        for (final line in widget.order.lines)
          ChoiceCard(
            title: '${line.product.name} × ${line.quantity}',
            selected: line.id == _line.id,
            onTap: () => setState(() => _line = line),
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
          label: _submitting ? 'Sending…' : 'Send return request',
          onPressed: _submitting ? null : _submit,
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
