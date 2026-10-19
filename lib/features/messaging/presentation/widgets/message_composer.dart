import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/feedback/app_popup.dart';

/// The longest message the backend accepts.
const maxMessageLength = 4000;

/// The box at the bottom of a conversation: type, then send. Sending is off
/// while the box is empty or over the backend's limit (which is explained
/// under the box), and the text stays put if sending fails.
class MessageComposer extends StatefulWidget {
  const MessageComposer({super.key, required this.onSend});

  final Future<void> Function(String body) onSend;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? get _error => Validators.text(
    _controller.text,
    label: 'a message',
    maxLength: maxMessageLength,
  );

  bool get _canSend =>
      !_sending && _controller.text.trim().isNotEmpty && _error == null;

  Future<void> _send() async {
    if (!_canSend) return;
    final body = _controller.text.trim();
    setState(() => _sending = true);
    try {
      await widget.onSend(body);
      if (mounted) _controller.clear();
    } on ApiException catch (error) {
      if (mounted) await showErrorPopup(context, error.message);
    } catch (_) {
      if (mounted) {
        await showErrorPopup(
          context,
          'Something went wrong. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              onChanged: (_) => setState(() {}),
              style: TextStyle(fontSize: 15, color: palette.ink),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                errorText: _error,
                filled: true,
                fillColor: palette.elevated,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: palette.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: palette.line),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Material(
              color: _canSend
                  ? AppColors.blue
                  : AppColors.blue.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: _canSend ? _send : null,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: _sending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(
                          Icons.arrow_upward_rounded,
                          color: AppColors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
