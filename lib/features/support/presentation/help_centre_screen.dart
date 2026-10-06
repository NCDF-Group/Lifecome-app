import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';

class _Topic {
  const _Topic({
    required this.icon,
    required this.label,
    required this.background,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color color;
}

const _topics = [
  _Topic(
    icon: Icons.health_and_safety_outlined,
    label: 'HMO membership\n& cover',
    background: Color(0xFFEAF7E8),
    color: AppColors.greenStrong,
  ),
  _Topic(
    icon: Icons.credit_card,
    label: 'Payments\n& refunds',
    background: Color(0xFFFCF3E3),
    color: AppColors.gold,
  ),
  _Topic(
    icon: Icons.calendar_today_outlined,
    label: 'Appointments\n& connections',
    background: Color(0xFFE8F4FC),
    color: AppColors.blue,
  ),
  _Topic(
    icon: Icons.person_outline,
    label: 'Account\n& privacy',
    background: Color(0xFFEAF7E8),
    color: AppColors.greenStrong,
  ),
];

/// Help and support, under the Profile tab. Matches view 20 in the
/// screenshot set ("How can we help?").
class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'How can we help?',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search help topics',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.5,
              children: [for (final topic in _topics) _TopicCard(topic: topic)],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Need more help?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.headset_mic_outlined, color: AppColors.blue),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Contact patient support',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Message our care team and get help with your account, appointments, cover and more.',
                    style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PrimaryButton(
                    label: 'Send a message',
                    icon: Icons.send,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFFCEAEA),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.error),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Medical emergency?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Seek immediate in-person care. Do not wait for a chat reply.',
                    style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
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

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final _Topic topic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: topic.background,
              shape: BoxShape.circle,
            ),
            child: Icon(topic.icon, color: topic.color, size: 20),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              topic.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
