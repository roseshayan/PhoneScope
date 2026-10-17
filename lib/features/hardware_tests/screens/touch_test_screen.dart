import 'package:flutter/material.dart';

class TouchTestScreen extends StatefulWidget {
  const TouchTestScreen({super.key});

  @override
  State<TouchTestScreen> createState() => _TouchTestScreenState();
}

class _TouchTestScreenState extends State<TouchTestScreen> {
  final Map<int, Offset> _activePointers = {};
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  final Set<int> _touchedGridCells = {};
  static const int _gridCols = 8;
  static const int _gridRows = 14;

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _activePointers[event.pointer] = event.localPosition;
      _currentStroke = [event.localPosition];
      _strokes.add(_currentStroke);
      _markGridCell(event.localPosition);
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    setState(() {
      _activePointers[event.pointer] = event.localPosition;
      _currentStroke.add(event.localPosition);
      _markGridCell(event.localPosition);
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _activePointers.remove(event.pointer);
    });
  }

  void _onPointerCancel(PointerCancelEvent event) {
    setState(() {
      _activePointers.remove(event.pointer);
    });
  }

  void _markGridCell(Offset pos) {
    final size = MediaQuery.of(context).size;
    final cellW = size.width / _gridCols;
    final cellH = size.height / _gridRows;
    final col = (pos.dx / cellW).floor().clamp(0, _gridCols - 1);
    final row = (pos.dy / cellH).floor().clamp(0, _gridRows - 1);
    final cellIndex = row * _gridCols + col;
    _touchedGridCells.add(cellIndex);
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
      _touchedGridCells.clear();
      _activePointers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final totalCells = _gridCols * _gridRows;
    final coveragePercent = ((_touchedGridCells.length / totalCells) * 100)
        .toStringAsFixed(0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: Stack(
          children: [
            // Grid Background
            CustomPaint(
              size: size,
              painter: _TouchGridPainter(
                cols: _gridCols,
                rows: _gridRows,
                touchedCells: _touchedGridCells,
              ),
            ),
            // Finger Strokes
            CustomPaint(
              size: size,
              painter: _StrokesPainter(
                strokes: _strokes,
                activePointers: _activePointers,
              ),
            ),
            // Header stats
            Positioned(
              top: 45,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'لمس همزمان: ${_activePointers.length}',
                      style: const TextStyle(
                        color: Color(0xFF06B6D4),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'پوشش صفحه: $coveragePercent%',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: 'پاک کردن',
                          onPressed: _clearCanvas,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 14),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06B6D4),
                            foregroundColor: const Color(0xFF0B1120),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'پایان',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TouchGridPainter extends CustomPainter {
  final int cols;
  final int rows;
  final Set<int> touchedCells;

  _TouchGridPainter({
    required this.cols,
    required this.rows,
    required this.touchedCells,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    final cellPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.25);
    final borderPaint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final index = r * cols + c;
        final rect = Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH);
        if (touchedCells.contains(index)) {
          canvas.drawRect(rect, cellPaint);
        }
        canvas.drawRect(rect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TouchGridPainter oldDelegate) => true;
}

class _StrokesPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Map<int, Offset> activePointers;

  _StrokesPainter({required this.strokes, required this.activePointers});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length > 1) {
        for (int i = 0; i < stroke.length - 1; i++) {
          canvas.drawLine(stroke[i], stroke[i + 1], strokePaint);
        }
      }
    }

    // Active Pointer Circles
    final pointerPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.8);
    for (final pos in activePointers.values) {
      canvas.drawCircle(pos, 35, pointerPaint);
      canvas.drawCircle(pos, 8, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokesPainter oldDelegate) => true;
}
