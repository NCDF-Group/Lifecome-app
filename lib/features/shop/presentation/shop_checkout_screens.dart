import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/info_banner.dart';
import '../../../core/widgets/feedback/status_chip.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/choice_card.dart';
import '../../../core/widgets/inputs/form_fields.dart';
import '../../../core/widgets/layout/detail_list.dart';
import '../../../core/widgets/layout/screen_title.dart';
import '../../../core/widgets/layout/step_progress.dart';
import '../../profile/application/profile_controller.dart';
import '../application/shop_controller.dart';
import '../domain/shop_models.dart';
import 'shop_widgets.dart';

/// "Where should we deliver?" — checkout step 1 (screen pack 108).
class ShopDeliveryScreen extends ConsumerStatefulWidget {
  const ShopDeliveryScreen({super.key});

  @override
  ConsumerState<ShopDeliveryScreen> createState() => _ShopDeliveryScreenState();
}

class _ShopDeliveryScreenState extends ConsumerState<ShopDeliveryScreen> {
  final _recipient = TextEditingController();
  final _line = TextEditingController();
  final _city = TextEditingController();
  final _postcode = TextEditingController();
  final _instructions = TextEditingController();
  final _errors = <String, String?>{};

  @override
  void initState() {
    super.initState();
    final saved = ref.read(shopProvider).delivery;
    if (saved != null) {
      _recipient.text = saved.recipient;
      _line.text = saved.line;
      _city.text = saved.city;
      _postcode.text = saved.postcode;
      _instructions.text = saved.instructions ?? '';
    }
    ref.listenManual(meProvider, (_, next) {
      final me = next.value;
      if (me == null) return;
      if (_recipient.text.isEmpty) _recipient.text = me.displayName ?? '';
      if (_city.text.isEmpty) _city.text = me.profile?.city ?? '';
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    for (final c in [_recipient, _line, _city, _postcode, _instructions]) {
      c.dispose();
    }
    super.dispose();
  }

  void _continue() {
    setState(() {
      _errors['recipient'] = Validators.text(
        _recipient.text,
        label: 'the recipient’s name',
        required: true,
        minLength: 2,
      );
      _errors['line'] = Validators.text(
        _line.text,
        label: 'the address',
        required: true,
        minLength: 3,
      );
      _errors['city'] = Validators.place(
        _city.text,
        label: 'town or city',
        required: true,
      );
      _errors['postcode'] = Validators.ukPostcode(_postcode.text);
    });
    if (_errors.values.any((e) => e != null)) return;
    final instructions = _instructions.text.trim();
    ref
        .read(shopProvider.notifier)
        .setDelivery(
          ShopDelivery(
            recipient: _recipient.text.trim(),
            line: _line.text.trim(),
            city: _city.text.trim(),
            postcode: _postcode.text.trim().toUpperCase(),
            instructions: instructions.isEmpty ? null : instructions,
          ),
        );
    context.push(RoutePaths.shopPayment);
  }

  @override
  Widget build(BuildContext context) {
    return ShopPage(
      backFallback: RoutePaths.shopBasket,
      children: [
        const StepProgress(step: 1, total: 3),
        const ScreenTitle(
          title: 'Where should we deliver?',
          subtitle: 'Standard delivery, 3 to 5 working days.',
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Recipient name',
          controller: _recipient,
          textCapitalization: TextCapitalization.words,
          errorText: _errors['recipient'],
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Address line',
          controller: _line,
          errorText: _errors['line'],
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Town or city',
          controller: _city,
          errorText: _errors['city'],
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Postcode',
          controller: _postcode,
          hintText: 'e.g. SW1A 1AA',
          textCapitalization: TextCapitalization.characters,
          errorText: _errors['postcode'],
        ),
        TextAreaField(
          label: 'Delivery instructions',
          controller: _instructions,
          optional: true,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Continue to payment', onPressed: _continue),
      ],
    );
  }
}

/// "Your payment method" — checkout step 2 (screen pack 109). The preview
/// collects no card details.
class ShopPaymentScreen extends StatelessWidget {
  const ShopPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShopPage(
      backFallback: RoutePaths.shopDelivery,
      children: [
        const StepProgress(step: 2, total: 3),
        const ScreenTitle(
          title: 'Your payment method',
          subtitle: 'How you will pay for this order.',
        ),
        const SizedBox(height: 14),
        ChoiceCard(
          title: 'Card, at checkout',
          subtitle: 'Handled securely by our payment provider',
          selected: true,
          onTap: () {},
        ),
        const SizedBox(height: 8),
        const InfoBanner(
          tone: BannerTone.warning,
          message:
              'No card details are collected or charged while the shop is in '
              'preview.',
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Review order',
          onPressed: () => context.push(RoutePaths.shopReview),
        ),
      ],
    );
  }
}

/// "One last look" — checkout step 3 (screen pack 110).
class ShopReviewScreen extends ConsumerStatefulWidget {
  const ShopReviewScreen({super.key});

  @override
  ConsumerState<ShopReviewScreen> createState() => _ShopReviewScreenState();
}

class _ShopReviewScreenState extends ConsumerState<ShopReviewScreen> {
  bool _agreed = false;
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    final shop = ref.watch(shopProvider);
    final delivery = shop.delivery;
    return ShopPage(
      backFallback: RoutePaths.shopPayment,
      children: [
        const StepProgress(step: 3, total: 3),
        const ScreenTitle(
          title: 'One last look',
          subtitle: 'Check your order before you place it.',
        ),
        const SizedBox(height: 10),
        DetailList(
          rows: [
            for (final line in shop.lines)
              (
                '${line.product.name} × ${line.quantity}',
                Formatters.money(line.totalPence),
              ),
          ],
        ),
        if (delivery != null)
          PanelCard(
            title: 'Delivery address',
            body:
                '${delivery.recipient}\n${delivery.line}\n'
                '${delivery.city} ${delivery.postcode}',
          ),
        ShopTotals(
          subtotalPence: shop.subtotalPence,
          deliveryPence: shop.deliveryPence,
        ),
        const SizedBox(height: 6),
        CheckRow(
          value: _agreed,
          onChanged: (v) => setState(() {
            _agreed = v;
            if (v) _showError = false;
          }),
          label:
              'I have reviewed my order and understand that, while the shop '
              'is in preview, nothing will be charged or shipped.',
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
          label: 'Place order',
          onPressed: shop.itemCount == 0 || delivery == null
              ? null
              : () {
                  if (!_agreed) {
                    setState(() => _showError = true);
                    return;
                  }
                  final order = ref.read(shopProvider.notifier).placeOrder();
                  context.go(RoutePaths.home);
                  context.push(RoutePaths.shop);
                  context.push(RoutePaths.shopConfirmed, extra: order);
                },
        ),
      ],
    );
  }
}

/// "Thank you" — order confirmed (screen pack 111).
class ShopConfirmedScreen extends ConsumerWidget {
  const ShopConfirmedScreen({super.key, required this.order});

  final ShopOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final first = order.delivery.recipient.split(' ').first;
    return ShopPage(
      children: [
        const SuccessIcon(),
        ScreenTitle(
          title: 'Thank you, $first',
          subtitle:
              'Your order is placed. While the shop is in preview, no payment '
              'is taken and nothing will be shipped.',
        ),
        const SizedBox(height: 12),
        const StatusBadge('Confirmed', tone: BadgeTone.blue),
        DetailList(
          rows: [
            ('Order', order.reference),
            ('Total', Formatters.money(order.totalPence)),
            ('Delivery', '3 to 5 working days'),
            ('Status', 'Confirmed'),
          ],
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'View your order',
          onPressed: () =>
              context.pushReplacement(RoutePaths.shopOrder, extra: order),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Continue shopping',
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
