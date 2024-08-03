import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int touchedIndex = -1;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  List<String> titles = ['Expense', 'Income'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "STATISTICS",
              style: TextStyle(
                color: Colors.red[900],
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5), // Reduce space between title and button
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 5.0), // Add vertical padding around the button
              child: SegmentedButton(
                segments: titles,
                selectedIndex: _currentPage,
                onSegmentTapped: (index) {
                  setState(() {
                    _currentPage = index;
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: 10), // Space between button and chart
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPieChartExpenses(),
                  _buildPieChartIncome(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartExpenses() {
    return Center(
      child: Stack(
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
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
              centerSpaceRadius: 55,
              sections: [
                PieChartSectionData(
                  color: const Color(0xFFFE5F55),
                  value: 60,
                  title: '60%',
                  radius: touchedIndex == 0 ? 110 : 100,
                  titleStyle: TextStyle(
                    fontSize: touchedIndex == 0 ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: const Color(0xFF577399),
                  value: 20,
                  title: '20%',
                  radius: touchedIndex == 1 ? 110 : 100,
                  titleStyle: TextStyle(
                    fontSize: touchedIndex == 1 ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: const Color(0xFF90BE6D),
                  value: 10,
                  title: '10%',
                  radius: touchedIndex == 2 ? 110 : 100,
                  titleStyle: TextStyle(
                    fontSize: touchedIndex == 2 ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: const Color(0xFFF5E960),
                  value: 10,
                  title: '10%',
                  radius: touchedIndex == 3 ? 110 : 100,
                  titleStyle: TextStyle(
                    fontSize: touchedIndex == 3 ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$458.00',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Total Expense',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartIncome() {
    return Center(
      child: Stack(
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
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
              centerSpaceRadius: 55,
              sections: [
                PieChartSectionData(
                  color: const Color(0xFF4B9CD3),
                  value: 50,
                  title: '50%',
                  radius: touchedIndex == 0 ? 110 : 100,
                  titleStyle: TextStyle(
                    fontSize: touchedIndex == 0 ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: const Color(0xFF8A4C4A),
                  value: 25,
                  title: '25%',
                  radius: touchedIndex == 1 ? 110 : 100,
                  titleStyle: TextStyle(
                    fontSize: touchedIndex == 1 ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: const Color(0xFF68B4C8),
                  value: 15,
                  title: '15%',
                  radius: touchedIndex == 2 ? 110 : 100,
                  titleStyle: TextStyle(
                    fontSize: touchedIndex == 2 ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: const Color(0xFF9B8F8F),
                  value: 10,
                  title: '10%',
                  radius: touchedIndex == 3 ? 110 : 100,
                  titleStyle: TextStyle(
                    fontSize: touchedIndex == 3 ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$1234.00',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Total Income',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SegmentedButton extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final Function(int) onSegmentTapped;

  const SegmentedButton({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onSegmentTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 146, 146, 146),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(segments.length, (index) {
          bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSegmentTapped(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color.fromARGB(255, 223, 225, 226)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                segments[index],
                style: TextStyle(
                  color:
                      isSelected ? Colors.black : Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
