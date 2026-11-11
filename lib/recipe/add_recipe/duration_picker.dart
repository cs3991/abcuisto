import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DurationPicker extends StatefulWidget {
  final String label;
  final Duration? initialDuration;
  final ValueChanged<Duration> onDurationChanged;
  const DurationPicker({
    super.key,
    required this.label,
    this.initialDuration,
    required this.onDurationChanged,
  });

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatDuration(widget.initialDuration ?? Duration.zero),
    );
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    });
  }

  String _formatDuration(Duration duration) =>
      '${duration.inHours.toString().padLeft(2, '0')}:'
      '${(duration.inMinutes % 60).toString().padLeft(2, '0')}';

  Duration _parseDuration(String text) {
    final parts = text.split(':');
    return Duration(
      hours: int.tryParse(parts.first) ?? 0,
      minutes: parts.length > 1 ? int.tryParse(parts.last) ?? 0 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant DurationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final duration = widget.initialDuration ?? Duration.zero;
    if (oldWidget.initialDuration != widget.initialDuration &&
        duration != _parseDuration(_controller.text)) {
      _controller.text = _formatDuration(duration);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [_DurationInputFormatter()],
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: '00:10',
          helperText: 'Heures : minutes',
          border: const OutlineInputBorder(),
        ),
        onChanged: (text) => widget.onDurationChanged(_parseDuration(text)),
        onSubmitted: (_) {
          _controller.text = _formatDuration(_parseDuration(_controller.text));
        },
      ),
    );
  }
}

class _DurationInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    var cursor = newValue.selection.extentOffset;
    // Backspacing over the separator also removes the preceding digit.
    if (oldValue.text.contains(':') &&
        !text.contains(':') &&
        oldValue.text.length == text.length + 1 &&
        oldValue.selection.isCollapsed &&
        oldValue.selection.extentOffset == 3 &&
        cursor == 2) {
      text = text.replaceRange(1, 2, '');
      cursor--;
    }
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 4 || (digits.length > 2 && int.parse(digits[2]) > 5)) {
      return oldValue;
    }
    final digitsBeforeCursor = text
        .substring(0, cursor.clamp(0, text.length))
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;
    final formatted = digits.length < 2
        ? digits
        : '${digits.substring(0, 2)}:${digits.substring(2)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: digitsBeforeCursor + (digitsBeforeCursor >= 2 ? 1 : 0),
      ),
    );
  }
}
