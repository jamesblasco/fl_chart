import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:fl_chart/src/chart/line_chart/range/fl_range.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class RangeGestureDetector extends StatefulWidget {
  final Widget child;
  final Function(List<Offset> range) onRangeSelected;

  const RangeGestureDetector({Key key, this.child, this.onRangeSelected})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RangeGestureDetectorState();
}

class _RangeGestureDetectorState extends State<RangeGestureDetector> {
  @override
  final List<_DragHandler> drags = [];

  Timer _debounce;

  bool shouldAvoid = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                () => TapGestureRecognizer(), (TapGestureRecognizer instance) {
          instance
            ..onTapUp = (TapUpDetails details) {
              setState(() => shouldAvoid = true);
              _debounce = Timer(const Duration(milliseconds: 200), () {
                setState(() => shouldAvoid = false);
              });
              widget.onRangeSelected?.call([
                details.localPosition,
                ..._getDragRange()
              ]..sort((a, b) => a.dx.compareTo(b.dx)));
            };
        }),
        HorizontalMultiDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
                    HorizontalMultiDragGestureRecognizer>(
                () => HorizontalMultiDragGestureRecognizer(),
                (HorizontalMultiDragGestureRecognizer instance) {
          instance
            ..onStart = (Offset offset) {
              final drag = _DragHandler(offset);
              if (drags.length < 2) {
                updateRange();
                drags.add(drag);
                print('[Drags] Added, total amount: ${drags.length}');
                drag
                  ..onUpdate = (DragUpdateDetails details) {
                    updateRange();
                    print('[Drag] Update: ${details.toString()}');
                  }
                  ..onEnd = (DragEndDetails details) {
                    setState(() => shouldAvoid = true);
                    _debounce = Timer(const Duration(milliseconds: 200), () {
                      setState(() => shouldAvoid = false);
                    });
                    drags.remove(drag);
                    print('[Drags] Removed, total amount: ${drags.length}');
                  };
              }
              return drag;
            };
        })
      },
      child: widget.child,
    );
  }

  List<Offset> _getDragRange() => drags.map((drag) => drag.offset).toList();

  void updateRange() {
    if (shouldAvoid) {
      return;
    }

    widget.onRangeSelected
        ?.call(_getDragRange()..sort((a, b) => a.dx.compareTo(b.dx)));
  }
}

class _DragHandler extends Drag {
  Offset offset;

  _DragHandler(this.offset);

  GestureDragUpdateCallback onUpdate;
  GestureDragEndCallback onEnd;

  @override
  void update(DragUpdateDetails details) {
    offset = details.localPosition;
    onUpdate?.call(details);
  }

  @override
  void end(DragEndDetails details) {
    onEnd?.call(details);
  }

  @override
  void cancel() {}
}
