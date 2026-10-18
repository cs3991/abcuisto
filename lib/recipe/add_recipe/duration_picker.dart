import 'package:flutter/material.dart';

class DurationPicker extends StatelessWidget {
  final String label;
  final Duration? initialDuration;
  final ValueChanged<Duration> onDurationChanged;
  late PageController hours_controller;
  late PageController minutes_controller;
  int hours = 0;
  int minutes = 0;

  DurationPicker({Key? key, required this.label, this.initialDuration, required this.onDurationChanged}) : super(key: key) {
    hours_controller = PageController(initialPage: initialDuration != null ? initialDuration!.inHours : 0);
    minutes_controller = PageController(initialPage: initialDuration != null ? initialDuration!.inMinutes % 60 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
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
                  hours = value;
                  onDurationChanged(Duration(hours: hours, minutes: minutes));
                },
                controller: hours_controller,

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
                controller: minutes_controller,
                scrollDirection: Axis.vertical,
                onPageChanged: (value) {
                  minutes = value;
                  onDurationChanged(Duration(hours: hours, minutes: minutes));
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

int hours = 0;
int minutes = 0;
