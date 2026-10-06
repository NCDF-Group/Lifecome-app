import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Shows "Resend code" once [availableAt] has passed, and a countdown
/// before that, matching the wording used on the website and in the
/// inspiration screens ("Resend code in 00:28").
class OtpTimer extends StatefulWidget {
  const OtpTimer({
    super.key,
    required this.availableAt,
    required this.onResend,
  });

  final DateTime availableAt;
  final VoidCallback onResend;

  @override
  State<OtpTimer> createState() => _OtpTimerState();
}

class _OtpTimerState extends State<OtpTimer> {
  Timer? _ticker;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = _timeLeft();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _remaining = _timeLeft());
      if (_remaining <= Duration.zero) {
        _ticker?.cancel();
      }
    });
  }

  Duration _timeLeft() {
    final left = widget.availableAt.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  @override
  void didUpdateWidget(covariant OtpTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.availableAt != widget.availableAt) {
      _remaining = _timeLeft();
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _remaining = _timeLeft());
        if (_remaining <= Duration.zero) {
          _ticker?.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining <= Duration.zero) {
      return TextButton(
        onPressed: widget.onResend,
        child: const Text(
          "Didn't get any code? Resend",
          style: TextStyle(
            color: AppColors.blue,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      );
    }

    final seconds = _remaining.inSeconds;
    final label = '00:${seconds.toString().padLeft(2, '0')}';
    return Text(
      "Didn't get any code? Resend in $label",
      style: const TextStyle(color: AppColors.inkMuted, fontSize: 14),
    );
  }
}
