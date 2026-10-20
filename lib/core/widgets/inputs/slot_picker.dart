import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../utils/formatters.dart';

/// Pick a day, then a time on it (the screen pack's `.date-grid` and
/// `.slots`), from a list of available start times.
class SlotPicker extends StatefulWidget {
  const SlotPicker({
    super.key,
    required this.slots,
    required this.selected,
    required this.onSelected,
  });

  final List<DateTime> slots;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  @override
  State<SlotPicker> createState() => _SlotPickerState();
}

class _SlotPickerState extends State<SlotPicker> {
  late DateTime _day = _dayOf(widget.selected ?? widget.slots.first);

  static DateTime _dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final days = <DateTime>[];
    for (final slot in widget.slots) {
      final day = _dayOf(slot);
      if (!days.contains(day)) days.add(day);
    }
    final onDay = [
      for (final slot in widget.slots)
        if (_dayOf(slot) == _day) slot,
    ];

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: palette.ink,
        ),
      ),
    );

    Widget tile({
      required bool selected,
      required VoidCallback onTap,
      required Widget child,
    }) => Material(
      color: selected ? palette.tintBlueFaint : palette.elevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
        side: BorderSide(color: selected ? palette.accent : palette.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: Center(child: child),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label('Choose a date'),
        Row(
          children: [
            for (var i = 0; i < days.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 76,
                  child: tile(
                    selected: days[i] == _day,
                    onTap: () => setState(() => _day = days[i]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Formatters.shortDate(days[i]).split(' ').first,
                          style: TextStyle(
                            fontSize: 11,
                            color: days[i] == _day
                                ? palette.accent
                                : palette.inkMuted,
                          ),
                        ),
                        Text(
                          '${days[i].day}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: days[i] == _day
                                ? palette.accent
                                : palette.ink,
                          ),
                        ),
                        Text(
                          Formatters.shortDate(days[i]).split(' ').last,
                          style: TextStyle(
                            fontSize: 11,
                            color: days[i] == _day
                                ? palette.accent
                                : palette.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        label('Available times · UK time'),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.6,
          children: [
            for (final slot in onDay)
              tile(
                selected: slot == widget.selected,
                onTap: () => widget.onSelected(slot),
                child: Text(
                  Formatters.time(slot),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: slot == widget.selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: slot == widget.selected
                        ? palette.accent
                        : palette.ink,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
