class EmaFilter {
  final double alpha;
  double? _current;

  EmaFilter({this.alpha = 0.2});

  double filter(double newValue) {
    if (_current == null) {
      _current = newValue;
    } else {
      _current = (_current! * (1.0 - alpha)) + (newValue * alpha);
    }
    return _current!;
  }

  void reset() {
    _current = null;
  }
}
