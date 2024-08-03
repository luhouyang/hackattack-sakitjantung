import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensesPieChart extends StatefulWidget {
  final int numberOfCategories;
  final List<double> amounts;
  final List<String> names;

  const ExpensesPieChart({
    super.key,
    required this.numberOfCategories,
    required this.amounts,
    required this.names,
  });

  @override
  State<ExpensesPieChart> createState() => _ExpensesPieChartState();
}

class _ExpensesPieChartState extends State<ExpensesPieChart> {
  int touchedIndex = -1;
  Offset? _touchPosition;

  final List<Color> _colorPalette = [
    const Color(0xFFFF6B6B), // Original coral red
    const Color(0xFF4A89DC), // Original steel blue
    const Color(0xFF8CC152), // Original light green
    const Color(0xFFF6BB42), // Original yellow
    const Color(0xFFE67E22), // Orange
    const Color(0xFF9B59B6), // Purple
    const Color(0xFF34495E), // Dark slate
    const Color(0xFF1ABC9C), // Turquoise
    const Color(0xFFD35400), // Pumpkin
    const Color(0xFF7F8C8D), // Gray
    const Color(0xFF2ECC71), // Emerald
    const Color(0xFFE74C3C),
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> data = _prepareData();
    double totalExpenses = data.fold(0, (prev, item) => prev + item['amount']);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        _touchPosition = null;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                      _touchPosition =
                          event.localPosition; // Capture touch position
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 47.03, // Adjust as needed
                sections: _showingSections(data),
              ),
            ),
            if (touchedIndex != -1 && _touchPosition != null)
              Positioned(
                left: _getAdjustedXPosition(context, constraints),
                top: _getAdjustedYPosition(context, constraints),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.black.withOpacity(0.7),
                    child: Text(
                      _getTooltipMessage(touchedIndex, data),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  'Total Expenses',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _prepareData() {
    List<Map<String, dynamic>> data = [];
    double totalAmount =
        widget.amounts.fold(0, (prev, amount) => prev + amount);

    for (int i = 0; i < widget.numberOfCategories; i++) {
      data.add({
        'color': _colorPalette[i % _colorPalette.length],
        'value':
            (widget.amounts[i] / totalAmount * 100), // Calculate percentage
        'label': widget.names[i],
        'amount': widget.amounts[i],
      });
    }
    return data;
  }

  List<PieChartSectionData> _showingSections(List<Map<String, dynamic>> data) {
    return List.generate(data.length, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 20 : 16;
      final double radius = isTouched ? 94.05 : 85.5;

      return PieChartSectionData(
        color: data[i]['color'],
        value: data[i]['value'],
        title: '${data[i]['value'].toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  double _getAdjustedXPosition(
      BuildContext context, BoxConstraints constraints) {
    double tooltipWidth = 200; // Adjust according to your tooltip width
    double screenWidth = constraints.maxWidth;
    double touchX = _touchPosition!.dx;

    if (touchX + tooltipWidth > screenWidth) {
      return screenWidth - tooltipWidth;
    } else if (touchX < 0) {
      return 0;
    }
    return touchX;
  }

  double _getAdjustedYPosition(
      BuildContext context, BoxConstraints constraints) {
    double tooltipHeight = 50; // Adjust according to your tooltip height
    double screenHeight = constraints.maxHeight;
    double touchY = _touchPosition!.dy;

    if (touchY + tooltipHeight > screenHeight) {
      return screenHeight - tooltipHeight;
    } else if (touchY < 0) {
      return 0;
    }
    return touchY;
  }

  String _getTooltipMessage(int index, List<Map<String, dynamic>> data) {
    if (index < 0 || index >= data.length) return '';
    final dataItem = data[index];
    return '${dataItem['value'].toStringAsFixed(1)}% - ${dataItem['label']}\n\$${dataItem['amount']}';
  }
}
