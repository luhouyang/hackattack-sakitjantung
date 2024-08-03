import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CashflowPieChart extends StatefulWidget {
  final int numberOfCategories;
  final List<double> amounts;
  final List<String> names;

  const CashflowPieChart({
    super.key,
    required this.numberOfCategories,
    required this.amounts,
    required this.names,
  });

  @override
  State<CashflowPieChart> createState() => _CashflowPieChartState();
}

class _CashflowPieChartState extends State<CashflowPieChart> {
  int touchedIndex = -1;
  Offset? _touchPosition;

  // Define your custom color palette
  final List<Color> _customColors = [
    Color(0xFF4A69BD),
    Color(0xFF7D3C98),
    Color(0xFF9B59B6),
    Color(0xFFE74C3C),
    Color(0xFFE67E22),
    Color(0xFFFFFFFF),
    Color(0xFF000000),
    Color(0xFFF5F5F5),
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> data = _prepareData();
    double totalCashflow = data.fold(0, (prev, item) => prev + item['amount']);

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
                centerSpaceRadius: 47.03, // Match the ExpensesPieChart size
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
                  '\$${totalCashflow.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  'Total Cashflow',
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
        'color': _customColors[
            i % _customColors.length], // Cycle through custom colors
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
