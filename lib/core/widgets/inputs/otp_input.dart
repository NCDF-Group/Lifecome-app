import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

/// A row of single-digit boxes for entering a verification code, matching
/// the six-box layout used across the app's verification screens.
/// Calls [onCompleted] once every box has a digit.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.errorText,
  });

  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  /// Clears every box and returns focus to the first one. Used after a
  /// failed attempt so the user can retype without deleting each digit.
  void clear() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
  }

  void _handleChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    widget.onChanged?.call(_code);
    if (_code.length == widget.length) {
      widget.onCompleted(_code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Sizes each box from the space actually available, so this
            // never overflows on a narrow phone and never looks
            // stretched-out on a tablet.
            const gap = 8.0;
            final totalGap = gap * (widget.length - 1);
            final boxSize = ((constraints.maxWidth - totalGap) / widget.length)
                .clamp(40.0, 56.0);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < widget.length; index++) ...[
                  if (index > 0) const SizedBox(width: gap),
                  _OtpBox(
                    size: boxSize,
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    hasError: hasError,
                    onChanged: (value) => _handleChanged(index, value),
                  ),
                ],
              ],
            );
          },
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.size,
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
  });

  final double size;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final focused = focusNode.hasFocus;
        final ringColor = hasError
            ? AppColors.error
            : (focused ? AppColors.blue : Colors.transparent);

        return Container(
          width: size,
          height: size + 8,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(color: ringColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        );
      },
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          hintText: '0',
          hintStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.line,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
