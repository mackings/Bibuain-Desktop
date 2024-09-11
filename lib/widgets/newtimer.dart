import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class CountdownTimerWidget extends StatefulWidget {
  final String tradeHash;
  final int duration;
  final VoidCallback onComplete;
  
  const CountdownTimerWidget({
    Key? key,
    required this.tradeHash,
    required this.duration,
    required this.onComplete,
  }) : super(key: key);

  @override
  _CountdownTimerWidgetState createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late CountDownController _countdownController;
  
  @override
  void initState() {
    super.initState();
    _countdownController = CountDownController();
  }

  @override
  Widget build(BuildContext context) {
    return CircularCountDownTimer(
      key: ValueKey(widget.tradeHash),
      width: 35,
      height: 35,
      duration: widget.duration,
      fillColor: Colors.black,
      ringColor: Colors.blue,
      controller: _countdownController,
      autoStart: true,
      onStart: () {
        // You can handle start logic here
      },
      onComplete: widget.onComplete,
    );
  }
}
