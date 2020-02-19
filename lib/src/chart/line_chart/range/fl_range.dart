

class FlRange {
  final double start;
  final double end;

  FlRange(this.start, this.end);

  FlRange copyWith({double start, double end}) =>
      FlRange(start ?? this.start, end ?? this.end);

  FlRange relativeRange([double minX, double maxX]) =>
      FlRange((start - minX) / (maxX - minX), (end - minX) / (maxX - minX));
}
