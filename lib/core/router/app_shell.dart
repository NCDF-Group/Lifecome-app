import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_svg_icons.dart';

/// Hosts the five bottom-nav tabs (Home, Book, Records, Messages,
/// Profile) behind a `StatefulShellRoute`, so switching tabs keeps each
/// one's own navigation stack instead of losing it. Tabs cross-fade (see
/// [FadingBranches]) and the bar itself is a floating pill ([_FloatingNavBar])
/// whose blue selection slides between tabs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: navigationShell,
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: navigationShell.currentIndex,
        onSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

/// Stacks every tab's navigator (all stay mounted, so each keeps its state
/// and scroll position) and cross-fades, with a slight rise, to the selected
/// one. Hidden tabs ignore touches and stop animating.
class FadingBranches extends StatelessWidget {
  const FadingBranches({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < children.length; i++)
          _FadingBranch(active: i == currentIndex, child: children[i]),
      ],
    );
  }
}

class _FadingBranch extends StatefulWidget {
  const _FadingBranch({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_FadingBranch> createState() => _FadingBranchState();
}

class _FadingBranchState extends State<_FadingBranch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    value: widget.active ? 1 : 0,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  @override
  void didUpdateWidget(_FadingBranch old) {
    super.didUpdateWidget(old);
    if (widget.active != old.active) {
      widget.active ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Visibility(
        visible: !_controller.isDismissed,
        maintainState: true,
        child: IgnorePointer(
          ignoring: !widget.active,
          child: FadeTransition(
            opacity: _curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.015),
                end: Offset.zero,
              ).animate(_curve),
              child: child,
            ),
          ),
        ),
      ),
      child: TickerMode(enabled: widget.active, child: widget.child),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.glyph,
    required this.selectedGlyph,
  });

  final String label;

  /// Outline glyph shown while the tab is idle.
  final AppSvgGlyph glyph;

  /// Solid glyph shown inside the blue pill.
  final AppSvgGlyph selectedGlyph;
}

const _items = [
  _NavItem(
    label: 'Home',
    glyph: AppSvgGlyph.homeLine,
    selectedGlyph: AppSvgGlyph.homeBold,
  ),
  _NavItem(
    label: 'Book',
    glyph: AppSvgGlyph.calendarLine,
    selectedGlyph: AppSvgGlyph.calendarBold,
  ),
  _NavItem(
    label: 'Records',
    glyph: AppSvgGlyph.documentLine,
    selectedGlyph: AppSvgGlyph.documentBold,
  ),
  _NavItem(
    label: 'Messages',
    glyph: AppSvgGlyph.chatLine,
    selectedGlyph: AppSvgGlyph.chatBold,
  ),
  _NavItem(
    label: 'Profile',
    glyph: AppSvgGlyph.userLine,
    selectedGlyph: AppSvgGlyph.userLine,
  ),
];

const _barHeight = 60.0;
const _barPadding = 4.0;
const _iconSize = 24.0;
const _pillPadding = 16.0;
const _pillGap = 8.0;
const _labelStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w600,
  color: AppColors.white,
);

/// A pill-shaped bar floating above the bottom edge. The selected tab is a
/// filled blue pill showing its icon and label; the others are bare grey
/// icons. Changing tab slides the pill across, squeezing the other icons
/// together and apart, in one continuous animation driven by a fractional
/// tab position `t`.
class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.currentIndex, required this.onSelected});

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    // Width the pill needs when each tab is selected: padding + icon + label.
    final pillWidths = [
      for (final item in _items)
        _pillPadding * 2 +
            _iconSize +
            _pillGap +
            (TextPainter(
              text: TextSpan(text: item.label, style: _labelStyle),
              textDirection: TextDirection.ltr,
              textScaler: scaler,
              maxLines: 1,
            )..layout()).width,
    ];

    return ColoredBox(
      color: AppColors.white,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Container(
            height: _barHeight,
            padding: const EdgeInsets.all(_barPadding),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => TweenAnimationBuilder<double>(
                tween: Tween(end: currentIndex.toDouble()),
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                builder: (context, t, _) => _NavBarContent(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  t: t,
                  pillWidths: pillWidths,
                  onSelected: onSelected,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarContent extends StatelessWidget {
  const _NavBarContent({
    required this.width,
    required this.height,
    required this.t,
    required this.pillWidths,
    required this.onSelected,
  });

  final double width;
  final double height;
  final double t;
  final List<double> pillWidths;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final n = _items.length;
    final lo = t.floor().clamp(0, n - 1);
    final hi = t.ceil().clamp(0, n - 1);
    final frac = t - lo;

    // Pill width at this instant, and the width left for each other tab.
    final pillWidth = pillWidths[lo] + (pillWidths[hi] - pillWidths[lo]) * frac;
    final slot = (width - pillWidth) / (n - 1);

    // How "selected" each tab is right now: 1 under the pill, 0 elsewhere.
    double weight(int j) => math.max(0, 1 - (t - j).abs());

    // Each tab's cell grows from `slot` to its own pill width as it's selected.
    final cellWidths = [
      for (var j = 0; j < n; j++) slot + (pillWidths[j] - slot) * weight(j),
    ];
    var x = 0.0;
    final cellLeft = <double>[];
    for (final w in cellWidths) {
      cellLeft.add(x);
      x += w;
    }
    final pillLeft = t * slot;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: pillLeft,
          width: pillWidth,
          top: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.actionBlue,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        for (var j = 0; j < n; j++) ...[
          // Icon: glides from its resting cell into the pill as it's selected.
          Positioned(
            left:
                (cellLeft[j] + (slot - _iconSize) / 2) * (1 - weight(j)) +
                (pillLeft + _pillPadding) * weight(j),
            top: (height - _iconSize) / 2,
            child: IgnorePointer(
              child: AppSvgIcon(
                weight(j) > 0.5 ? _items[j].selectedGlyph : _items[j].glyph,
                size: _iconSize,
                color: Color.lerp(
                  AppColors.textSecondary,
                  AppColors.white,
                  weight(j),
                ),
              ),
            ),
          ),
          if (weight(j) > 0.01)
            Positioned(
              left: pillLeft + _pillPadding + _iconSize + _pillGap,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: weight(j),
                  child: Center(
                    child: Text(
                      _items[j].label,
                      maxLines: 1,
                      softWrap: false,
                      style: _labelStyle,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: cellLeft[j],
            width: cellWidths[j],
            top: 0,
            bottom: 0,
            child: Semantics(
              button: true,
              selected: weight(j) > 0.5,
              label: _items[j].label,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(j),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
