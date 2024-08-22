import 'dart:async';

import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final Duration initialDuration;
  final VoidCallback onTimeUp;
  final VoidCallback onMarkPaid;

  TimerWidget({
    required this.initialDuration,
    required this.onTimeUp,
    required this.onMarkPaid,
  });

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _countdownTimer;
  //Duration _remainingTime;
  Duration _remainingTime = Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.initialDuration;
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        widget.onTimeUp();
      } else {
        setState(() {
          _remainingTime -= Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'Time Remaining: ${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: widget.onMarkPaid,
            child: Text('Mark Paid'),
          ),
        ],
      ),
    );
  }
}
