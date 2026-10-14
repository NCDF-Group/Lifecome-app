import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'route_paths.dart';

extension SafeBack on BuildContext {
  /// Goes back one screen.
  ///
  /// When nothing is behind this screen — it was opened with `go`, from a
  /// link, or restored on its own — `pop` has nowhere to go (go_router throws
  /// "There is nothing to pop"), so this goes to [fallback] instead and the
  /// back button never does nothing.
  void goBack({String fallback = RoutePaths.home}) {
    if (canPop()) {
      pop();
    } else {
      go(fallback);
    }
  }
}
