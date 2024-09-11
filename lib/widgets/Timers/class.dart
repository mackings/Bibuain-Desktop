import 'dart:async';

class CountdownTimerService {
  Timer? _timer;
  int _duration = 0;
  void Function()? onComplete;

  CountdownTimerService({required int duration, this.onComplete}) {
    _duration = duration;
  }

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_duration > 0) {
        _duration--;
      } else {
        _timer?.cancel();
        if (onComplete != null) {
          onComplete!();
        }
      }
    });
  }

  void reset(int duration) {
    _duration = duration;
    start();
  }

  int get remainingTime => _duration;
}
