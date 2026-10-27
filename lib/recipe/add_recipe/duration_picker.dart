import 'package:flutter/material.dart';

class DurationPicker extends StatefulWidget {
  final String label;
  final Duration? initialDuration;
  final ValueChanged<Duration> onDurationChanged;
  const DurationPicker({super.key, required this.label, this.initialDuration, required this.onDurationChanged});

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late final PageController _hoursController;
  late final PageController _minutesController;

  @override
  void initState() {
    super.initState();
    _hoursController = PageController(initialPage: widget.initialDuration?.inHours ?? 0);
    _minutesController = PageController(initialPage: (widget.initialDuration?.inMinutes ?? 0) % 60);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Hours
            SizedBox(
              height: 40,
              width: 40,
              child: PageView.builder(
                onPageChanged: (value) {
                  widget.onDurationChanged(Duration(hours: value, minutes: (widget.initialDuration?.inMinutes ?? 0) % 60));
                },
                controller: _hoursController,

                scrollDirection: Axis.vertical,
                itemCount: 73,
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                      top: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Center(child: Text(index.toString())),
                ),
              ),
            ),
            Text('hrs'),
            // Minutes
            SizedBox(
              height: 40,
              width: 40,
              child: PageView.builder(
                controller: _minutesController,
                scrollDirection: Axis.vertical,
                onPageChanged: (value) {
                  widget.onDurationChanged(Duration(hours: widget.initialDuration?.inHours ?? 0, minutes: value));
                },
                itemCount: 60,
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                      top: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Center(child: Text((index).toString())),
                ),
              ),
            ),
            Text('min'),
          ],
        ),
      ],
    );
  }
}

