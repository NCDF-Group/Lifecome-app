import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_state.dart';
import 'error_state.dart';
import 'loading_indicator.dart';

/// Turns an [AsyncValue] into the three states every data screen needs: a
/// spinner while it loads, an [ErrorState] with a retry button if it fails,
/// and the data itself — or [empty] when [isEmpty] says there is none.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    required this.onRetry,
    this.isEmpty,
    this.empty,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback onRetry;

  /// With [empty]: when this returns true for the loaded data, show [empty]
  /// instead of [data].
  final bool Function(T data)? isEmpty;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const LoadingIndicator(),
      error: (error, _) => ErrorState(error: error, onRetry: onRetry),
      data: (loaded) {
        if (empty != null && (isEmpty?.call(loaded) ?? false)) return empty!;
        return data(loaded);
      },
    );
  }
}

/// A ready-made [EmptyState] for a list that has nothing in it.
Widget emptyList({
  required IconData icon,
  required String title,
  String? message,
}) => EmptyState(icon: icon, title: title, message: message);
